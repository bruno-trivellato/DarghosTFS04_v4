#!/bin/bash
# Darghos TFS Server Startup Script
# Generates config.lua from environment variables at runtime
# This allows flexible configuration without rebuilding the Docker image

set -e

echo "========================================="
echo "Darghos TFS Server - Startup Script"
echo "========================================="
echo ""

# Default values (can be overridden with environment variables)
MYSQL_HOST="${MYSQL_HOST:-darghos-mysql-bruno.francecentral.azurecontainer.io}"
MYSQL_USER="${MYSQL_USER:-root}"
MYSQL_PASS="${MYSQL_PASS:-darghos123}"
MYSQL_DATABASE="${MYSQL_DATABASE:-darghos}"
MYSQL_PORT="${MYSQL_PORT:-3306}"

SERVER_NAME="${SERVER_NAME:-Darghos}"
OWNER_NAME="${OWNER_NAME:-Darghos Team}"
OWNER_EMAIL="${OWNER_EMAIL:-admin@darghos.com}"
SERVER_URL="${SERVER_URL:-http://darghos-bruno.francecentral.azurecontainer.io}"
SERVER_LOCATION="${SERVER_LOCATION:-France}"

# Network configuration
LOGIN_PORT="${LOGIN_PORT:-7171}"
GAME_PORT="${GAME_PORT:-7172}"
STATUS_PORT="${STATUS_PORT:-7171}"
ADMIN_PORT="${ADMIN_PORT:-7171}"

# Auto-detect public IP if not provided
if [ -z "$SERVER_IP" ]; then
    echo "Detecting public IP address..."
    # Try to get from Azure metadata service
    DETECTED_IP=$(curl -s -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text" 2>/dev/null || echo "")

    if [ -z "$DETECTED_IP" ]; then
        # Fallback to eth0 IP
        DETECTED_IP=$(ip addr show eth0 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1 | head -1)
    fi

    if [ -n "$DETECTED_IP" ]; then
        SERVER_IP="$DETECTED_IP"
        echo "  Detected IP: $SERVER_IP"
    else
        SERVER_IP="0.0.0.0"
        echo "  WARNING: Could not detect public IP, using 0.0.0.0"
    fi
else
    echo "Using configured IP: $SERVER_IP"
fi

# Map configuration
MAP_NAME="${MAP_NAME:-test.otbm}"
MAP_AUTHOR="${MAP_AUTHOR:-Darghos Team}"

# Game configuration
WORLD_TYPE="${WORLD_TYPE:-open}"
MAX_PLAYERS="${MAX_PLAYERS:-1000}"
MOTD="${MOTD:-Welcome to Darghos! Server running on Azure Cloud!}"

# Rate configuration
RATE_EXPERIENCE="${RATE_EXPERIENCE:-5.0}"
RATE_SKILL="${RATE_SKILL:-3.0}"
RATE_MAGIC="${RATE_MAGIC:-3.0}"
RATE_LOOT="${RATE_LOOT:-2.0}"

# TFS executable to use
TFS_EXECUTABLE="${TFS_EXECUTABLE:-/app/tfs-debug}"

# New player configuration
NEW_PLAYER_LEVEL="${NEW_PLAYER_LEVEL:-1}"
NEW_PLAYER_MAGIC_LEVEL="${NEW_PLAYER_MAGIC_LEVEL:-0}"
GENERATE_ACCOUNT_NUMBER="${GENERATE_ACCOUNT_NUMBER:-false}"

# Death configuration
DEATH_LOST_PERCENT="${DEATH_LOST_PERCENT:-10}"

# Frag system configuration
DAILY_FRAGS_TO_KICK="${DAILY_FRAGS_TO_KICK:-40}"
WEEKLY_FRAGS_TO_KICK="${WEEKLY_FRAGS_TO_KICK:-80}"
MONTHLY_FRAGS_TO_KICK="${MONTHLY_FRAGS_TO_KICK:-160}"
DAILY_FRAGS_TO_BANISHMENT="${DAILY_FRAGS_TO_BANISHMENT:-80}"
WEEKLY_FRAGS_TO_BANISHMENT="${WEEKLY_FRAGS_TO_BANISHMENT:-160}"
MONTHLY_FRAGS_TO_BANISHMENT="${MONTHLY_FRAGS_TO_BANISHMENT:-320}"

# DDOS Emergency configuration (CRITICAL - was part of original fix)
DDOS_EMERGENCY_PUBLIC_IFACE="${DDOS_EMERGENCY_PUBLIC_IFACE:-eth0}"

# Logging configuration
ADMIN_LOGS_ENABLED="${ADMIN_LOGS_ENABLED:-false}"
DISPLAY_PLAYERS_LOGGING="${DISPLAY_PLAYERS_LOGGING:-true}"
PREFIX_CHANNEL_LOGS="${PREFIX_CHANNEL_LOGS:-false}"
OUTPUT_LOG="${OUTPUT_LOG:-}"
TRUNCATE_LOGS_ON_STARTUP="${TRUNCATE_LOGS_ON_STARTUP:-false}"

# Database optimization
OPTIMIZE_DATABASE_AT_STARTUP="${OPTIMIZE_DATABASE_AT_STARTUP:-false}"
SQL_KEEP_ALIVE="${SQL_KEEP_ALIVE:-0}"

# Misc configuration
MAXIMUM_DOOR_LEVEL="${MAXIMUM_DOOR_LEVEL:-500}"
REMOVE_PREMIUM_ON_INIT="${REMOVE_PREMIUM_ON_INIT:-true}"
CONFIRM_OUTDATED_VERSION="${CONFIRM_OUTDATED_VERSION:-false}"
RUN_FILE="${RUN_FILE:-}"

echo "Configuration:"
echo "  MySQL: $MYSQL_USER@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE"
echo "  Server: $SERVER_NAME"
echo "  Ports: Login=$LOGIN_PORT, Game=$GAME_PORT"
echo "  Executable: $TFS_EXECUTABLE"
echo ""

# Check if TFS executable exists
if [ ! -f "$TFS_EXECUTABLE" ]; then
    echo "ERROR: TFS executable not found at $TFS_EXECUTABLE"
    echo "Available TFS executables:"
    ls -lah /app/tfs* 2>/dev/null || echo "  No TFS executables found!"
    exit 1
fi

# Generate config.lua
echo "Generating config.lua from environment variables..."
cat > /app/config.lua << EOF
-- Darghos TFS Server Configuration
-- Generated automatically at runtime from environment variables
-- $(date)

-- Account manager
accountManager = false
namelockManager = true
newPlayerChooseVoc = false
newPlayerSpawnPosX = 95
newPlayerSpawnPosY = 117
newPlayerSpawnPosZ = 3
newPlayerTownId = 1
newPlayerLevel = $NEW_PLAYER_LEVEL
newPlayerMagicLevel = $NEW_PLAYER_MAGIC_LEVEL
generateAccountNumber = $GENERATE_ACCOUNT_NUMBER

-- Database configuration
sqlType = "mysql"
sqlHost = "$MYSQL_HOST"
sqlPort = $MYSQL_PORT
sqlUser = "$MYSQL_USER"
sqlPass = "$MYSQL_PASS"
sqlDatabase = "$MYSQL_DATABASE"
sqlFile = ""
mysqlReadTimeout = 10
mysqlWriteTimeout = 10
sqlKeepAlive = $SQL_KEEP_ALIVE
optimizeDatabaseAtStartup = $OPTIMIZE_DATABASE_AT_STARTUP

-- Server information
serverName = "$SERVER_NAME"
ownerName = "$OWNER_NAME"
ownerEmail = "$OWNER_EMAIL"
url = "$SERVER_URL"
location = "$SERVER_LOCATION"
displayGamemastersWithOnlineCommand = false

-- Network configuration
worldId = 0
ip = "$SERVER_IP"
bindOnlyConfiguredIpAddress = false
loginPort = $LOGIN_PORT
gamePort = $GAME_PORT
adminPort = $ADMIN_PORT
statusPort = $STATUS_PORT
loginTries = 10
retryTimeout = 5 * 1000
loginTimeout = 60 * 1000

-- Map configuration
mapName = "$MAP_NAME"
mapAuthor = "$MAP_AUTHOR"

-- World type configuration
worldType = "$WORLD_TYPE"
hotkeyAimbotEnabled = true

-- Player limits and MOTD
maxPlayers = $MAX_PLAYERS
motd = "$MOTD"
displayOnOrOffAtCharlist = false
onePlayerOnlinePerAccount = true
allowClones = false
serverMessage = ""
loginMessage = "$MOTD"

-- PvP and Combat Configuration
protectionLevel = 1
pvpTileIgnoreLevelAndVocationProtection = true
pzLocked = 60 * 1000
huntingDuration = 60 * 1000
criticalHitChance = 7
criticalHitMultiplier = 1
displayCriticalHitNotify = false
removeWeaponAmmunition = true
removeWeaponCharges = true
removeRuneCharges = "no"
whiteSkullTime = 15 * 60 * 1000
noDamageToSameLookfeet = false
showHealingDamage = false
showHealingDamageForMonsters = false
fieldOwnershipDuration = 5 * 1000
stopAttackingAtExit = false
oldConditionAccuracy = false
loginProtectionPeriod = 10 * 1000
stairhopDelay = 2 * 1000
pushCreatureDelay = 2 * 1000
deathContainerId = 1987
gainExperienceColor = 215
addManaSpentInPvPZone = true
squareColor = 0
allowFightback = true

-- Skull System
redSkullLength = 1 * 24 * 60 * 60
blackSkullLength = 2 * 24 * 60 * 60
dailyFragsToRedSkull = 3
dailyFragsToBlackSkull = 5
weeklyFragsToRedSkull = 5
weeklyFragsToBlackSkull = 10
monthlyFragsToRedSkull = 10
monthlyFragsToBlackSkull = 20
blackSkulledDeathHealth = 40
blackSkulledDeathMana = 0
useBlackSkull = true
useFragHandler = true
advancedFragList = false
dailyFragsToKick = $DAILY_FRAGS_TO_KICK
weeklyFragsToKick = $WEEKLY_FRAGS_TO_KICK
monthlyFragsToKick = $MONTHLY_FRAGS_TO_KICK

-- Banishment
notationsToBan = 3
warningsToFinalBan = 4
warningsToDeletion = 5
banLength = 7 * 24 * 60 * 60
killsBanLength = 7 * 24 * 60 * 60
finalBanLength = 30 * 24 * 60 * 60
ipBanishmentLength = 1 * 24 * 60 * 60
dailyFragsToBanishment = $DAILY_FRAGS_TO_BANISHMENT
weeklyFragsToBanishment = $WEEKLY_FRAGS_TO_BANISHMENT
monthlyFragsToBanishment = $MONTHLY_FRAGS_TO_BANISHMENT
broadcastBanishments = true
maxViolationCommentSize = 200
violationNameReportActionType = 2
autoBanishUnknownBytes = false

-- Security
encryptionType = "sha1"
replaceKickOnLogin = true
forceSlowConnectionsToDisconnect = false
loginOnlyWithLoginServer = false
premiumPlayerSkipWaitList = false

-- Death and experience configuration
deathLosePercent = -1
deathLostPercent = $DEATH_LOST_PERCENT
bioDegradation = 0
experienceStages = false
rateExperience = $RATE_EXPERIENCE
rateSkill = $RATE_SKILL
rateMagic = $RATE_MAGIC
rateLoot = $RATE_LOOT
rateSpawn = 1

-- Monster configuration
deSpawnRange = 2
deSpawnRadius = 50

-- Death List
deathListEnabled = true
deathListRequiredTime = 1 * 60 * 1000
deathAssistCount = 19
maxDeathRecords = 5

-- Stamina system
rateStaminaLoss = 1
rateStaminaGain = 3
rateStaminaThresholdGain = 12
staminaRatingLimitTop = 41 * 60
staminaRatingLimitBottom = 14 * 60
rateStaminaAboveNormal = 1.5
rateStaminaUnderNormal = 0.5
staminaThresholdOnlyPremium = true

-- Party System
experienceShareRadiusX = 30
experienceShareRadiusY = 30
experienceShareRadiusZ = 1
experienceShareLevelDifference = 2 / 3
extraPartyExperienceLimit = 20
extraPartyExperiencePercent = 5
experienceShareActivity = 2 * 60 * 1000

-- Global Save
globalSaveEnabled = false
globalSaveHour = 8
shutdownAtGlobalSave = true
cleanMapAtGlobalSave = false

-- Summons
maxPlayerSummons = 2
teleportAllSummons = false
teleportPlayerSummons = false

-- Monster Rates
rateMonsterHealth = 1.0
rateMonsterMana = 1.0
rateMonsterAttack = 1.0
rateMonsterDefense = 1.0

-- Experience from Players
rateExperienceFromPlayers = 0
minLevelThresholdForKilledPlayer = 0.9
maxLevelThresholdForKilledPlayer = 1.1

-- Misc settings
allowChangeOutfit = true
allowChangeColors = true
allowChangeAddons = true
disableOutfitsForPrivilegedPlayers = false
addonsOnlyPremium = true
freePremium = false
kickIdlePlayerAfterMinutes = 15
maxMessageBuffer = 4
dataDirectory = "data/"
logsDirectory = "data/logs/"
bankSystem = true
displaySkillLevelOnAdvance = false
promptExceptionTraceback = true
separateViplistPerCharacter = false
maximumDoorLevel = $MAXIMUM_DOOR_LEVEL
maxItemsPerPZTile = 0

-- Logging configuration
adminLogsEnabled = $ADMIN_LOGS_ENABLED
displayPlayersLogging = $DISPLAY_PLAYERS_LOGGING
prefixChannelLogs = $PREFIX_CHANNEL_LOGS
outputLog = "$OUTPUT_LOG"
truncateLogsOnStartup = $TRUNCATE_LOGS_ON_STARTUP

-- DDOS Emergency (CRITICAL - prevents crashes)
ddosEmergencyPublicIface = "$DDOS_EMERGENCY_PUBLIC_IFACE"

-- Premium and misc
removePremiumOnInit = $REMOVE_PREMIUM_ON_INIT
confirmOutdatedVersion = $CONFIRM_OUTDATED_VERSION
runFile = "$RUN_FILE"

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
houseNeedPremium = true
bedsRequirePremium = true
levelToBuyHouse = 1
housesPerAccount = 0
houseRentAsPrice = false
housePriceAsRent = false
housePriceEachSquare = 1000
houseRentPeriod = "never"
houseCleanOld = 0
guildHalls = false

-- Combat and Item timings
timeBetweenActions = 200
timeBetweenExActions = 1000
checkCorpseOwner = true

-- Spells
formulaLevel = 5.0
formulaMagic = 1.0
bufferMutedOnSpellFailure = false
spellNameInsteadOfWords = false
emoteSpells = false

-- Map storage and configuration
randomizeTiles = true
useHouseDataStorage = false
houseDataStorage = "relational"
storeTrash = true
cleanProtectedZones = true
mailboxDisabledTowns = "-1"

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

echo "Config generated successfully!"
echo ""

# Verify map file exists
if [ ! -f "/app/data/world/$MAP_NAME" ] && [ ! -f "/app/$MAP_NAME" ]; then
    echo "WARNING: Map file '$MAP_NAME' not found in /app/data/world/ or /app/"
    echo "Server may fail to start. Available maps:"
    ls -la /app/data/world/*.otbm 2>/dev/null || echo "  No .otbm files found"
    echo ""
fi

# Test database connectivity and auto-import schema if needed
echo "Testing database connectivity..."
if command -v mysql > /dev/null 2>&1; then
    if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" -e "SELECT 1;" > /dev/null 2>&1; then
        echo "  Database connection: OK"

        # Check if database is empty (no tables)
        TABLE_COUNT=$(mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DATABASE" -sN -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$MYSQL_DATABASE';" 2>/dev/null || echo "0")

        if [ "$TABLE_COUNT" -eq "0" ]; then
            echo "  Database is empty - importing schema..."

            # Try to find schema file
            SCHEMA_FILE=""
            if [ -f "/app/src/schemas/mysql.sql" ]; then
                SCHEMA_FILE="/app/src/schemas/mysql.sql"
            elif [ -f "/app/schemas/mysql.sql" ]; then
                SCHEMA_FILE="/app/schemas/mysql.sql"
            fi

            if [ -n "$SCHEMA_FILE" ]; then
                echo "  Using schema: $SCHEMA_FILE"
                if mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" -p"$MYSQL_PASS" "$MYSQL_DATABASE" < "$SCHEMA_FILE" 2>&1 | head -10; then
                    echo "  ✓ Schema imported successfully!"
                else
                    echo "  ✗ Schema import failed - server may not start correctly"
                fi
            else
                echo "  WARNING: No schema file found at /app/src/schemas/mysql.sql or /app/schemas/mysql.sql"
                echo "  Server will likely fail to start with empty database"
            fi
        else
            echo "  Database has $TABLE_COUNT tables - schema already exists"
        fi
    else
        echo "  WARNING: Database connection failed (server will retry at startup)"
    fi
else
    echo "  Skipped (mysql client not available)"
fi
echo ""

# Change to app directory
cd /app

# Check if auto-start is disabled
AUTO_START="${AUTO_START:-true}"

if [ "$AUTO_START" = "false" ]; then
    echo "========================================="
    echo "Auto-start disabled (AUTO_START=false)"
    echo "========================================="
    echo ""
    echo "To start the server manually, run:"
    echo "  cd /app"
    echo "  $TFS_EXECUTABLE"
    echo ""
    echo "Or with auto-yes to root warning:"
    echo "  echo 'y' | $TFS_EXECUTABLE"
    echo ""
    echo "Keeping container alive - press Ctrl+C to exit"
    exec tail -f /dev/null
else
    # Start TFS server
    echo "========================================="
    echo "Starting TFS Server..."
    echo "========================================="
    echo ""
    echo "Executable: $TFS_EXECUTABLE"
    echo "Working directory: $(pwd)"
    echo ""

    # Auto-answer 'yes' to the root user warning
    # Using exec to replace shell process and ensure all output is captured
    # This makes TFS become PID 1 and all output goes directly to Docker logs
    exec bash -c "echo 'y' | $TFS_EXECUTABLE"
fi
