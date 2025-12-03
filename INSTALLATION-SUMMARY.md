# Installation Automation Summary

## Problem
unRAID Community Applications templates (XML files) cannot execute scripts automatically. Users need a way to automatically import the Terraform template after installing Coder.

## Solution
Created `install-coder.sh` - a post-installation script that automates the entire template import process.

## Files Created

1. **`install-coder.sh`** - Main installation script
   - Checks for Coder container
   - Copies template files to correct location
   - Waits for Coder to be ready
   - Automatically imports the template
   - Can be run via: `curl -sSL URL | bash` or downloaded and run locally

2. **`AUTO-INSTALL.md`** - Documentation explaining all automation methods
   - Method 1: Installation script (recommended)
   - Method 2: Include in repository
   - Method 3: Container auto-import (advanced)
   - Method 4: User Scripts plugin

## How Users Will Use It

### Option 1: One-Line Install (Recommended)
```bash
curl -sSL https://raw.githubusercontent.com/YOUR_REPO/coder-docker/main/install-coder.sh | bash
```

### Option 2: Download and Run
```bash
wget https://raw.githubusercontent.com/YOUR_REPO/coder-docker/main/install-coder.sh
chmod +x install-coder.sh
./install-coder.sh
```

## What Needs to Be Updated

Before publishing, update the GitHub repository URL in:

1. **`install-coder.sh`** - Line with curl command (currently has placeholder)
2. **`README.md`** - Installation instructions (currently has placeholder)
3. **`AUTO-INSTALL.md`** - All GitHub URLs (currently have placeholders)

Replace `YOUR_REPO` with your actual GitHub repository path.

## Integration with Community Applications

The script works perfectly with Community Applications because:

1. User installs Coder from Community Applications
2. User runs the installation script (one command)
3. Template is automatically imported
4. User can immediately start creating workspaces

## Alternative: User Scripts Plugin

For users who prefer automation on array start:
- Use `unraid-user-script.sh` in the User Scripts plugin
- Set to run "At First Array Start Only"
- Will automatically import template when array starts

## Testing

To test the installation script:

```bash
# Make executable
chmod +x install-coder.sh

# Run it
./install-coder.sh
```

The script will:
- ✓ Verify Coder container exists
- ✓ Start container if stopped
- ✓ Copy template files
- ✓ Wait for Coder to initialize
- ✓ Import template automatically

