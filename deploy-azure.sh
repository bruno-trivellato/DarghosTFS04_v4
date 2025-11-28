#!/bin/bash
# Darghos TFS Azure Quick Deployment Script
# Deploys pre-built container to Azure Container Instances

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%H:%M:%S')] ERROR: $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%H:%M:%S')] WARNING: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')] INFO: $1${NC}"
}

echo "========================================="
echo "  Darghos TFS Azure Deployment Script"
echo "========================================="
echo ""

# Configuration
RESOURCE_GROUP="${RESOURCE_GROUP:-Bruno-outros}"
LOCATION="${LOCATION:-francecentral}"
ACR_NAME="${ACR_NAME:-darghos1756699566}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

# Container names (can be overridden)
TFS_CONTAINER_NAME="${TFS_CONTAINER_NAME:-darghos-tfs-server}"
MYSQL_CONTAINER_NAME="${MYSQL_CONTAINER_NAME:-darghos-mysql}"

# DNS labels
TFS_DNS_LABEL="${TFS_DNS_LABEL:-darghos-bruno}"
MYSQL_DNS_LABEL="${MYSQL_DNS_LABEL:-darghos-mysql-bruno}"

# MySQL Configuration
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-darghos123}"
MYSQL_DATABASE="${MYSQL_DATABASE:-darghos}"
MYSQL_USER="${MYSQL_USER:-darghos}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-darghos123}"

# TFS Configuration
TFS_SERVER_NAME="${TFS_SERVER_NAME:-Darghos}"
TFS_MOTD="${TFS_MOTD:-Welcome to Darghos on Azure!}"
TFS_EXECUTABLE="${TFS_EXECUTABLE:-/app/tfs-debug}"

# Parse command line arguments
DEPLOY_MYSQL=true
DEPLOY_TFS=true
SKIP_MYSQL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --tfs-only)
            DEPLOY_MYSQL=false
            shift
            ;;
        --mysql-only)
            DEPLOY_TFS=false
            shift
            ;;
        --skip-mysql)
            SKIP_MYSQL=true
            DEPLOY_MYSQL=false
            shift
            ;;
        --help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --tfs-only      Deploy only TFS server (assumes MySQL exists)"
            echo "  --mysql-only    Deploy only MySQL server"
            echo "  --skip-mysql    Don't deploy MySQL, but deploy TFS"
            echo "  --help          Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  RESOURCE_GROUP         Azure resource group (default: Bruno-outros)"
            echo "  LOCATION              Azure location (default: francecentral)"
            echo "  TFS_CONTAINER_NAME    TFS container name (default: darghos-tfs-server)"
            echo "  MYSQL_CONTAINER_NAME  MySQL container name (default: darghos-mysql)"
            echo "  TFS_DNS_LABEL         TFS DNS label (default: darghos-bruno)"
            echo "  MYSQL_DNS_LABEL       MySQL DNS label (default: darghos-mysql-bruno)"
            echo "  IMAGE_TAG             Docker image tag (default: latest)"
            echo ""
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Verify Azure CLI is installed
if ! command -v az &> /dev/null; then
    error "Azure CLI (az) is not installed. Please install it first."
    exit 1
fi

# Verify logged in to Azure
log "Checking Azure authentication..."
if ! az account show &> /dev/null; then
    error "Not logged in to Azure. Please run 'az login' first."
    exit 1
fi

SUBSCRIPTION=$(az account show --query name -o tsv)
info "Using subscription: $SUBSCRIPTION"
echo ""

# Deploy MySQL if requested
if [ "$DEPLOY_MYSQL" = true ]; then
    log "Deploying MySQL container..."
    info "  Name: $MYSQL_CONTAINER_NAME"
    info "  DNS: $MYSQL_DNS_LABEL.$LOCATION.azurecontainer.io"

    az container create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$MYSQL_CONTAINER_NAME" \
        --image mysql:8.0 \
        --os-type Linux \
        --dns-name-label "$MYSQL_DNS_LABEL" \
        --ports 3306 \
        --cpu 2 \
        --memory 4 \
        --environment-variables \
            MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
            MYSQL_DATABASE="$MYSQL_DATABASE" \
            MYSQL_USER="$MYSQL_USER" \
            MYSQL_PASSWORD="$MYSQL_PASSWORD" \
        --restart-policy Always \
        --location "$LOCATION" \
        --no-wait

    log "MySQL container deployment initiated!"
    info "Waiting 30 seconds for MySQL to initialize..."
    sleep 30
    echo ""
fi

# Deploy TFS if requested
if [ "$DEPLOY_TFS" = true ]; then
    log "Retrieving Azure Container Registry credentials..."
    ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

    if [ -z "$ACR_PASSWORD" ]; then
        error "Failed to retrieve ACR password"
        exit 1
    fi

    # Construct MySQL host
    MYSQL_HOST="$MYSQL_DNS_LABEL.$LOCATION.azurecontainer.io"

    log "Deploying TFS server container..."
    info "  Name: $TFS_CONTAINER_NAME"
    info "  DNS: $TFS_DNS_LABEL.$LOCATION.azurecontainer.io"
    info "  Image: $ACR_NAME.azurecr.io/darghos-server:$IMAGE_TAG"
    info "  MySQL: $MYSQL_HOST"
    info "  Executable: $TFS_EXECUTABLE"

    az container create \
        --resource-group "$RESOURCE_GROUP" \
        --name "$TFS_CONTAINER_NAME" \
        --image "$ACR_NAME.azurecr.io/darghos-server:$IMAGE_TAG" \
        --registry-login-server "$ACR_NAME.azurecr.io" \
        --registry-username "$ACR_NAME" \
        --registry-password "$ACR_PASSWORD" \
        --dns-name-label "$TFS_DNS_LABEL" \
        --ports 7171 7172 8080 \
        --cpu 4 \
        --memory 16 \
        --os-type Linux \
        --environment-variables \
            MYSQL_HOST="$MYSQL_HOST" \
            MYSQL_USER="$MYSQL_USER" \
            MYSQL_PASS="$MYSQL_PASSWORD" \
            MYSQL_DATABASE="$MYSQL_DATABASE" \
            MYSQL_PORT=3306 \
            SERVER_NAME="$TFS_SERVER_NAME" \
            MOTD="$TFS_MOTD" \
            TFS_EXECUTABLE="$TFS_EXECUTABLE" \
        --restart-policy Always \
        --location "$LOCATION"

    log "TFS server container deployed!"
    echo ""
fi

# Summary
echo "========================================="
echo "  Deployment Complete!"
echo "========================================="
echo ""

if [ "$DEPLOY_MYSQL" = true ]; then
    echo "MySQL Server:"
    echo "  Host: $MYSQL_DNS_LABEL.$LOCATION.azurecontainer.io"
    echo "  Port: 3306"
    echo "  Database: $MYSQL_DATABASE"
    echo "  User: $MYSQL_USER"
    echo ""
fi

if [ "$DEPLOY_TFS" = true ]; then
    echo "TFS Server:"
    echo "  FQDN: $TFS_DNS_LABEL.$LOCATION.azurecontainer.io"
    echo "  Login Port: 7171"
    echo "  Game Port: 7172"
    echo "  Web Monitor: 8080"
    echo ""

    info "Checking container status..."
    sleep 5
    az container show --resource-group "$RESOURCE_GROUP" --name "$TFS_CONTAINER_NAME" \
        --query "{Name:name, State:instanceView.state, IP:ipAddress.ip, FQDN:ipAddress.fqdn}" \
        -o table
    echo ""
fi

log "Deployment script finished!"
echo ""
echo "Next steps:"
if [ "$DEPLOY_MYSQL" = true ]; then
    echo "  1. Import database schema (see IMPORT_TEST_DATA.md)"
fi
echo "  2. Check container logs: az container logs --resource-group $RESOURCE_GROUP --name $TFS_CONTAINER_NAME"
echo "  3. Connect to container: az container exec --resource-group $RESOURCE_GROUP --name $TFS_CONTAINER_NAME --exec-command /bin/bash"
echo "  4. Test connectivity: nc -zv $TFS_DNS_LABEL.$LOCATION.azurecontainer.io 7171"
echo ""
