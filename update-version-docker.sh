#!/bin/bash
# update-version-docker.sh - Update template and Docker image to match a specific Coder version
#
# Usage: 
#   Development: ./update-version-docker.sh v2.28.5-dev.1
#   Stable:      ./update-version-docker.sh v2.28.5
#   With message: ./update-version-docker.sh v2.28.5-dev.1 "Fixed workspace creation bug"
#
# This script:
#   1. Updates coder.xml with new version
#   2. Builds Docker image for the new version
#   3. Optionally pushes to registry

set -e

NEW_VERSION=$1
COMMIT_MSG=$2
BUILD_IMAGE="${BUILD_IMAGE:-true}"
PUSH_IMAGE="${PUSH_IMAGE:-false}"

if [ -z "$NEW_VERSION" ]; then
  echo "Usage: $0 <version> [commit-message] [--no-build] [--push]"
  echo ""
  echo "Examples:"
  echo "  Development: $0 v2.28.5-dev.1"
  echo "  Stable:      $0 v2.28.5"
  echo "  With message: $0 v2.28.5-dev.1 'Fixed workspace creation bug'"
  echo "  No build:    $0 v2.28.5 '' --no-build"
  echo "  Build & push: $0 v2.28.5 '' --push"
  echo ""
  echo "Environment variables:"
  echo "  BUILD_IMAGE=false  - Skip Docker image build"
  echo "  PUSH_IMAGE=true     - Push image to registry after build"
  exit 1
fi

# Check for flags
for arg in "$@"; do
  case $arg in
    --no-build)
      BUILD_IMAGE=false
      shift
      ;;
    --push)
      PUSH_IMAGE=true
      shift
      ;;
  esac
done

# Validate version format
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-dev\.[0-9]+)?$ ]]; then
  echo "Error: Version must be in format:"
  echo "  - Stable: vX.Y.Z (e.g., v2.28.5)"
  echo "  - Development: vX.Y.Z-dev.N (e.g., v2.28.5-dev.1)"
  exit 1
fi

# Determine if this is a development or stable version
if [[ $NEW_VERSION =~ -dev\.[0-9]+$ ]]; then
  VERSION_TYPE="development"
  BASE_VERSION=$(echo $NEW_VERSION | sed 's/-dev\.[0-9]*$//')
  DEV_NUMBER=$(echo $NEW_VERSION | sed 's/.*-dev\.//')
else
  VERSION_TYPE="stable"
  BASE_VERSION=$NEW_VERSION
fi

# Extract version number without 'v' prefix for Docker image tag
DOCKER_TAG=$BASE_VERSION
VERSION_NUM=${BASE_VERSION#v}

echo "Updating to Coder ${NEW_VERSION}..."
echo "Version type: ${VERSION_TYPE}"
if [ "$VERSION_TYPE" = "development" ]; then
  echo "Docker image tag: ${DOCKER_TAG} (using base version)"
  echo "Development iteration: ${DEV_NUMBER}"
else
  echo "Docker image tag: ${DOCKER_TAG}"
fi
echo ""

# Update coder.xml
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s|ghcr.io/ascheel/coder-unraid:v[0-9][0-9.]*|ghcr.io/ascheel/coder-unraid:${DOCKER_TAG}|g" coder.xml
else
  # Linux
  sed -i "s|ghcr.io/ascheel/coder-unraid:v[0-9][0-9.]*|ghcr.io/ascheel/coder-unraid:${DOCKER_TAG}|g" coder.xml
fi

echo "✓ Updated coder.xml (Docker image: ghcr.io/ascheel/coder-unraid:${DOCKER_TAG})"

# Build Docker image if requested
if [ "$BUILD_IMAGE" = "true" ]; then
  echo ""
  echo "Building Docker image..."
  if ./build.sh "${DOCKER_TAG}" "${DOCKER_TAG}"; then
    echo "✓ Docker image built successfully"
    
    if [ "$PUSH_IMAGE" = "true" ]; then
      echo ""
      echo "Pushing Docker image to registry..."
      docker push "ghcr.io/ascheel/coder-unraid:${DOCKER_TAG}" && \
      docker push "ghcr.io/ascheel/coder-unraid:latest" && \
      echo "✓ Docker image pushed successfully"
    fi
  else
    echo "⚠ Docker image build failed"
  fi
else
  echo "⚠ Skipping Docker image build (use --no-build to suppress this message)"
fi

# Show what changed
echo ""
echo "Changes made:"
git diff coder.xml 2>/dev/null || echo "  - Repository updated to ${NEW_VERSION}"

echo ""
echo "Next steps:"
echo "1. Review the changes above"
echo "2. Test the new version:"
echo "   docker run --rm -it ghcr.io/ascheel/coder-unraid:${DOCKER_TAG}"
echo "3. Test the template on unRAID"
echo "4. Update CHANGELOG.md if needed"
echo "5. Commit changes:"
if [ -z "$COMMIT_MSG" ]; then
  if [ "$VERSION_TYPE" = "development" ]; then
    echo "   git add coder.xml"
    echo "   git commit -m \"Update to Coder ${NEW_VERSION} (dev iteration ${DEV_NUMBER})\""
  else
    echo "   git add coder.xml"
    echo "   git commit -m \"Update to Coder ${NEW_VERSION} (stable release)\""
  fi
else
  echo "   git add coder.xml"
  echo "   git commit -m \"Update to Coder ${NEW_VERSION} - ${COMMIT_MSG}\""
fi
echo "6. Create tag: git tag -a ${NEW_VERSION} -m \"Coder ${NEW_VERSION}\""
echo "7. Push: git push origin main && git push origin ${NEW_VERSION}"

if [ "$BUILD_IMAGE" = "true" ] && [ "$PUSH_IMAGE" != "true" ]; then
  echo "8. Push Docker image:"
  echo "   docker push ghcr.io/ascheel/coder-unraid:${DOCKER_TAG}"
  echo "   docker push ghcr.io/ascheel/coder-unraid:latest"
fi

if [ "$VERSION_TYPE" = "development" ]; then
  echo ""
  echo "Note: This is a development version. When ready for stable release, run:"
  echo "   ./update-version-docker.sh ${BASE_VERSION}"
fi

