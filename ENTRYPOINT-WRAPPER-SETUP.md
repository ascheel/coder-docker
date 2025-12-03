# Entrypoint Wrapper Setup (Alternative to Post-Install Script)

This approach provides **full automation** without modifying the Docker image. The wrapper script runs Coder and automatically imports templates on first start.

## How It Works

1. A wrapper script is mounted into the container
2. The wrapper is set as the entrypoint (replacing default Coder entrypoint)
3. Wrapper starts Coder, waits for it to be ready, then imports templates
4. Everything happens automatically - no user intervention needed

## Setup Instructions

### Step 1: Copy Files to Template Directory

```bash
# Create template directory
mkdir -p /mnt/user/appdata/coder/templates

# Copy template and scripts
cp docker-workspace.tf /mnt/user/appdata/coder/templates/
cp import-template.sh /mnt/user/appdata/coder/templates/
cp entrypoint-wrapper.sh /mnt/user/appdata/coder/
chmod +x /mnt/user/appdata/coder/entrypoint-wrapper.sh
chmod +x /mnt/user/appdata/coder/templates/import-template.sh
```

### Step 2: Update coder.xml

Modify the `ExtraParams` line to use the wrapper as entrypoint:

```xml
<ExtraParams>--entrypoint /home/coder/.config/entrypoint-wrapper.sh --group-add $(stat -c %g /var/run/docker.sock)</ExtraParams>
```

**Important:** The entrypoint path is `/home/coder/.config/entrypoint-wrapper.sh` because `/mnt/user/appdata/coder` is mounted to `/home/coder/.config`.

### Step 3: Install Coder

Install Coder from Community Applications as normal. The template will be imported automatically on first start.

## Pros and Cons

### Pros
- ✅ Fully automated - no user commands needed
- ✅ Uses official Coder image (no maintenance)
- ✅ Template imports automatically on container start
- ✅ Works with Community Applications

### Cons
- ⚠️ More complex configuration
- ⚠️ Entrypoint override can be fragile if Coder changes
- ⚠️ Requires files to be in place before container starts
- ⚠️ Harder to debug if something goes wrong

## Comparison with Post-Install Script

| Feature | Entrypoint Wrapper | Post-Install Script |
|---------|-------------------|---------------------|
| Automation | ✅ Full | ⚠️ One command |
| Setup Complexity | ⚠️ Medium | ✅ Simple |
| Maintenance | ✅ Low | ✅ None |
| Debugging | ⚠️ Harder | ✅ Easier |
| User Control | ❌ Less | ✅ More |

## Troubleshooting

### Container won't start
- Check that `entrypoint-wrapper.sh` exists and is executable
- Verify path in `ExtraParams` is correct
- Check container logs: `docker logs Coder`

### Template not importing
- Verify files are in `/mnt/user/appdata/coder/templates/`
- Check that `import-template.sh` is executable
- Check container logs for errors

### Coder not starting
- The wrapper may be interfering with Coder's startup
- Try removing the entrypoint override temporarily
- Check Coder's official entrypoint requirements

## Recommendation

For most users, the **post-install script approach is simpler and more maintainable**. Use the entrypoint wrapper only if:
- You need 100% automation
- You're comfortable with entrypoint overrides
- You can ensure files are in place before container start

