# Automatically Importing Coder Templates in unRAID

This guide provides several methods to automatically import the `docker-workspace.tf` Terraform template into Coder as part of the installation routine.

## Overview

The template file (`docker-workspace.tf`) needs to be imported into Coder so it can be used to create workspaces. This can be automated using one of the methods below.

## Method 1: Mount Template Directory (Recommended)

This method mounts the template directory into the Coder container, allowing Coder to discover and use templates automatically.

### Steps:

1. **No additional mount needed!** The Coder Data Directory (`/mnt/user/appdata/coder` → `/home/coder/.config`) already provides access. Simply create the templates subdirectory:
   ```bash
   mkdir -p /mnt/user/appdata/coder/templates
   ```
   
   This will be accessible at `/home/coder/.config/templates` inside the container.

2. **Copy the template file** to the mounted directory:
   ```bash
   mkdir -p /mnt/user/appdata/coder/templates
   cp docker-workspace.tf /mnt/user/appdata/coder/templates/
   ```

3. **Import via Coder CLI** (run inside container or from host):
   ```bash
   docker exec Coder coder templates create docker-workspace-unraid \
     --directory /home/coder/.config/templates \
     --yes
   ```
   
   **Note:** Use `/home/coder/.config/templates` (container path), since `/mnt/user/appdata/coder` is mounted to `/home/coder/.config`.

**Pros:**
- Templates persist across container restarts
- Easy to update templates
- No additional scripts needed

**Cons:**
- Requires manual import via CLI or web UI initially

## Method 2: Automated Import Script (Inside Container)

This method uses a startup script that automatically imports the template when Coder starts.

### Steps:

1. **Copy the import script** to your template directory:
   ```bash
   mkdir -p /mnt/user/appdata/coder/templates
   cp import-template.sh /mnt/user/appdata/coder/templates/
   cp docker-workspace.tf /mnt/user/appdata/coder/templates/
   chmod +x /mnt/user/appdata/coder/templates/import-template.sh
   ```

2. **No changes to `coder.xml` needed** - the existing Coder Data Directory mount provides access. Add an environment variable for the startup script if desired:
   ```xml
   <Config
     Name="Auto Import Template"
     Target="CODER_AUTO_IMPORT_TEMPLATE"
     Default="true"
     Mode=""
     Description="Automatically import template on startup"
     Type="Variable"
     Display="always"
     Required="false"
     Mask="false">true</Config>
   ```

3. **Modify Coder startup** to run the import script. You can do this by:
   - Using a custom entrypoint script, or
   - Using unRAID's User Scripts plugin (see Method 3)

## Method 3: unRAID User Scripts Plugin (Easiest)

This method uses unRAID's User Scripts plugin to automatically import the template after the Coder container starts.

### Steps:

1. **Install User Scripts plugin** (if not already installed):
   - Go to Plugins → Install Plugin
   - Search for "User Scripts"
   - Install the plugin

2. **Copy files to a persistent location**:
   ```bash
   mkdir -p /mnt/user/appdata/coder/templates
   cp docker-workspace.tf /mnt/user/appdata/coder/templates/
   cp import-template.sh /mnt/user/appdata/coder/templates/
   chmod +x /mnt/user/appdata/coder/templates/import-template.sh
   ```

3. **Add the User Script**:
   - Go to Settings → User Scripts
   - Click "Add New Script"
   - Name it "Import Coder Template"
   - Paste the contents of `unraid-user-script.sh`
   - Save the script

4. **Configure the script**:
   - Set it to run "At First Array Start Only" or "Custom Schedule"
   - Or run it manually after starting the Coder container

5. **No changes to `coder.xml` needed** - templates are accessible via the existing Coder Data Directory mount

**Pros:**
- Easy to set up and manage
- Runs automatically after container starts
- Can be scheduled or run manually
- No container modifications needed

**Cons:**
- Requires User Scripts plugin
- Runs on host, not inside container

## Method 4: Docker Compose with Init Container

If using Docker Compose (for testing or alternative deployment):

1. **Create an init container** that waits for Coder and imports the template
2. **Use docker-compose.yml** with depends_on and healthchecks
3. **Run the import script** in the init container

See `docker-compose.yml` for reference structure.

## Quick Start (Recommended: Method 3)

For the easiest setup:

```bash
# 1. Create template directory
mkdir -p /mnt/user/appdata/coder/templates

# 2. Copy template and script
cp docker-workspace.tf /mnt/user/appdata/coder/templates/
cp import-template.sh /mnt/user/appdata/coder/templates/
chmod +x /mnt/user/appdata/coder/templates/import-template.sh

# 3. Update coder.xml to add template directory mount (see Method 1)

# 4. Add unraid-user-script.sh to User Scripts plugin

# 5. Start Coder container and run the User Script
```

## Verification

After importing, verify the template is available:

```bash
# From host
docker exec Coder coder templates list

# Or access Coder web UI and check Templates section
```

## Troubleshooting

### Template not found
- Verify the template file exists at the expected path
- Check file permissions (should be readable)
- Ensure the directory is mounted correctly

### Coder not ready
- Wait a few minutes after container start for Coder to initialize
- Check logs: `docker logs Coder`
- Verify CODER_ACCESS_URL is correct

### Import fails
- Check Coder logs: `docker logs Coder`
- Verify you're logged in as admin: `docker exec Coder coder users list`
- Try manual import: `docker exec Coder coder templates create docker-workspace-unraid --directory /mnt/user/appdata/coder/templates`

## Updating Templates

When you update `docker-workspace.tf`:

1. Copy the updated file to `/mnt/user/appdata/coder/templates/`
2. Update the template in Coder:
   ```bash
   docker exec Coder coder templates update docker-workspace-unraid \
     --directory /mnt/user/appdata/coder/templates \
     --yes
   ```

Or re-run the import script - it will update existing templates automatically.

