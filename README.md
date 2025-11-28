# DarghosTFS04_v4

Darghos server based on The Forgotten Server (TFS) 0.4, used during Tibia version 8.6.

This repository contains all Darghos server changes from 2013 to 2017, before the implementation of the proprietary client.

---

## Local Setup (Docker)

### Prerequisites
- Docker installed
- 4GB+ RAM available
- Tibia 8.6 client

### Quick Start

```bash
# 1. Start MySQL
docker run -d \
  --name darghos-mysql \
  -e MYSQL_ROOT_PASSWORD=darghos123 \
  -e MYSQL_DATABASE=darghos \
  -p 3306:3306 \
  mysql:8.0 \
  --default-authentication-plugin=mysql_native_password

# 2. Import database (wait 15 seconds first)
sleep 15
docker exec -i darghos-mysql mysql -uroot -pdarghos123 darghos < darghos-clean-backup.sql

# 3. Import admin accounts (optional - creates bruno, ninao, yves accounts)
docker exec -i darghos-mysql mysql -uroot -pdarghos123 darghos < create-admin-accounts.sql

# 4. Get your local IP
ifconfig | grep "inet " | grep -v 127.0.0.1
# Example: inet 192.168.1.119

# 5. Build and run TFS server (use YOUR IP from step 4)
docker build --platform linux/amd64 -f Dockerfile.production -t darghos-server:latest .

docker run -d \
  --name darghos-server \
  -p 7171:7171 -p 7172:7172 -p 8080:8080 \
  -e MYSQL_HOST=host.docker.internal \
  -e MYSQL_USER=root \
  -e MYSQL_PASS=darghos123 \
  -e SERVER_IP=192.168.1.119 \
  darghos-server:latest

# 6. Check logs (wait for ">> Darghos server Online!")
docker logs -f darghos-server
```

**Connect:**
- **IP**: Your local IP (e.g., `192.168.1.119`)
- **Port**: `7171`
- **Username**: `test` / **Password**: `test`

---

## Azure Setup (Production)

### Prerequisites
- Azure CLI installed and logged in (`az login`)
- Azure subscription with a resource group

### Deployment Steps

```bash
# 1. Set variables (replace with your values)
RESOURCE_GROUP="your-resource-group"
ACR_NAME="your-acr-name"
LOCATION="francecentral"

# 2. Create Azure Container Registry
az acr create --name $ACR_NAME --resource-group $RESOURCE_GROUP --sku Basic --location $LOCATION
az acr login --name $ACR_NAME

# 3. Build and push images (from macOS, use --platform linux/amd64)
docker build --platform linux/amd64 -f Dockerfile.production -t $ACR_NAME.azurecr.io/darghos-server:latest .
docker push $ACR_NAME.azurecr.io/darghos-server:latest

# 4. Create Azure Storage for config persistence
az storage account create --name ${ACR_NAME}storage --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS
STORAGE_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name ${ACR_NAME}storage --query "[0].value" -o tsv)
az storage share create --name darghos-config --account-name ${ACR_NAME}storage --account-key "$STORAGE_KEY"

# 5. Deploy MySQL container
az container create \
  --resource-group $RESOURCE_GROUP \
  --name darghos-mysql \
  --image mysql:8.0 \
  --dns-name-label darghos-mysql-${USER} \
  --ports 3306 \
  --cpu 2 --memory 4 \
  -e MYSQL_ROOT_PASSWORD=darghos123 MYSQL_DATABASE=darghos \
  --restart-policy Always \
  --location $LOCATION

# 6. Wait 30 seconds, then import database
sleep 30
docker run --rm -i mysql:8.0 mysql -h darghos-mysql-${USER}.${LOCATION}.azurecontainer.io -uroot -pdarghos123 darghos < darghos-clean-backup.sql

# 7. Import admin accounts (optional - creates bruno, ninao, yves accounts)
cat create-admin-accounts.sql | docker run --rm -i mysql:8.0 mysql -h darghos-mysql-${USER}.${LOCATION}.azurecontainer.io -uroot -pdarghos123 darghos

# 8. Deploy TFS server (note: Azure assigns new IP on each deployment)
ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)

az container create \
  --resource-group $RESOURCE_GROUP \
  --name darghos-tfs-server \
  --image $ACR_NAME.azurecr.io/darghos-server:latest \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password "$ACR_PASSWORD" \
  --dns-name-label darghos-${USER} \
  --ports 7171 7172 8080 \
  --cpu 4 --memory 16 \
  --azure-file-volume-account-name ${ACR_NAME}storage \
  --azure-file-volume-account-key "$STORAGE_KEY" \
  --azure-file-volume-share-name darghos-config \
  --azure-file-volume-mount-path /mnt/config \
  --restart-policy Always \
  --location $LOCATION

# 9. Get public IP and update config
PUBLIC_IP=$(az container show --resource-group $RESOURCE_GROUP --name darghos-tfs-server --query "ipAddress.ip" -o tsv)
echo "Server IP: $PUBLIC_IP"

# Update config.lua with correct IP and upload to Azure Files
# (See below for config update workflow)
```

### Update Config Without Redeployment

```bash
# 1. Edit config.lua locally (update 'ip' field)
# 2. Upload to Azure Files
az storage file delete --share-name darghos-config --path config.lua --account-name ${ACR_NAME}storage --account-key "$STORAGE_KEY"
az storage file upload --share-name darghos-config --source config.lua --path config.lua --account-name ${ACR_NAME}storage --account-key "$STORAGE_KEY"

# 3. Restart container (30 seconds)
az container restart --resource-group $RESOURCE_GROUP --name darghos-tfs-server
```

**Connect:**
- **FQDN**: `darghos-${USER}.${LOCATION}.azurecontainer.io`
- **Port**: `7171`
- **Username**: `test` / **Password**: `test`

**Important:** Azure Container Instances assign a new public IP on each redeployment. Use Azure Files to update `config.lua` without rebuilding containers.

### Azure Management Commands

```bash
# View TFS server logs
az container logs --resource-group $RESOURCE_GROUP --name darghos-tfs-server

# View MySQL logs
az container logs --resource-group $RESOURCE_GROUP --name darghos-mysql

# Check server status
az container show --resource-group $RESOURCE_GROUP --name darghos-tfs-server --query "{IP:ipAddress.ip, State:instanceView.state}"

# Restart TFS server (after config changes)
az container restart --resource-group $RESOURCE_GROUP --name darghos-tfs-server

# Stop containers
az container delete --resource-group $RESOURCE_GROUP --name darghos-tfs-server --yes
az container delete --resource-group $RESOURCE_GROUP --name darghos-mysql --yes

# List all containers
az container list --resource-group $RESOURCE_GROUP --output table
```

---

## Connection Details

**Test Account:**
- **Username**: `test` / **Password**: `test`
- **Characters**: Test Knight (lvl 8), Test Sorc (lvl 8), God Admin (lvl 500)

**Admin Accounts** (if you ran `create-admin-accounts.sql`):
- **Username**: `bruno` / **Password**: `bruno` → Bruno Knight, Bruno Sorc, GOD Bruno (lvl 500)
- **Username**: `ninao` / **Password**: `ninao` → Ninao Knight, Ninao Sorc, GOD Ninao (lvl 500)
- **Username**: `yves` / **Password**: `yves` → Yves Knight, Yves Sorc, GOD Yves (lvl 500)

**Database Access:**
- **Local**: `localhost:3306`
- **Azure**: `darghos-mysql-${USER}.${LOCATION}.azurecontainer.io:3306`
- **Database**: `darghos` / **User**: `root` / **Password**: `darghos123`

---

## Project Structure

```
DarghosTFS04_v4/
├── src/src/           # C++ source code (170+ files)
├── data/              # Game data (Lua scripts, XML configs, maps)
│   ├── actions/       # Action scripts
│   ├── creaturescripts/
│   ├── globalevents/
│   ├── monster/       # Monster definitions
│   └── world/         # Map files (.otbm)
├── Dockerfile.production  # Production Docker image
├── start-server.sh    # Runtime configuration script
└── docker-compose.yml # Development environment
```

---

## Key Features

- **Custom PvP System** - Darghos-specific PvP mechanics
- **Anti-DDoS Protection** - Emergency DDoS mitigation system
- **War System** - Guild wars and battlegrounds
- **5000x5000 Map** - Custom Darghos world
- **Inquisition Bosses** - Ushuriel, Madareth, Zugurosh, Latrivan, Golgordan, Annihilon, Hellgorak
- **Kashmir Quest System** - Custom quest mechanics

---

## Configuration

The server uses environment variables for configuration. See [CONFIG-ENVIRONMENT-VARIABLES.md](CONFIG-ENVIRONMENT-VARIABLES.md) for all available options.

**Key environment variables:**
- `SERVER_IP` - Your host machine's IP address
- `MYSQL_HOST` - MySQL server hostname
- `RATE_EXPERIENCE`, `RATE_SKILL`, `RATE_MAGIC`, `RATE_LOOT` - Game rates
- `WORLD_TYPE` - PvP rules (`open`, `optional`, `hardcore`)

---

## Troubleshooting

**Server won't start:**
- Check MySQL is running: `docker ps | grep mysql`
- Verify database is imported: `docker exec darghos-mysql mysql -uroot -pdarghos123 -e "USE darghos; SELECT COUNT(*) FROM houses;"`
- Check logs: `docker logs darghos-server`

**Can't connect from client:**
- Verify your IP is correct in config
- Check ports are exposed: `docker ps | grep darghos-server`
- Test connectivity: `telnet YOUR_IP 7171`

**Container keeps restarting:**
- Check logs: `docker logs darghos-server`
- Verify MySQL connectivity from container
- See [DEVELOPMENT-HISTORY.md](DEVELOPMENT-HISTORY.md) for known issues

---

## Documentation

- **[DEVELOPMENT-HISTORY.md](DEVELOPMENT-HISTORY.md)** - Development journey and debugging history
- **[CONFIG-ENVIRONMENT-VARIABLES.md](CONFIG-ENVIRONMENT-VARIABLES.md)** - Runtime configuration reference
- **[2025-10-22-AZURE-DEPLOYMENT-SUCCESS.md](2025-10-22-AZURE-DEPLOYMENT-SUCCESS.md)** - Azure deployment guide
- **[CLAUDE.md](CLAUDE.md)** - Project architecture and guidelines for Claude Code

---

## Technology Stack

- **Language**: C++ (pre-C++11)
- **Build System**: CMake
- **Database**: MySQL 8.0 with `mysql_native_password`
- **Scripting**: Lua 5.1
- **Libraries**: Boost, LibXML2, OpenSSL, ZLIB
- **Container**: Debian 9 (Stretch) with GCC 6.3

---

## License

This is a private Darghos server project based on The Forgotten Server 0.4.

---

**Server Status**: ✅ Fully operational - Ready for local development and Azure deployment
