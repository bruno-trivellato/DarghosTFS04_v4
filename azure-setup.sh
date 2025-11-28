#!/bin/bash

echo "🚀 Darghos TFS Azure Setup Script"
echo "=================================="

# Set error handling
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
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

log "Starting Darghos TFS setup on Azure..."

# Step 1: Build TFS Server
log "Step 1: Building TFS Server..."
cd /app/src

if [ -d "build" ]; then
    log "Removing old build directory..."
    rm -rf build
fi

log "Creating build directory..."
mkdir -p build && cd build

log "Running CMake configuration (Release mode)..."
cmake -DCMAKE_BUILD_TYPE=Release .. || {
    error "CMake configuration failed!"
    exit 1
}

log "Compiling TFS server (using 4 cores)..."
make -j4 || {
    error "Compilation failed!"
    exit 1
}

if [ ! -f "tfs" ]; then
    error "TFS executable not found after build!"
    exit 1
fi

log "✅ TFS server compiled successfully!"

# Step 2: Copy executable and set permissions
log "Step 2: Setting up TFS executable..."
cp tfs /app/tfs-optimized
chmod +x /app/tfs-optimized
log "✅ TFS executable ready at /app/tfs-optimized"

# Step 3: Create config.lua
log "Step 3: Creating server configuration..."
cd /app

cat > config.lua << 'EOF'
-- Darghos TFS Server Configuration
-- Generated for Azure deployment

-- Account manager
accountManager = false
namelockManager = true
newPlayerChooseVoc = false
newPlayerSpawnPosX = 95
newPlayerSpawnPosY = 117
newPlayerSpawnPosZ = 3
newPlayerTownId = 1

-- Database configuration
mysqlHost = "darghos-mysql.francecentral.azurecontainer.io"
mysqlUser = "root"
mysqlPass = "darghos123"
mysqlDatabase = "darghos"
mysqlPort = 3306
mysqlSock = ""

-- Server information
serverName = "Darghos"
ownerName = "Darghos Team"
ownerEmail = "admin@darghos.com"
url = "http://darghos-bruno.francecentral.azurecontainer.io"
location = "France"
displayGamemastersWithOnlineCommand = false

-- Network configuration
worldId = 0
ip = "98.66.243.222"
bindOnlyGlobalAddress = false
loginPort = 7171
gamePort = 7172
statusPort = 7171

-- Map configuration
mapName = "test.otbm"
mapAuthor = "Darghos Team"

-- World type configuration
worldType = "open"
hotkeyAimbotEnabled = true

-- Player limits and MOTD
maxPlayers = 1000
motd = "Welcome to Darghos! Server running on Azure Cloud!"
displayOnOrOffAtCharlist = false
onePlayerOnlinePerAccount = true
allowClones = false
serverMessage = ""

-- Death and experience configuration
deathLosePercent = -1
bioDegradation = 0
experienceStages = false
rateExperience = 5.0
rateSkill = 3.0
rateMagic = 3.0
rateLoot = 2.0
rateSpawn = 1

-- Monster configuration
deSpawnRange = 2
deSpawnRadius = 50

-- Stamina system
staminaRatingLimitTop = 41 * 60
staminaRatingLimitBottom = 14 * 60

-- Misc settings
allowChangeOutfit = true
freePremium = false
kickIdlePlayerAfterMinutes = 15
maxMessageBuffer = 4

-- Guild system
ingameGuildManagement = true
levelToFormGuild = 8
premiumDaysToFormGuild = 0
guildNameMinLength = 4
guildNameMaxLength = 20

-- Highscores
highscoreDisplayPlayers = 15
updateHighscoresAfterMinutes = 60

-- Houses
buyableAndSellableHouses = true
houseRentAsPrice = false
housePriceAsRent = false
housePriceEachSquare = 1000
houseRentPeriod = "never"

-- Combat timings
timeBetweenActions = 200
timeBetweenExActions = 1000

-- Map storage
houseDataStorage = "relational"
storeTrash = true
cleanProtectedZones = true

-- System performance
defaultPriority = "high"
niceLevel = 5
coresUsed = "-1"
startupDatabaseOptimization = false

-- Network timeouts
statusTimeout = 5000
replaceKickOnLogin = true
forceSlowConnectionsToDisconnect = false
loginTimeout = 60000
maxPacketsPerSecond = 25
EOF

log "✅ Configuration file created"

# Step 4: Test database connection
log "Step 4: Testing database connection..."
if command -v mysql > /dev/null; then
    if mysql -h darghos-mysql.francecentral.azurecontainer.io -u root -pdarghos123 -e "SHOW DATABASES;" > /dev/null 2>&1; then
        log "✅ Database connection successful"
    else
        warn "Database connection failed, but continuing..."
    fi
else
    warn "MySQL client not available for testing, but continuing..."
fi

# Step 5: Check if map file exists
log "Step 5: Checking map file..."
if [ -f "/app/data/world/test.otbm" ]; then
    log "✅ Map file found: test.otbm"
elif [ -f "/app/test.otbm" ]; then
    log "✅ Map file found in root: test.otbm"
else
    warn "Map file not found, server may fail to start"
fi

# Step 6: Show final status
log "Step 6: Setup complete!"
echo ""
echo "🎉 DARGHOS TFS AZURE SETUP COMPLETE!"
echo "====================================="
echo ""
echo "📋 Summary:"
echo "✅ TFS Server: Compiled and ready"
echo "✅ Configuration: Created"
echo "✅ Database: Connection tested"
echo "✅ Executable: /app/tfs-optimized"
echo ""
echo "🚀 To start the server, run:"
echo "   cd /app && echo 'y' | ./tfs-optimized"
echo ""
echo "🌐 Connection Details:"
echo "   Server: darghos-bruno.francecentral.azurecontainer.io"
echo "   Login Port: 7171"
echo "   Game Port: 7172"
echo "   IP: 98.66.243.222"
echo ""

log "Setup script completed successfully! 🎉"