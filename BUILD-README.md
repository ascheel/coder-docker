# Building and Maintaining the Custom Docker Image

## Quick Start

### Build Locally
```bash
# Build with latest Coder version
./build.sh

# Build with specific Coder version
./build.sh v2.27.7
```

### Update Version (Template + Image)
```bash
# Update coder.xml and build new image
./update-version-docker.sh v2.27.7
```

## File Structure

```
.
├── Dockerfile                    # Custom image definition
├── entrypoint-wrapper.sh        # Auto-import entrypoint
├── docker-workspace.tf          # Terraform template (bundled in image)
├── import-template.sh           # Template import script (bundled in image)
├── build.sh                     # Local build script
├── update-version-docker.sh     # Version update script
├── .dockerignore                # Files to exclude from build
└── .github/workflows/
    └── build-image.yml          # GitHub Actions CI/CD
```

## How It Works

1. **Dockerfile** extends official Coder image
2. **Bundles** template files and import script
3. **Entrypoint wrapper** starts Coder and auto-imports template
4. **Result**: Zero-configuration template import

## Building

### Prerequisites
- Docker installed
- All required files in repository

### Local Build
```bash
./build.sh v2.27.7
```

### Manual Build
```bash
docker build \
  --build-arg CODER_VERSION=v2.27.7 \
  -t ghcr.io/ascheel/coder-unraid:v2.27.7 \
  .
```

## Publishing

### GitHub Container Registry

1. **Authenticate**:
   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
   ```

2. **Push**:
   ```bash
   docker push ghcr.io/ascheel/coder-unraid:v2.27.7
   docker push ghcr.io/ascheel/coder-unraid:latest
   ```

### GitHub Actions (Automatic)

The workflow automatically:
- Builds on push to `main`
- Builds on version tags (e.g., `v2.27.7`)
- Pushes to `ghcr.io/ascheel/coder-unraid`

## Version Management

### Update to New Coder Version

```bash
# This updates coder.xml AND builds the image
./update-version-docker.sh v2.27.8
```

### Development Versions

```bash
# Build development version
./update-version-docker.sh v2.27.7-dev.1
```

## Testing

```bash
# Test the image locally
docker run -d \
  --name coder-test \
  -p 7080:7080 \
  -v /tmp/coder-data:/home/coder/.config \
  ghcr.io/ascheel/coder-unraid:latest

# Check logs
docker logs -f coder-test

# Verify template
docker exec coder-test coder templates list
```

## Maintenance

### When Coder Releases New Version

1. Run: `./update-version-docker.sh v2.28.0`
2. Test the image
3. Push to registry (or let GitHub Actions handle it)
4. Update repository

### Updating the Template

1. Edit `docker-workspace.tf`
2. Rebuild: `./build.sh`
3. Test and push

## Troubleshooting

### Build fails
- Check Dockerfile syntax
- Verify all files exist
- Check base image is accessible

### Template not importing
- Check container logs
- Verify files in image: `docker exec coder ls -la /home/coder/templates/`
- Check Coder API accessibility

## See Also

- [DOCKER-IMAGE.md](DOCKER-IMAGE.md) - Detailed image documentation
- [VERSIONING.md](VERSIONING.md) - Version management guide

