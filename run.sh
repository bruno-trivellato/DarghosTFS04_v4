#!/bin/bash

echo "Starting Darghos TFS Server..."

# Start all services
echo "Starting all services..."
docker-compose up -d

# Wait a moment for containers to start
sleep 3

# Check if TFS executable exists in the container and run it
echo "Server starting... Press Ctrl+C to stop watching logs."
echo "You can connect to the server on localhost:7171"
echo ""

# Run the TFS server in the container
docker exec -d darghos-server bash -c "cd /app && echo 'y' | ./tfs"

# Show logs
docker-compose logs -f darghos