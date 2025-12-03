#!/bin/bash
# unraid-user-script.sh - unRAID User Scripts plugin script to import Coder template
# Install this script in unRAID User Scripts plugin and run it after Coder container starts
#
# Usage: Add this script to User Scripts plugin and schedule it to run:
#   - At First Array Start Only
#   - Or manually after Coder container is running

set -e

CONTAINER_NAME="Coder"
TEMPLATE_DIR="/mnt/user/appdata/coder/templates"
TEMPLATE_FILE="docker-workspace.tf"
CODER_URL="http://localhost:7080"
MAX_WAIT=300  # Wait up to 5 minutes for Coder to be ready

echo "=========================================="
echo "Coder Template Import - unRAID User Script"
echo "=========================================="
echo ""

# Check if container is running
if ! docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "✗ Coder container '$CONTAINER_NAME' is not running"
    echo "  Please start the container first"
    exit 1
fi

echo "✓ Coder container is running"
echo ""

# Ensure template directory exists
mkdir -p "$TEMPLATE_DIR"
echo "✓ Template directory ready: $TEMPLATE_DIR"
echo ""

# Copy template file if it doesn't exist or is outdated
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/$TEMPLATE_FILE" ]; then
    if [ ! -f "$TEMPLATE_DIR/$TEMPLATE_FILE" ] || \
       [ "$SCRIPT_DIR/$TEMPLATE_FILE" -nt "$TEMPLATE_DIR/$TEMPLATE_FILE" ]; then
        echo "Copying template file to $TEMPLATE_DIR..."
        cp "$SCRIPT_DIR/$TEMPLATE_FILE" "$TEMPLATE_DIR/$TEMPLATE_FILE"
        echo "✓ Template file copied"
    else
        echo "✓ Template file already up to date"
    fi
else
    echo "⚠ Template file not found at $SCRIPT_DIR/$TEMPLATE_FILE"
    echo "  Please ensure docker-workspace.tf is in the same directory as this script"
fi
echo ""

# Wait for Coder to be ready
echo "Waiting for Coder to be ready..."
WAIT_TIME=0
while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    if docker exec "$CONTAINER_NAME" curl -s -f "${CODER_URL}/api/v2/users/me" > /dev/null 2>&1; then
        echo "✓ Coder is ready!"
        break
    fi
    sleep 5
    WAIT_TIME=$((WAIT_TIME + 5))
    echo "  Waiting... (${WAIT_TIME}s/${MAX_WAIT}s)"
done

if [ $WAIT_TIME -ge $MAX_WAIT ]; then
    echo "✗ Coder did not become ready after ${MAX_WAIT}s"
    echo "  Please check Coder logs: docker logs $CONTAINER_NAME"
    exit 1
fi
echo ""

# Execute import script inside container
echo "Importing template into Coder..."
if docker exec "$CONTAINER_NAME" /bin/bash -c "
    export CODER_ACCESS_URL='$CODER_URL'
    export TEMPLATE_DIR='/home/coder/.config/templates'
    export TEMPLATE_FILE='$TEMPLATE_FILE'
    export TEMPLATE_NAME='docker-workspace-unraid'
    /home/coder/.config/templates/import-template.sh
" 2>&1; then
    echo ""
    echo "=========================================="
    echo "✓ Template import completed successfully!"
    echo "=========================================="
    echo ""
    echo "You can now access Coder at: $CODER_URL"
    echo "The template 'docker-workspace-unraid' should be available in the templates list."
else
    echo ""
    echo "✗ Template import failed"
    echo "  Check Coder logs: docker logs $CONTAINER_NAME"
    exit 1
fi

