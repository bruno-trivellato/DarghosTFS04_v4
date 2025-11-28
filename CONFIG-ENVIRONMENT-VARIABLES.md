# TFS Server Environment Variables Configuration

**Date**: 2025-10-21
**Purpose**: Reference for all environment variables used by the TFS server startup script

---

## Overview

The TFS server now supports **runtime configuration** through environment variables. This means you can deploy the same Docker image with different configurations without rebuilding.

The `start-server.sh` script reads these environment variables at container startup and generates `config.lua` dynamically.

---

## Database Configuration

### MYSQL_HOST
- **Description**: MySQL server hostname or IP address
- **Default**: `darghos-mysql-bruno.francecentral.azurecontainer.io`
- **Example**: `MYSQL_HOST=darghos-mysql-bruno.francecentral.azurecontainer.io`

### MYSQL_USER
- **Description**: MySQL username for TFS server connection
- **Default**: `root`
- **Example**: `MYSQL_USER=darghos`

### MYSQL_PASS
- **Description**: MySQL password for TFS server connection
- **Default**: `darghos123`
- **Example**: `MYSQL_PASS=mySecurePassword123`
- **Security**: Consider using Azure Key Vault for production

### MYSQL_DATABASE
- **Description**: MySQL database name
- **Default**: `darghos`
- **Example**: `MYSQL_DATABASE=darghos_production`

### MYSQL_PORT
- **Description**: MySQL server port
- **Default**: `3306`
- **Example**: `MYSQL_PORT=3307`

---

## Server Identity Configuration

### SERVER_NAME
- **Description**: Server name displayed to players
- **Default**: `Darghos`
- **Example**: `SERVER_NAME=Darghos Test Server`

### OWNER_NAME
- **Description**: Server owner name
- **Default**: `Darghos Team`
- **Example**: `OWNER_NAME=Bruno Trivellato`

### OWNER_EMAIL
- **Description**: Server owner contact email
- **Default**: `admin@darghos.com`
- **Example**: `OWNER_EMAIL=support@example.com`

### SERVER_URL
- **Description**: Server website URL
- **Default**: `http://darghos-bruno.francecentral.azurecontainer.io`
- **Example**: `SERVER_URL=https://darghos.com`

### SERVER_LOCATION
- **Description**: Server geographical location
- **Default**: `France`
- **Example**: `SERVER_LOCATION=Brazil`

---

## Network Configuration

### SERVER_IP
- **Description**: Server IP address for client connections
- **Default**: `0.0.0.0` (binds to all interfaces)
- **Example**: `SERVER_IP=4.178.239.245`
- **Note**: Using `0.0.0.0` is recommended for Azure containers

### LOGIN_PORT
- **Description**: Port for login server
- **Default**: `7171`
- **Example**: `LOGIN_PORT=7171`

### GAME_PORT
- **Description**: Port for game server
- **Default**: `7172`
- **Example**: `GAME_PORT=7172`

### STATUS_PORT
- **Description**: Port for status queries
- **Default**: `7171`
- **Example**: `STATUS_PORT=7171`

---

## Map Configuration

### MAP_NAME
- **Description**: Map file name (must exist in /app/data/world/)
- **Default**: `test.otbm`
- **Example**: `MAP_NAME=darghos-world.otbm`

### MAP_AUTHOR
- **Description**: Map creator name
- **Default**: `Darghos Team`
- **Example**: `MAP_AUTHOR=Custom Maps`

---

## Game Rules Configuration

### WORLD_TYPE
- **Description**: PvP rules type
- **Default**: `open`
- **Options**: `pvp`, `no-pvp`, `open`
- **Example**: `WORLD_TYPE=pvp`

### MAX_PLAYERS
- **Description**: Maximum concurrent players
- **Default**: `1000`
- **Example**: `MAX_PLAYERS=500`

### MOTD
- **Description**: Message of the day shown at login
- **Default**: `Welcome to Darghos! Server running on Azure Cloud!`
- **Example**: `MOTD=Welcome to Darghos - Now with 2x XP event!`

---

## Experience & Rates Configuration

### RATE_EXPERIENCE
- **Description**: Experience gain multiplier
- **Default**: `5.0`
- **Example**: `RATE_EXPERIENCE=10.0`

### RATE_SKILL
- **Description**: Skill advancement multiplier
- **Default**: `3.0`
- **Example**: `RATE_SKILL=5.0`

### RATE_MAGIC
- **Description**: Magic level advancement multiplier
- **Default**: `3.0`
- **Example**: `RATE_MAGIC=5.0`

### RATE_LOOT
- **Description**: Loot drop rate multiplier
- **Default**: `2.0`
- **Example**: `RATE_LOOT=3.0`

---

## TFS Executable Configuration

### TFS_EXECUTABLE
- **Description**: Path to TFS executable to run
- **Default**: `/app/tfs-debug`
- **Options**:
  - `/app/tfs-debug` - Debug build with verbose logging
  - `/app/tfs-optimized` - Release build for performance
- **Example**: `TFS_EXECUTABLE=/app/tfs-optimized`

---

## Docker Compose Local Development

You can also use these variables with docker-compose:

```yaml
version: '3.8'

services:
  darghos:
    build:
      context: .
      dockerfile: Dockerfile.production
    environment:
      MYSQL_HOST: darghos-mysql
      MYSQL_USER: root
      MYSQL_PASS: darghos123
      MYSQL_DATABASE: darghos
      SERVER_NAME: "Darghos Local Dev"
      RATE_EXPERIENCE: 100.0  # Fast testing
      TFS_EXECUTABLE: /app/tfs-debug
    ports:
      - "7171:7171"
      - "7172:7172"
      - "8080:8080"
```

---

## Configuration Priority

When the container starts, configuration is loaded in this order:

1. **Environment variables** (highest priority)
2. **Default values** in `start-server.sh`

This means environment variables always override defaults.

---

## Verifying Configuration

To see the generated config.lua:

```bash
# Connect to container
az container exec --resource-group Bruno-outros --name darghos-tfs-server --exec-command /bin/bash

# View generated config
cat /app/config.lua
```

The config file includes a timestamp showing when it was generated:
```lua
-- Darghos TFS Server Configuration
-- Generated automatically at runtime from environment variables
-- Tue Oct 21 19:30:45 UTC 2025
```

---

## Security Best Practices

### Don't Hardcode Secrets

❌ **Bad**:
```bash
--environment-variables \
  MYSQL_PASS=SuperSecretPassword123
```

✅ **Good** (use Azure Key Vault):
```bash
MYSQL_PASSWORD=$(az keyvault secret show --vault-name MyKeyVault --name mysql-password --query value -o tsv)

--environment-variables \
  MYSQL_PASS="$MYSQL_PASSWORD"
```

### Use Secure Variables for Sensitive Data

Azure Container Instances supports secure environment variables that are not displayed in logs:

```bash
az container create \
  # ... (standard params)
  --secure-environment-variables \
    MYSQL_PASS=SecretPassword123
```

---