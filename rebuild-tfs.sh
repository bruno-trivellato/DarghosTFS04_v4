#!/bin/bash
# Quick rebuild script - only recompiles changed files

echo "🔨 Incremental TFS rebuild..."

# Copy updated source into container
docker cp src/src/game.cpp darghos-server:/app/src/src/game.cpp
docker cp src/src/game.h darghos-server:/app/src/src/game.h

# Rebuild inside container (incremental - only changed files)
docker exec darghos-server bash -c "cd /app/src/build-amd64 && make -j4 && cp tfs /app/tfs-debug-new && echo '✅ Build complete!'"

# Stop TFS process and start new one
docker exec darghos-server pkill tfs || true
sleep 2

echo "🚀 Starting new TFS binary..."
docker exec -d darghos-server bash -c "cd /app && echo 'y' | /app/tfs-debug-new"

echo "✅ Server restarted with new binary!"
echo "📋 Watch logs: docker logs -f darghos-server"
