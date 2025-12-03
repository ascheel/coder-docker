# Automated Template Import for Coder on unRAID

This guide explains how to automatically import the Terraform template when installing Coder from Community Applications.

## The Problem

unRAID Community Applications templates (XML files) cannot execute scripts automatically. However, we can automate the template import process using one of the methods below.

## Method 1: Installation Script (Recommended)

After installing Coder from Community Applications, run the installation script:

### Quick Install

```bash
# Download and run the installation script
curl -sSL https://raw.githubusercontent.com/ascheel/coder-docker/main/install-coder.sh | bash
```

### Manual Install

1. **Download the installation script:**
   ```bash
   cd /tmp
   wget https://raw.githubusercontent.com/ascheel/coder-docker/main/install-coder.sh
   chmod +x install-coder.sh
   ```

2. **Run the script:**
   ```bash
   ./install-coder.sh
   ```

The script will:
- ✓ Check if Coder container exists and is running
- ✓ Create the template directory
- ✓ Copy template files to the correct location
- ✓ Wait for Coder to be ready
- ✓ Automatically import the template

## Method 2: Include Script in Repository

If you're distributing this template via Community Applications, you can:

1. **Package the files together:**
   - Include `docker-workspace.tf` and `import-template.sh` in the repository
   - Users can download and run `install-coder.sh` after installation

2. **Update the README** to include installation instructions

## Method 3: Container Auto-Import (Advanced)

For fully automated import, you can modify the container to auto-import on first start:

### Create a wrapper entrypoint script:

```bash
#!/bin/bash
# /mnt/user/appdata/coder/entrypoint-wrapper.sh

# Run the original Coder entrypoint in background
exec /usr/local/bin/coder server --address 0.0.0.0:7080 "$@" &

# Wait for Coder to be ready
sleep 30
while ! curl -s -f http://localhost:7080/api/v2/users/me > /dev/null 2>&1; do
    sleep 5
done

# Import template if it exists
if [ -f /home/coder/.config/templates/docker-workspace.tf ]; then
    /home/coder/.config/templates/import-template.sh || true
fi

# Wait for background process
wait
```

### Update coder.xml to use the wrapper:

Add to `ExtraParams` or create a custom entrypoint. However, this is complex and not recommended for Community Applications templates.

## Method 4: User Scripts Plugin (Semi-Automated)

1. **Install User Scripts plugin** (if not already installed)

2. **Add the import script:**
   - Go to Settings → User Scripts
   - Add New Script
   - Paste contents of `unraid-user-script.sh`
   - Set to run "At First Array Start Only" or "Custom Schedule"

3. **The script will run automatically** when the array starts

## Recommended Approach

For Community Applications distribution:

1. **Include in repository:**
   - `install-coder.sh` - Main installation script
   - `docker-workspace.tf` - Template file
   - `import-template.sh` - Import helper script
   - `unraid-user-script.sh` - User Scripts plugin script

2. **Update README.md** with installation instructions:
   ```markdown
   ## Post-Installation Setup
   
   After installing Coder from Community Applications:
   
   ```bash
   # Download and run the installation script
   curl -sSL https://raw.githubusercontent.com/ascheel/coder-docker/main/install-coder.sh | bash
   ```
   
   Or manually:
   1. Copy `docker-workspace.tf` to `/mnt/user/appdata/coder/templates/`
   2. Import via CLI: `docker exec Coder coder templates create docker-workspace-unraid --directory /home/coder/.config/templates --yes`
   ```

3. **Update coder.xml Overview** to mention the post-install script

## Testing the Installation Script

To test locally:

```bash
# Make script executable
chmod +x install-coder.sh

# Run it
./install-coder.sh
```

The script will:
- Check for Coder container
- Copy files to the right locations
- Wait for Coder to be ready
- Import the template automatically

## Troubleshooting

### Script fails to find container
- Ensure Coder is installed and the container name is "Coder" (case-sensitive)
- Check: `docker ps -a | grep -i coder`

### Template import fails
- Check Coder logs: `docker logs Coder`
- Verify files exist: `ls -la /mnt/user/appdata/coder/templates/`
- Try manual import: `docker exec Coder coder templates create docker-workspace-unraid --directory /home/coder/.config/templates --yes`

### Coder not ready
- Wait longer (first start can take 2-3 minutes)
- Check if Coder web UI is accessible
- Verify CODER_ACCESS_URL is correct

