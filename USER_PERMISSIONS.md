# User Permissions Guide for Coder Container

This guide explains how to determine which user the Coder container runs as and how to properly prepare the configuration directory with the correct UID/GID permissions.

## Determining the Container User

### Method 1: Check Running Container

If you have a running Coder container, you can check the user it runs as:

```bash
docker exec coder id
```

This will output something like:
```
uid=1000(coder) gid=1000(coder) groups=1000(coder),999(docker)
```

### Method 2: Inspect the Image

Check the Dockerfile or image metadata:

```bash
docker inspect ghcr.io/coder/coder:v2.27.7 | grep -i user
```

Or check the image's default user:

```bash
docker run --rm --entrypoint id ghcr.io/coder/coder:v2.27.7
```

### Method 3: Check Coder Documentation

The Coder Docker image typically runs as:
- **User**: `coder`
- **UID**: Usually `1000` (but can vary)
- **GID**: Usually `1000` (but can vary)
- **Home directory**: `/home/coder`

## Default Coder Container User

Based on the Coder Docker image structure:
- **Username**: `coder`
- **Default UID**: `1000`
- **Default GID**: `1000`
- **Home directory**: `/home/coder`
- **Config directory**: `/home/coder/.config`

**Note**: The actual UID/GID may vary depending on the image version. Always verify using Method 1 or 2 above.

## Preparing the Config Directory

### For unRAID

In unRAID, the default path is `/mnt/user/appdata/coder`. You need to set the correct ownership before starting the container.

#### Step 1: Determine the Container's UID/GID

Run a test container to check:

```bash
docker run --rm --entrypoint id ghcr.io/coder/coder:v2.27.7
```

Example output:
```
uid=1000(coder) gid=1000(coder) groups=1000(coder)
```

#### Step 2: Set Directory Ownership

Set the ownership to match the container's UID/GID:

```bash
# If container runs as UID 1000, GID 1000:
chown -R 1000:1000 /mnt/user/appdata/coder

# Or if you want to use the nobody user (UID 99) common in unRAID:
chown -R 99:100 /mnt/user/appdata/coder
```

#### Step 3: Set Directory Permissions

Ensure the directory has proper permissions:

```bash
chmod -R 755 /mnt/user/appdata/coder
```

### For Docker Compose

If using `docker-compose.yml`, prepare the directory:

```bash
# Create directory if it doesn't exist
mkdir -p ./coder-data

# Set ownership (assuming UID 1000, GID 1000)
sudo chown -R 1000:1000 ./coder-data

# Set permissions
chmod -R 755 ./coder-data
```

## Running Container with Specific User (Alternative)

If you want to run the container as a specific user (e.g., to match your unRAID user), you can override the default user:

### Docker Compose

Add `user` to your service:

```yaml
services:
  coder:
    image: ghcr.io/coder/coder:v2.27.7
    user: "1000:1000"  # UID:GID
    # ... rest of config
```

### Docker Run

```bash
docker run --user 1000:1000 ...
```

### unRAID Template

Add to `ExtraParams` in `coder.xml`:

```xml
<ExtraParams>--user 1000:1000 --group-add $(stat -c %g /var/run/docker.sock)</ExtraParams>
```

**Note**: You'll need to determine the correct UID/GID for your unRAID system. Common values:
- `nobody` user: UID `99`, GID `100`
- Your user: Check with `id` command

## Verifying Permissions

After starting the container, verify it can write to the config directory:

```bash
# Check if container can write
docker exec coder touch /home/coder/.config/test.txt

# Check ownership of created files
ls -la /mnt/user/appdata/coder/

# Clean up test file
docker exec coder rm /home/coder/.config/test.txt
```

## Troubleshooting Permission Issues

### Permission Denied Errors

If you see permission errors:

1. **Check current ownership**:
   ```bash
   ls -la /mnt/user/appdata/coder
   ```

2. **Check container user**:
   ```bash
   docker exec coder id
   ```

3. **Fix ownership mismatch**:
   ```bash
   # Match container's UID/GID
   chown -R 1000:1000 /mnt/user/appdata/coder
   ```

### Files Created as Root

If files are being created as root:

1. The container is likely running as root
2. Check if you can specify a non-root user (see "Running Container with Specific User" above)
3. Or fix ownership after the fact:
   ```bash
   sudo chown -R 1000:1000 /mnt/user/appdata/coder
   ```

### unRAID-Specific Issues

In unRAID, if you're having permission issues:

1. **Use the `nobody` user** (UID 99, GID 100):
   ```xml
   <ExtraParams>--user 99:100 --group-add $(stat -c %g /var/run/docker.sock)</ExtraParams>
   ```

2. **Set directory ownership**:
   ```bash
   chown -R 99:100 /mnt/user/appdata/coder
   ```

3. **Ensure directory exists** before starting container:
   ```bash
   mkdir -p /mnt/user/appdata/coder
   chown -R 99:100 /mnt/user/appdata/coder
   ```

## Quick Reference

### Default Coder Container User
- **Username**: `coder`
- **UID**: `1000` (verify with `docker exec coder id`)
- **GID**: `1000` (verify with `docker exec coder id`)

### Recommended unRAID Setup
```bash
# 1. Create directory
mkdir -p /mnt/user/appdata/coder

# 2. Set ownership (adjust UID/GID as needed)
chown -R 1000:1000 /mnt/user/appdata/coder

# 3. Set permissions
chmod -R 755 /mnt/user/appdata/coder
```

### Verify After Container Start
```bash
docker exec coder id
docker exec coder ls -la /home/coder/.config
```

