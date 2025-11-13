# PepMapViz Docker Deployment

This directory contains Docker configuration files to run the PepMapViz Shiny application in a containerized environment.

## Quick Start

### Option 1: Using Docker Compose (Recommended)

```bash
# Build and run the container
docker-compose up --build

# Run in detached mode (background)
docker-compose up -d --build

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

### Option 2: Using Docker directly

```bash
# Build the image
docker build -t pepmapviz:latest .

# Run the container
docker run -d \
  --name pepmapviz-app \
  -p 3838:3838 \
  pepmapviz:latest

# View logs
docker logs -f pepmapviz-app

# Stop and remove the container
docker stop pepmapviz-app
docker rm pepmapviz-app
```

## Accessing the Application

Once the container is running, open your web browser and navigate to:
- **Local machine**: http://localhost:3838
- **Remote server**: http://YOUR_SERVER_IP:3838

## Configuration

### Port Mapping
- The default port is 3838
- To use a different port, change the port mapping: `-p YOUR_PORT:3838`

### Data Volumes
To persist uploaded data or provide pre-loaded datasets:

```bash
# Create a data directory
mkdir -p ./data

# Run with data volume mounted
docker run -d \
  --name pepmapviz-app \
  -p 3838:3838 \
  -v $(pwd)/data:/srv/shiny-server/data:ro \
  pepmapviz:latest
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `SHINY_LOG_STDERR` | `1` | Enable logging to stderr |

## System Requirements

### Minimum Requirements
- **CPU**: 1 core
- **Memory**: 2GB RAM
- **Storage**: 2GB free space
- **Docker**: Version 20.10+
- **Docker Compose**: Version 2.0+

### Recommended Requirements
- **CPU**: 2+ cores
- **Memory**: 4GB+ RAM
- **Storage**: 5GB+ free space

## Troubleshooting

### Container won't start
```bash
# Check container logs
docker logs pepmapviz-app

# Check if port is already in use
netstat -tlnp | grep :3838
```

### Application not accessible
1. Verify the container is running: `docker ps`
2. Check port mapping is correct
3. Ensure firewall allows port 3838
4. Check application logs: `docker logs pepmapviz-app`

### Performance issues
1. Increase container memory limit:
   ```bash
   docker run -d --memory="4g" --name pepmapviz-app -p 3838:3838 pepmapviz:latest
   ```
2. Monitor resource usage: `docker stats pepmapviz-app`

## Security Considerations

### Production Deployment
1. **Use HTTPS**: Configure a reverse proxy (nginx/Apache) with SSL
2. **Authentication**: Implement user authentication
3. **Network Security**: Use Docker networks and limit exposed ports
4. **Resource Limits**: Set memory and CPU limits
5. **Updates**: Regularly update the base image and dependencies

### Example production setup with nginx
```yaml
version: '3.8'
services:
  pepmapviz:
    build: .
    expose:
      - "3838"
    environment:
      - SHINY_LOG_STDERR=1
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - pepmapviz
```

## Building for Different Architectures

### For Apple Silicon (M1/M2) Macs
```bash
docker buildx build --platform linux/amd64,linux/arm64 -t pepmapviz:latest .
```

### For specific architecture
```bash
# AMD64 (Intel/AMD)
docker build --platform linux/amd64 -t pepmapviz:amd64 .

# ARM64 (Apple Silicon, ARM servers)
docker build --platform linux/arm64 -t pepmapviz:arm64 .
```

## Updates and Maintenance

### Updating the application
```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose down
docker-compose up --build -d
```

### Cleaning up Docker resources
```bash
# Remove unused images
docker image prune

# Remove unused containers and networks
docker system prune
```

## Support

For issues specific to the Docker deployment, check:
1. Container logs: `docker logs pepmapviz-app`
2. System resources: `docker stats`
3. Docker version compatibility
4. Network connectivity

For application-specific issues, refer to the main PepMapViz documentation.