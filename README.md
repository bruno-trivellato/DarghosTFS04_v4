# DarghosTFS04_v4

Darghos server based on The Forgotten Server (TFS) 0.4, used during Tibia version 8.6.

This repository contains all Darghos server changes from 2013 to 2017, before the implementation of the proprietary client.

---

## Quick Start - Running Locally with Docker

### Prerequisites
- Docker and Docker Compose installed
- 4GB+ RAM available
- Tibia 8.6 client or OTClient for testing

### Option 1: Using Production Image (Recommended - Fastest)

```bash
# 1. Start MySQL with complete database
docker run -d \
  --name darghos-mysql \
  -e MYSQL_ROOT_PASSWORD=darghos123 \
  -e MYSQL_DATABASE=darghos \
  -p 3306:3306 \
  mysql:8.0 \
  --default-authentication-plugin=mysql_native_password

# 2. Wait for MySQL to initialize
sleep 15

# 3. Import database (from project root)
docker exec -i darghos-mysql mysql -uroot -pdarghos123 darghos < darghos-clean-backup.sql

# 4. Get your host machine's IP address
ifconfig | grep "inet " | grep -v 127.0.0.1
# Example output: inet 192.168.1.119

# 5. Build and run TFS server
docker build -f Dockerfile.production -t darghos-server:latest .

docker run -d \
  --name darghos-server \
  --restart=unless-stopped \
  -p 7171:7171 \
  -p 7172:7172 \
  -p 8080:8080 \
  -e MYSQL_HOST=host.docker.internal \
  -e MYSQL_USER=root \
  -e MYSQL_PASS=darghos123 \
  -e SERVER_IP=192.168.1.119 \
  darghos-server:latest

# 6. Watch server startup
docker logs -f darghos-server

# Look for: ">> Darghos server Online!"
```

### Option 2: Using Docker Compose (Development)

```bash
# 1. Build containers
docker-compose up -d

# 2. Get your IP and update config
YOUR_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -1 | awk '{print $2}')
docker exec darghos-server sed -i "s/ip = \"127.0.0.1\"/ip = \"$YOUR_IP\"/" /app/config.lua

# 3. Compile TFS inside container
docker exec darghos-server bash -c "cd /app/src && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=Debug .. && make -j4 && cp tfs /app/tfs-debug"

# 4. Start server
docker exec -it darghos-server bash
# Inside container:
cd /app && ./tfs-debug
```

---

## Connection Details

Once the server is running, connect using a Tibia 8.6 client:

**Server Address:**
- **IP**: Your host machine's IP (e.g., `192.168.1.119`)
- **Port**: `7171`

**Test Account:**
- **Username**: `test`
- **Password**: `test`
- **Characters**:
  - `Test Knight` - Level 8 Knight
  - `Test Sorc` - Level 8 Sorcerer
  - `God Admin` - Level 500 Super Admin with full GM powers

**Database Access (DataGrip/MySQL Workbench):**
- **Host**: `localhost`
- **Port**: `3306`
- **Database**: `darghos`
- **User**: `root`
- **Password**: `darghos123`

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
