#!/bin/bash

echo "Starting Darghos TFS Server..."

# Check if tfs executable exists
if [ ! -f "./src/build/tfs" ]; then
    echo "TFS executable not found. Please run ./build.sh first."
    exit 1
fi

# Start all services
echo "Starting all services..."
docker-compose up -d

# Show logs
echo "Server starting... Press Ctrl+C to stop watching logs."
echo "You can connect to the server on localhost:7171"
echo ""
docker-compose logs -f darghos