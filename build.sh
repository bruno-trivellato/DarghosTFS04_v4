#!/bin/bash

echo "Building Darghos TFS Server..."

# Build Docker image
echo "Building Docker image..."
docker-compose build

# Start MySQL container first
echo "Starting MySQL container..."
docker-compose up -d mysql

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
sleep 10

# Start the main container and compile
echo "Starting compilation container..."
docker-compose run --rm darghos bash -c "
    cd /app/src
    mkdir -p build
    cd build
    echo 'Running CMake...'
    cmake ..
    echo 'Compiling with make...'
    make -j\$(nproc)
    echo 'Build complete!'
    if [ -f tfs ]; then
        echo 'TFS executable created successfully!'
        echo 'Copying TFS executable to root directory...'
        cp tfs /app/tfs
        chmod +x /app/tfs
        echo 'TFS executable copied to /app/tfs'
    else
        echo 'Build failed - no executable found'
    fi
"

echo "Build process finished. Check output above for any errors."