#!/bin/bash

echo "Opening shell in Darghos container..."

# Start services if not running
docker-compose up -d

# Open interactive shell
docker-compose exec darghos /bin/bash