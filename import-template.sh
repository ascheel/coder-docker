#!/bin/bash
# import-template.sh - Automatically import Terraform template into Coder
# This script can be run inside the Coder container or on the host

set -e

CODER_URL="${CODER_ACCESS_URL:-http://localhost:7080}"
TEMPLATE_DIR="${TEMPLATE_DIR:-/mnt/user/appdata/coder/templates}"
TEMPLATE_FILE="${TEMPLATE_FILE:-docker-workspace.tf}"
TEMPLATE_NAME="${TEMPLATE_NAME:-docker-workspace-unraid}"
MAX_RETRIES=30
RETRY_DELAY=5

echo "Coder Template Import Script"
echo "============================"
echo "Coder URL: $CODER_URL"
echo "Template File: $TEMPLATE_FILE"
echo "Template Name: $TEMPLATE_NAME"
echo ""

# Function to check if Coder is ready
wait_for_coder() {
    local retries=0
    echo "Waiting for Coder to be ready..."
    
    while [ $retries -lt $MAX_RETRIES ]; do
        if curl -s -f "${CODER_URL}/api/v2/users/me" > /dev/null 2>&1; then
            echo "✓ Coder is ready!"
            return 0
        fi
        retries=$((retries + 1))
        echo "  Attempt $retries/$MAX_RETRIES - Coder not ready yet, waiting ${RETRY_DELAY}s..."
        sleep $RETRY_DELAY
    done
    
    echo "✗ Coder did not become ready after $MAX_RETRIES attempts"
    return 1
}

# Function to check if template already exists
template_exists() {
    local template_name="$1"
    coder templates list --output json 2>/dev/null | grep -q "\"name\":\"$template_name\"" || return 1
}

# Function to import template
import_template() {
    local template_dir="$1"
    local template_name="$2"
    
    if [ ! -d "$template_dir" ]; then
        echo "✗ Template directory not found: $template_dir"
        return 1
    fi
    
    if [ ! -f "$template_dir/$TEMPLATE_FILE" ]; then
        echo "✗ Template file not found: $template_dir/$TEMPLATE_FILE"
        return 1
    fi
    
    echo "Importing template: $template_name"
    echo "From directory: $template_dir"
    
    # Check if template already exists
    if template_exists "$template_name"; then
        echo "Template '$template_name' already exists. Updating..."
        coder templates update "$template_name" --directory "$template_dir" --yes
    else
        echo "Creating new template: $template_name"
        coder templates create "$template_name" --directory "$template_dir" --yes
    fi
    
    if [ $? -eq 0 ]; then
        echo "✓ Template '$template_name' imported successfully!"
        return 0
    else
        echo "✗ Failed to import template"
        return 1
    fi
}

# Main execution
main() {
    # Wait for Coder to be ready
    if ! wait_for_coder; then
        echo "Failed to connect to Coder. Please check:"
        echo "  1. Coder container is running"
        echo "  2. CODER_ACCESS_URL is set correctly"
        echo "  3. Coder has finished initializing"
        exit 1
    fi
    
    # Determine template file path
    # Inside container, templates are accessible at /home/coder/.config/templates
    # (since /mnt/user/appdata/coder is mounted to /home/coder/.config)
    # On host, they're at /mnt/user/appdata/coder/templates
    if [ -f "/home/coder/.config/templates/$TEMPLATE_FILE" ]; then
        TEMPLATE_PATH="/home/coder/.config/templates/$TEMPLATE_FILE"
        TEMPLATE_DIR="/home/coder/.config/templates"
    elif [ -f "/mnt/user/appdata/coder/templates/$TEMPLATE_FILE" ]; then
        TEMPLATE_PATH="/mnt/user/appdata/coder/templates/$TEMPLATE_FILE"
        TEMPLATE_DIR="/mnt/user/appdata/coder/templates"
    elif [ -f "$TEMPLATE_DIR/$TEMPLATE_FILE" ]; then
        TEMPLATE_PATH="$TEMPLATE_DIR/$TEMPLATE_FILE"
        TEMPLATE_DIR="$TEMPLATE_DIR"
    elif [ -f "$TEMPLATE_FILE" ]; then
        TEMPLATE_PATH="$TEMPLATE_FILE"
        TEMPLATE_DIR="$(dirname "$TEMPLATE_PATH")"
    else
        echo "✗ Template file not found. Searched:"
        echo "  - /home/coder/.config/templates/$TEMPLATE_FILE (container path)"
        echo "  - /mnt/user/appdata/coder/templates/$TEMPLATE_FILE (host path)"
        echo "  - $TEMPLATE_DIR/$TEMPLATE_FILE"
        echo "  - $TEMPLATE_FILE (current directory)"
        exit 1
    fi
    
    echo "Found template at: $TEMPLATE_PATH"
    echo ""
    
    # Import the template (use directory, not file path)
    import_template "$TEMPLATE_DIR" "$TEMPLATE_NAME"
}

# Run main function
main "$@"

