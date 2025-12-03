# Quick Start: Auto-Import Template

## Fastest Method (5 minutes)

### Step 1: Prepare Files
```bash
# Create template directory
mkdir -p /mnt/user/appdata/coder/templates

# Copy template file
cp docker-workspace.tf /mnt/user/appdata/coder/templates/

# Copy import script
cp import-template.sh /mnt/user/appdata/coder/templates/
chmod +x /mnt/user/appdata/coder/templates/import-template.sh
```

### Step 2: Verify Coder Container
1. The Coder Data Directory is already mounted (`/mnt/user/appdata/coder` → `/home/coder/.config`)
2. Templates placed in `/mnt/user/appdata/coder/templates` will be accessible at `/home/coder/.config/templates` inside the container
3. No additional container configuration needed!

### Step 3: Import Template (One-Time)

**Option A: Using unRAID User Scripts (Recommended)**
1. Install "User Scripts" plugin if not installed
2. Go to Settings → User Scripts → Add New Script
3. Name: "Import Coder Template"
4. Paste contents of `unraid-user-script.sh`
5. Save and run the script

**Option B: Manual CLI Import**
```bash
# Wait for Coder to be ready (about 1-2 minutes after start)
docker exec Coder coder templates create docker-workspace-unraid \
  --directory /home/coder/.config/templates \
  --yes
```

**Option C: From Inside Container**
```bash
docker exec -it Coder bash
cd /home/coder/.config/templates
export CODER_ACCESS_URL="http://localhost:7080"
./import-template.sh
```

### Step 4: Verify
```bash
# List templates
docker exec Coder coder templates list

# Or check in web UI at http://[YOUR-IP]:7080
```

## That's It!

The template `docker-workspace-unraid` should now be available in Coder. You can create workspaces using this template, and they will have persistent storage at `/mnt/user/appdata/coder/workspaces/{workspace-id}`.

## Updating the Template

When you update `docker-workspace.tf`:
```bash
# 1. Copy updated file
cp docker-workspace.tf /mnt/user/appdata/coder/templates/

# 2. Update in Coder
docker exec Coder coder templates update docker-workspace-unraid \
  --directory /home/coder/.config/templates \
  --yes
```

## Troubleshooting

**Template not showing up?**
- Wait 2-3 minutes after container start for Coder to initialize
- Check logs: `docker logs Coder`
- Verify template file exists on host: `ls -la /mnt/user/appdata/coder/templates/`
- Verify template file exists in container: `docker exec Coder ls -la /home/coder/.config/templates/`

**Import script fails?**
- Ensure Coder is fully started (check web UI is accessible)
- Verify CODER_ACCESS_URL matches your setup
- Check container logs: `docker logs Coder`

**Permission errors?**
- Ensure template directory is writable: `chmod 755 /mnt/user/appdata/coder/templates`
- Check Docker socket permissions (should be handled by container config)

