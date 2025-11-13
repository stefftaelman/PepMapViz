#!/bin/bash

# PepMapViz Docker Build and Test Script

set -e  # Exit on any error

echo "🐳 Building PepMapViz Docker container..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

print_status "Docker is running ✓"

# Build the image
print_status "Building PepMapViz Docker image..."
if docker build -t pepmapviz:latest .; then
    print_success "Docker image built successfully!"
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Check if port 3838 is available
if lsof -i :3838 > /dev/null 2>&1; then
    print_error "Port 3838 is already in use. Please stop any running services on this port."
    echo "You can check what's using the port with: lsof -i :3838"
    exit 1
fi

# Run the container
print_status "Starting PepMapViz container..."
CONTAINER_ID=$(docker run -d --name pepmapviz-test -p 3838:3838 pepmapviz:latest)

if [ $? -eq 0 ]; then
    print_success "Container started with ID: $CONTAINER_ID"
else
    print_error "Failed to start container"
    exit 1
fi

# Wait for the application to start
print_status "Waiting for application to start..."
sleep 10

# Test if the application is responding
print_status "Testing application health..."
for i in {1..30}; do
    if curl -f http://localhost:3838/ > /dev/null 2>&1; then
        print_success "PepMapViz is running and accessible!"
        print_success "🎉 Open your browser and go to: http://localhost:3838"
        break
    else
        if [ $i -eq 30 ]; then
            print_error "Application failed to start properly"
            echo "Container logs:"
            docker logs pepmapviz-test
            docker stop pepmapviz-test
            docker rm pepmapviz-test
            exit 1
        fi
        print_status "Waiting for app to be ready... (attempt $i/30)"
        sleep 2
    fi
done

echo
echo "🎯 Container Management Commands:"
echo "  View logs:        docker logs -f pepmapviz-test"
echo "  Stop container:   docker stop pepmapviz-test"
echo "  Remove container: docker rm pepmapviz-test"
echo "  Access app:       http://localhost:3838"
echo

echo "✅ PepMapViz is ready for use!"