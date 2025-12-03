#!/bin/bash
# entrypoint-wrapper.sh - Wrapper script for Coder that auto-imports templates
# This script runs Coder server and automatically imports templates on first start

set -e

CODER_URL="${CODER_ACCESS_URL:-http://localhost:7080}"
TEMPLATE_DIR="/home/coder/templates"
TEMPLATE_FILE="docker-workspace.tf"
TEMPLATE_NAME="docker-workspace-unraid"
MAX_WAIT=300
WAIT_TIME=0

# Function to check if template already exists
template_exists() {
    local template_name="$1"
    /usr/local/bin/coder templates list --output json 2>/dev/null | grep -q "\"name\":\"$template_name\"" || return 1
}

# Function to import template
import_template() {
    local template_dir="$1"
    local template_name="$2"
    
    if [ ! -d "$template_dir" ]; then
        echo "⚠ Template directory not found: $template_dir"
        return 1
    fi
    
    if [ ! -f "$template_dir/$TEMPLATE_FILE" ]; then
        echo "⚠ Template file not found: $template_dir/$TEMPLATE_FILE"
        return 1
    fi
    
    echo "Importing template: $template_name"
    
    # Check if template already exists
    if template_exists "$template_name"; then
        echo "Template '$template_name' already exists. Skipping import."
        return 0
    else
        echo "Creating new template: $template_name"
        if /usr/local/bin/coder templates create "$template_name" \
            --directory "$template_dir" \
            --yes 2>&1; then
            echo "✓ Template imported successfully"
            return 0
        else
            echo "⚠ Template import failed (may already exist or Coder not ready)"
            return 1
        fi
    fi
    
    return 0
}

# Start Coder server in background
echo "=========================================="
echo "Starting Coder server..."
echo "=========================================="
/usr/local/bin/coder server --address 0.0.0.0:7080 "$@" &

CODER_PID=$!

# Wait for Coder to be ready
echo ""
echo "Waiting for Coder to initialize..."
while [ $WAIT_TIME -lt $MAX_WAIT ]; do
    if curl -s -f "${CODER_URL}/api/v2/users/me" > /dev/null 2>&1; then
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
    echo "⚠ Coder did not become ready after ${MAX_WAIT}s"
    echo "  Template import will be skipped"
    echo "  Coder server will continue running"
else
    # Import template if it exists
    if [ -f "$TEMPLATE_DIR/$TEMPLATE_FILE" ]; then
        echo ""
        echo "=========================================="
        echo "Auto-importing template..."
        echo "=========================================="
        export CODER_ACCESS_URL="$CODER_URL"
        import_template "$TEMPLATE_DIR" "$TEMPLATE_NAME" || true
        echo ""
    else
        echo "⚠ Template file not found at $TEMPLATE_DIR/$TEMPLATE_FILE"
        echo "  Skipping template import"
    fi
fi

echo "=========================================="
echo "Coder server is running"
echo "Access at: ${CODER_ACCESS_URL:-http://localhost:7080}"
echo "=========================================="
echo ""

# Wait for Coder process (keep container running)
wait $CODER_PID
