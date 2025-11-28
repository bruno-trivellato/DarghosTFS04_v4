#!/bin/bash
echo "🚀 Setting up Darghos TFS on Azure..."

# Build TFS
cd /app/src && rm -rf build && mkdir build && cd build
echo "Running CMake..."
cmake -DCMAKE_BUILD_TYPE=Release ..
echo "Building with make..."
make -j4
cp tfs /app/tfs-optimized && chmod +x /app/tfs-optimized

# Create config
cd /app
cat > config.lua << 'EOF'
mysqlHost = "darghos-mysql.francecentral.azurecontainer.io"
mysqlUser = "root"
mysqlPass = "darghos123"
mysqlDatabase = "darghos"
mysqlPort = 3306
serverName = "Darghos"
ip = "98.66.243.222"
loginPort = 7171
gamePort = 7172
mapName = "test.otbm"
worldType = "open"
maxPlayers = 1000
motd = "Welcome to Darghos on Azure!"
rateExperience = 5.0
rateSkill = 3.0
rateMagic = 3.0
rateLoot = 2.0
EOF

echo "✅ Setup complete! Run: cd /app && echo 'y' | ./tfs-optimized"