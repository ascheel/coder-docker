#!/bin/bash
# update-version.sh - Update template to match a specific Coder version
#
# Usage: 
#   Development: ./update-version.sh v2.27.7-dev.1
#   Stable:      ./update-version.sh v2.27.7
#   With message: ./update-version.sh v2.27.7-dev.1 "Fixed workspace creation bug"

set -e

NEW_VERSION=$1
COMMIT_MSG=$2

if [ -z "$NEW_VERSION" ]; then
  echo "Usage: $0 <version> [commit-message]"
  echo ""
  echo "Examples:"
  echo "  Development: $0 v2.27.7-dev.1"
  echo "  Stable:      $0 v2.27.7"
  echo "  With message: $0 v2.27.7-dev.1 'Fixed workspace creation bug'"
  echo ""
  echo "Version formats:"
  echo "  Development: vX.Y.Z-dev.N (e.g., v2.27.7-dev.1)"
  echo "  Stable:      vX.Y.Z (e.g., v2.27.7)"
  exit 1
fi

# Validate version format
# Supports: vX.Y.Z (stable) or vX.Y.Z-dev.N (development)
if [[ ! $NEW_VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-dev\.[0-9]+)?$ ]]; then
  echo "Error: Version must be in format:"
  echo "  - Stable: vX.Y.Z (e.g., v2.27.7)"
  echo "  - Development: vX.Y.Z-dev.N (e.g., v2.27.7-dev.1)"
  exit 1
fi

# Determine if this is a development or stable version
if [[ $NEW_VERSION =~ -dev\.[0-9]+$ ]]; then
  VERSION_TYPE="development"
  # Extract base version (e.g., v2.27.7 from v2.27.7-dev.1)
  BASE_VERSION=$(echo $NEW_VERSION | sed 's/-dev\.[0-9]*$//')
  # Extract dev number
  DEV_NUMBER=$(echo $NEW_VERSION | sed 's/.*-dev\.//')
else
  VERSION_TYPE="stable"
  BASE_VERSION=$NEW_VERSION
fi

# Extract version number without 'v' prefix for Docker image tag
# For development versions, use the base version (e.g., v2.27.7-dev.1 → v2.27.7)
DOCKER_TAG=$BASE_VERSION
VERSION_NUM=${BASE_VERSION#v}

echo "Updating template to Coder ${NEW_VERSION}..."
echo "Version type: ${VERSION_TYPE}"
if [ "$VERSION_TYPE" = "development" ]; then
  echo "Docker image tag: ${DOCKER_TAG} (using base version)"
  echo "Development iteration: ${DEV_NUMBER}"
else
  echo "Docker image tag: ${DOCKER_TAG}"
fi
echo ""

# Update coder.xml
# Note: Docker image tag uses BASE_VERSION (e.g., v2.27.7), not the full dev version
# Pattern: v[0-9][0-9.]* ensures version starts with at least one digit
# Period in character class [] doesn't need escaping - it's literal
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  sed -i '' "s|ghcr.io/coder/coder:v[0-9][0-9.]*|ghcr.io/coder/coder:${DOCKER_TAG}|g" coder.xml
else
  # Linux
  sed -i "s|ghcr.io/coder/coder:v[0-9][0-9.]*|ghcr.io/coder/coder:${DOCKER_TAG}|g" coder.xml
fi

echo "✓ Updated coder.xml (Docker tag: ${DOCKER_TAG})"

# Update docker-compose.yml if it exists
if [ -f "docker-compose.yml" ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|ghcr.io/coder/coder:.*|ghcr.io/coder/coder:${DOCKER_TAG}|g" docker-compose.yml
  else
    sed -i "s|ghcr.io/coder/coder:.*|ghcr.io/coder/coder:${DOCKER_TAG}|g" docker-compose.yml
  fi
  echo "✓ Updated docker-compose.yml (Docker tag: ${DOCKER_TAG})"
fi

# Show what changed
echo ""
echo "Changes made:"
git diff coder.xml docker-compose.yml 2>/dev/null || echo "  - Repository updated to ${NEW_VERSION}"

echo ""
echo "Next steps:"
echo "1. Review the changes above"
echo "2. Test the new version locally:"
echo "   docker run --rm -it ghcr.io/coder/coder:${DOCKER_TAG}"
echo "3. Test the template on unRAID"
echo "4. Update CHANGELOG.md if needed"
echo "5. Commit changes:"
if [ -z "$COMMIT_MSG" ]; then
  if [ "$VERSION_TYPE" = "development" ]; then
    echo "   git add coder.xml docker-compose.yml"
    echo "   git commit -m \"Update to Coder ${NEW_VERSION} (dev iteration ${DEV_NUMBER})\""
  else
    echo "   git add coder.xml docker-compose.yml"
    echo "   git commit -m \"Update to Coder ${NEW_VERSION} (stable release)\""
  fi
else
  echo "   git add coder.xml docker-compose.yml"
  echo "   git commit -m \"Update to Coder ${NEW_VERSION} - ${COMMIT_MSG}\""
fi
echo "6. Create tag: git tag -a ${NEW_VERSION} -m \"Coder ${NEW_VERSION}\""
echo "7. Push: git push origin main && git push origin ${NEW_VERSION}"
echo "8. Create GitHub release for ${NEW_VERSION}"
if [ "$VERSION_TYPE" = "development" ]; then
  echo ""
  echo "Note: This is a development version. When ready for stable release, run:"
  echo "   ./update-version.sh ${BASE_VERSION}"
fi

