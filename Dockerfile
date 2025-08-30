# Debian 9 (Stretch) for full C++11 support
FROM debian:9

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Add archived Debian 9 repositories since it's EOL
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list && \
    echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/99no-check-valid-until

# Update package list and install essential build tools
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    wget \
    git \
    pkg-config

# Install required libraries for TFS/Darghos
RUN apt-get install -y \
    libboost-all-dev \
    libxml2-dev \
    libgmp-dev \
    libssl1.0-dev \
    liblua5.1-0-dev \
    default-libmysqlclient-dev \
    zlib1g-dev

# Clean up apt cache to reduce image size
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create working directory
WORKDIR /app

# Copy source code (will be mounted as volume in practice)
COPY . /app

# Create build directory
RUN mkdir -p build

# Set the default command
CMD ["/bin/bash"]