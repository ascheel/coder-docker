#!/bin/bash
# install-coder.sh - Automated installation script for Coder on unRAID
# This script handles the complete setup including template import
#
# Usage:
#   After installing Coder from Community Applications, run this script:
#   ./install-coder.sh
#
# Or download and run directly:
#   curl -sSL https://raw.githubusercontent.com/ascheel/coder-docker/main/install-coder.sh | bash

set -e

CONTAINER_NAME="Coder"
TEMPLATE_DIR="/mnt/user/appdata/coder/templates"
TEMPLATE_FILE="docker-workspace.tf"
IMPORT_SCRIPT="import-template.sh"
CODER_URL="http://localhost:7080"
MAX_WAIT=300  # Wait up to 5 minutes for Coder to be ready

echo "=========================================="
echo "Coder Installation & Template Setup"
echo "=========================================="
echo ""

# Check if running on unRAID
if [ ! -d "/boot/config" ]; then
    echo "⚠ Warning: This script is designed for unRAID"
    echo "  Continuing anyway..."
    echo ""
fi

# Step 1: Check if container exists
echo "Step 1: Checking Coder container..."
if ! docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "✗ Coder container '$CONTAINER_NAME' not found"
    echo ""
    echo "Please install Coder first:"
    echo "  1. Go to Apps → Community Applications"
    echo "  2. Search for 'Coder'"
    echo "  3. Click Install and configure settings"
    echo "  4. Start the container"
    echo "  5. Run this script again"
    exit 1
fi

echo "✓ Coder container found"
echo ""

# Step 2: Check if container is running
echo "Step 2: Checking container status..."
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "⚠ Container exists but is not running"
    echo "  Starting container..."
    docker start "$CONTAINER_NAME"
    sleep 5
    echo "✓ Container started"
else
    echo "✓ Container is running"
fi
echo ""

# Step 3: Prepare template directory
echo "Step 3: Preparing template directory..."
mkdir -p "$TEMPLATE_DIR"
echo "✓ Template directory ready: $TEMPLATE_DIR"
echo ""

# Step 4: Copy template files
echo "Step 4: Copying template files..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy docker-workspace.tf
if [ -f "$SCRIPT_DIR/$TEMPLATE_FILE" ]; then
    if [ ! -f "$TEMPLATE_DIR/$TEMPLATE_FILE" ] || \
       [ "$SCRIPT_DIR/$TEMPLATE_FILE" -nt "$TEMPLATE_DIR/$TEMPLATE_FILE" ]; then
        cp "$SCRIPT_DIR/$TEMPLATE_FILE" "$TEMPLATE_DIR/$TEMPLATE_FILE"
        echo "✓ Copied $TEMPLATE_FILE"
    else
        echo "✓ $TEMPLATE_FILE already up to date"
    fi
else
    echo "⚠ $TEMPLATE_FILE not found in script directory"
    echo "  You may need to download it manually"
fi

# Copy import-template.sh
if [ -f "$SCRIPT_DIR/$IMPORT_SCRIPT" ]; then
    if [ ! -f "$TEMPLATE_DIR/$IMPORT_SCRIPT" ] || \
       [ "$SCRIPT_DIR/$IMPORT_SCRIPT" -nt "$TEMPLATE_DIR/$IMPORT_SCRIPT" ]; then
        cp "$SCRIPT_DIR/$IMPORT_SCRIPT" "$TEMPLATE_DIR/$IMPORT_SCRIPT"
        chmod +x "$TEMPLATE_DIR/$IMPORT_SCRIPT"
        echo "✓ Copied $IMPORT_SCRIPT"
    else
        echo "✓ $IMPORT_SCRIPT already up to date"
    fi
else
    echo "⚠ $IMPORT_SCRIPT not found in script directory"
    echo "  You may need to download it manually"
fi
echo ""

# Step 5: Wait for Coder to be ready
echo "Step 5: Waiting for Coder to initialize..."
WAIT_TIME=0
while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    if docker exec "$CONTAINER_NAME" curl -s -f "${CODER_URL}/api/v2/users/me" > /dev/null 2>&1; then
        echo "✓ Coder is ready!"
        break
    fi
    sleep 5
    WAIT_TIME=$((WAIT_TIME + 5))
    if [ $((WAIT_TIME % 30)) -eq 0 ]; then
        echo "  Still waiting... (${WAIT_TIME}s/${MAX_WAIT}s)"
    fi
done

if [ $WAIT_TIME -ge $MAX_WAIT ]; then
    echo "✗ Coder did not become ready after ${MAX_WAIT}s"
    echo "  Please check Coder logs: docker logs $CONTAINER_NAME"
    echo "  You can try running the import manually later"
    exit 1
fi
echo ""

# Step 6: Import template
echo "Step 6: Importing template into Coder..."
if docker exec "$CONTAINER_NAME" /bin/bash -c "
    export CODER_ACCESS_URL='$CODER_URL'
    export TEMPLATE_DIR='/home/coder/.config/templates'
    export TEMPLATE_FILE='$TEMPLATE_FILE'
    export TEMPLATE_NAME='docker-workspace-unraid'
    if [ -f /home/coder/.config/templates/$IMPORT_SCRIPT ]; then
        /home/coder/.config/templates/$IMPORT_SCRIPT
    else
        # Fallback: direct import
        coder templates create docker-workspace-unraid \
            --directory /home/coder/.config/templates \
            --yes 2>&1 || \
        coder templates update docker-workspace-unraid \
            --directory /home/coder/.config/templates \
            --yes 2>&1
    fi
" 2>&1; then
    echo ""
    echo "=========================================="
    echo "✓ Installation completed successfully!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "  1. Access Coder at: $CODER_URL"
    echo "  2. The template 'docker-workspace-unraid' should be available"
    echo "  3. Create your first workspace!"
    echo ""
else
    echo ""
    echo "⚠ Template import had issues, but files are in place"
    echo "  You can import manually:"
    echo "    docker exec $CONTAINER_NAME coder templates create docker-workspace-unraid \\"
    echo "      --directory /home/coder/.config/templates --yes"
    echo ""
    exit 1
fi

