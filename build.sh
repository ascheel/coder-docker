#!/bin/bash
# build.sh - Build script for Coder unRAID Docker image
#
# Usage:
#   ./build.sh [version] [tag]
#
# Examples:
#   ./build.sh v2.27.7                    # Build with specific Coder version
#   ./build.sh v2.27.7 latest             # Build and tag as latest
#   ./build.sh                            # Build with latest Coder version

set -e

CODER_VERSION="${1:-latest}"
IMAGE_TAG="${2:-${CODER_VERSION}}"
IMAGE_NAME="ghcr.io/ascheel/coder-unraid"
FULL_IMAGE="${IMAGE_NAME}:${IMAGE_TAG}"

echo "=========================================="
echo "Building Coder unRAID Docker Image"
echo "=========================================="
echo "Base Coder version: ${CODER_VERSION}"
echo "Image tag: ${IMAGE_TAG}"
echo "Full image: ${FULL_IMAGE}"
echo ""

# Check if Docker is available
if ! command -v docker &> /dev/null; then
    echo "✗ Docker is not installed or not in PATH"
    exit 1
fi

# Check if required files exist
if [ ! -f "Dockerfile" ]; then
    echo "✗ Dockerfile not found"
    exit 1
fi

if [ ! -f "docker-workspace.tf" ]; then
    echo "✗ docker-workspace.tf not found"
    exit 1
fi

if [ ! -f "import-template.sh" ]; then
    echo "✗ import-template.sh not found"
    exit 1
fi

if [ ! -f "entrypoint-wrapper.sh" ]; then
    echo "✗ entrypoint-wrapper.sh not found"
    exit 1
fi

echo "✓ All required files found"
echo ""

# Build arguments
BUILD_ARGS="--build-arg CODER_VERSION=${CODER_VERSION}"

# Build the image
echo "Building Docker image..."
docker build \
    --build-arg CODER_VERSION="${CODER_VERSION}" \
    --tag "${FULL_IMAGE}" \
    --tag "${IMAGE_NAME}:latest" \
    .

if [ $? -eq 0 ]; then
    echo ""
    echo "=========================================="
    echo "✓ Build completed successfully!"
    echo "=========================================="
    echo ""
    echo "Image: ${FULL_IMAGE}"
    echo ""
    echo "Next steps:"
    echo "  1. Test the image:"
    echo "     docker run -d --name coder-test -p 7080:7080 ${FULL_IMAGE}"
    echo ""
    echo "  2. Push to registry (if authenticated):"
    echo "     docker push ${FULL_IMAGE}"
    echo "     docker push ${IMAGE_NAME}:latest"
    echo ""
else
    echo ""
    echo "✗ Build failed"
    exit 1
fi

