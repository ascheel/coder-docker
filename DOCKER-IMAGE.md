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
./build.sh v2.28.5

# Build and tag as specific version
./build.sh v2.28.5 v2.28.5
```

### Manual Build

```bash
# Build with latest Coder
docker build -t ghcr.io/ascheel/coder-unraid:latest .

# Build with specific Coder version
docker build \
  --build-arg CODER_VERSION=v2.28.5 \
  -t ghcr.io/ascheel/coder-unraid:v2.28.5 \
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
- `ghcr.io/ascheel/coder-unraid:v2.28.5` → Based on Coder v2.28.5
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

The repository includes a GitHub Actions workflow (`.github/workflows/build-docker-image.yml`) that builds and pushes the Docker image to GitHub Container Registry.

### Features

- **Manual dispatch only** - Builds only when manually triggered
- **Version selection** - Specify Coder version or use `latest`
- **Automatic tagging** - Creates version-specific tag and updates `latest`
- **amd64 platform** - Builds for linux/amd64 architecture
- **Free for public repos** - No charges for GitHub Actions on public repositories

### Setting Up GitHub Actions

1. **Enable GitHub Container Registry**:
   - Go to repository Settings → Actions → General
   - Ensure "Read and write permissions" is enabled
   - This allows the workflow to push images to `ghcr.io`

2. **No additional secrets needed**:
   - The workflow uses `GITHUB_TOKEN` automatically provided by GitHub Actions
   - No manual authentication setup required

### Manual Workflow Trigger

1. Go to the **Actions** tab in your GitHub repository
2. Select **"Build and Push Docker Image"** workflow from the left sidebar
3. Click **"Run workflow"** button
4. Optionally specify a Coder version:
   - Leave empty or enter `latest` to build from the latest Coder image
   - Enter a specific version like `v2.28.5` to build from that version
5. Click **"Run workflow"** to start the build

The workflow will:
- Build the Docker image with the specified Coder version
- Tag it with the version (or `latest` if not specified)
- Also tag it as `latest` (unless version was already `latest`)
- Push both tags to `ghcr.io/ascheel/coder-unraid`

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
   ./build.sh v2.28.5 v2.28.5
   docker push ghcr.io/ascheel/coder-unraid:v2.28.5
   docker push ghcr.io/ascheel/coder-unraid:latest
   ```

### Using GitHub Actions (Recommended)

The GitHub Actions workflow handles building and pushing. Simply trigger it manually from the Actions tab when you need to build a new image.

## Image Tags

- `latest` - Always points to the most recent build
- `v2.28.5` - Specific Coder version
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

