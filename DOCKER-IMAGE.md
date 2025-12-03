# Custom Docker Image for Coder unRAID

This repository includes a custom Docker image that extends the official Coder image with automatic template import functionality.

## Overview

The custom image (`ghcr.io/ascheel/coder-unraid`) includes:
- Official Coder server (from `ghcr.io/coder/coder`)
- Pre-bundled `docker-workspace.tf` template
- Automatic template import on first container start
- Entrypoint wrapper that handles initialization

## Building the Image

### Prerequisites

- Docker installed and running
- Access to GitHub Container Registry (for pushing)

### Local Build

```bash
# Build with latest Coder version
./build.sh

# Build with specific Coder version
./build.sh v2.27.7

# Build and tag as specific version
./build.sh v2.27.7 v2.27.7
```

### Manual Build

```bash
# Build with latest Coder
docker build -t ghcr.io/ascheel/coder-unraid:latest .

# Build with specific Coder version
docker build \
  --build-arg CODER_VERSION=v2.27.7 \
  -t ghcr.io/ascheel/coder-unraid:v2.27.7 \
  .
```

## Image Structure

```
/home/coder/
├── templates/
│   ├── docker-workspace.tf      # Terraform template
│   └── import-template.sh       # Import helper script
└── .config/                      # Coder data (mounted from host)

/usr/local/bin/
└── entrypoint-wrapper.sh         # Entrypoint that auto-imports templates
```

## How It Works

1. **Container starts** → Entrypoint wrapper runs
2. **Coder server starts** → Runs in background
3. **Wait for Coder** → Waits for API to be ready
4. **Import template** → Automatically imports `docker-workspace-unraid` template
5. **Continue running** → Coder server continues normally

## Version Management

### Matching Coder Versions

The image is tagged to match Coder versions:
- `ghcr.io/ascheel/coder-unraid:v2.27.7` → Based on Coder v2.27.7
- `ghcr.io/ascheel/coder-unraid:latest` → Based on latest Coder

### Updating for New Coder Version

1. **Update coder.xml** with new Coder version:
   ```xml
   <Repository>ghcr.io/ascheel/coder-unraid:v2.28.0</Repository>
   ```

2. **Build the image**:
   ```bash
   ./build.sh v2.28.0 v2.28.0
   ```

3. **Push to registry**:
   ```bash
   docker push ghcr.io/ascheel/coder-unraid:v2.28.0
   docker push ghcr.io/ascheel/coder-unraid:latest
   ```

4. **Update coder.xml** in repository and commit

## GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/build-image.yml`) that:
- Automatically builds on pushes to `main`
- Builds on version tags (e.g., `v2.27.7`)
- Pushes to GitHub Container Registry
- Supports manual workflow dispatch

### Setting Up GitHub Actions

1. **Enable GitHub Container Registry**:
   - Go to repository Settings → Actions → General
   - Ensure "Read and write permissions" is enabled

2. **Workflow will automatically**:
   - Build on push to main
   - Build on version tags
   - Push to `ghcr.io/ascheel/coder-unraid`

### Manual Workflow Trigger

1. Go to Actions → Build and Push Docker Image
2. Click "Run workflow"
3. Optionally specify Coder version
4. Run workflow

## Testing the Image

```bash
# Run the image locally
docker run -d \
  --name coder-test \
  -p 7080:7080 \
  -v /mnt/user/appdata/coder:/home/coder/.config \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  --group-add $(stat -c %g /var/run/docker.sock) \
  ghcr.io/ascheel/coder-unraid:latest

# Check logs
docker logs -f coder-test

# Verify template was imported
docker exec coder-test coder templates list
```

## Publishing to GitHub Container Registry

### First Time Setup

1. **Authenticate with GitHub**:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
   ```

2. **Build and push**:
   ```bash
   ./build.sh v2.27.7 v2.27.7
   docker push ghcr.io/ascheel/coder-unraid:v2.27.7
   docker push ghcr.io/ascheel/coder-unraid:latest
   ```

### Using GitHub Actions (Recommended)

The GitHub Actions workflow handles building and pushing automatically. Just push to the repository or create a tag.

## Image Tags

- `latest` - Always points to the most recent build
- `v2.27.7` - Specific Coder version
- `v2.27` - Major.minor version
- `main` - Build from main branch (development)

## Maintenance

### When Coder Releases a New Version

1. Update `coder.xml` with new version
2. Build new image: `./build.sh v2.28.0 v2.28.0`
3. Push to registry
4. Update repository

### Updating the Template

1. Edit `docker-workspace.tf`
2. Rebuild image: `./build.sh`
3. Push updated image

## Troubleshooting

### Image won't build
- Check Dockerfile syntax
- Verify all required files exist
- Check base image is accessible

### Template not importing
- Check container logs: `docker logs coder`
- Verify template file exists in image: `docker exec coder ls -la /home/coder/templates/`
- Check Coder API is accessible

### Image too large
- Review `.dockerignore` to exclude unnecessary files
- Use multi-stage builds if needed
- Optimize base image usage

## Security Considerations

- Image is based on official Coder image (trusted source)
- Only adds template files and wrapper script
- No additional dependencies or packages
- Regular updates recommended when Coder releases security patches

