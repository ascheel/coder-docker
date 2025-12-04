# Coder for unRAID

This repository contains the unRAID Community Application template for [Coder](https://coder.com), a platform for secure, remote development environments.

## Overview

Coder enables you to create and manage remote development environments in the cloud or on your own infrastructure. This template provides an easy way to deploy Coder on your unRAID server.

## Features

- Quick deployment with built-in database (proof-of-concept)
- Support for external PostgreSQL database (production-ready)
- Docker workspace support via Docker socket access
- **Automatic template import** - Docker workspace template is imported automatically on first start
- Persistent data storage
- Easy configuration through unRAID's web interface

## Requirements

- unRAID 6.9.0 or higher
- Docker version 20.10 or higher
- 2 CPU cores and 4 GB RAM minimum
- Linux-based unRAID system

## Installation

### Method 1: Community Applications Plugin (Recommended)

1. Ensure you have the [Community Applications](https://forums.unraid.net/forum/86-community-applications/) plugin installed
2. Search for "Coder" in the Apps tab
3. Click "Install" and configure the following:
   - **Port**: Default is 7080 (change if needed)
   - **Coder Data Directory**: Default is `/mnt/user/appdata/coder`
   - **Coder Access URL**: Set to your unRAID server's IP and port (e.g., `http://192.168.1.100:7080/`)
   - **PostgreSQL Connection URL**: (Optional) Leave empty for built-in database, or provide external PostgreSQL connection string

### Method 2: Manual Template Installation

1. Copy `coder.xml` to your unRAID server's template directory:
   ```bash
   cp coder.xml /boot/config/plugins/dockerMan/templates-user/
   ```
2. Go to Docker → Add Container in the unRAID web interface
3. Select "Coder" from the template dropdown
4. Configure the settings as described above
5. Click "Apply" to start the container

## Automatic Template Import

This template uses a **custom Docker image** (`ghcr.io/ascheel/coder-unraid`) that automatically imports the Docker workspace template on first container start. No manual setup required!

The template `docker-workspace-unraid` will be available immediately after:
1. Installing Coder from Community Applications
2. Starting the container
3. Waiting for Coder to initialize (1-2 minutes)

You can verify the template was imported by:
- Checking the Templates section in the Coder web UI
- Running: `docker exec Coder coder templates list`

See [DOCKER-IMAGE.md](DOCKER-IMAGE.md) for details about the custom image and how to build it.

## Configuration

### Basic Configuration (Built-in Database)

For proof-of-concept or small deployments, you can use Coder's built-in database:

- Set `CODER_ACCESS_URL` to your server's URL (e.g., `http://192.168.1.100:7080/`)
- Leave `CODER_PG_CONNECTION_URL` empty
- Ensure the data directory is mapped correctly

### Production Configuration (External PostgreSQL)

For production deployments, use an external PostgreSQL database:

1. Set up a PostgreSQL database (version 13 or higher)
2. Configure `CODER_PG_CONNECTION_URL` with the connection string:
   ```
   postgresql://username:password@host:port/database
   ```
3. Set `CODER_ACCESS_URL` to your public domain name with HTTPS:
   ```
   https://coder.yourdomain.com
   ```

### Docker Workspace Support

Coder requires access to the Docker socket to create and manage workspace containers. The template automatically configures this with the correct group permissions.

## Usage

1. After installation, access Coder at `http://[YOUR-IP]:7080/`
2. Follow the on-screen instructions to:
   - Create your first admin user
3. The `docker-workspace-unraid` template is automatically imported and ready to use
4. Create your first workspace using the pre-configured template

## Troubleshooting

### Container won't start

- Verify Docker is running: `docker ps`
- Check container logs: `docker logs coder`
- Ensure port 7080 is not in use by another container

### Cannot create Docker workspaces

- Verify Docker socket is accessible: `ls -l /var/run/docker.sock`
- Check that the container has the correct group permissions
- Ensure Docker is running on the host system

### Workspace stuck in "Connecting..."

- Verify `CODER_ACCESS_URL` is set correctly and accessible
- For production deployments, ensure HTTPS is configured
- Check firewall rules allow access to the configured port

### Permission denied errors

- The template uses `--group-add` to grant Docker access
- If issues persist, verify the Docker group exists: `getent group docker`

## Updating

This template uses **version-pinned releases** - each template version matches a specific Coder version for stability and easy rollback.

### Upgrading to a New Version

When a new Coder version is released, a matching template release will be available:

1. Check for new template releases in Community Applications or [GitHub Releases](https://github.com/ascheel/coder-unraid/releases)
2. Review Coder's release notes for breaking changes
3. Stop your Coder container
4. Update the template (or reinstall from Community Applications)
5. Start the container again

### Rolling Back to a Previous Version

If you encounter issues with a newer version:

1. Install a previous template version (e.g., `v2.28.5` instead of `v2.28.0`)
2. Your data persists - only the Coder version changes
3. Report issues in the support thread

### Current Version

This template is currently pinned to: **Coder v2.28.5**

Check the template's Git tags or GitHub releases to see available versions.

**Check Coder releases**: [Coder Releases](https://github.com/coder/coder/releases)

See [VERSIONING.md](VERSIONING.md) and [VERSION_WORKFLOW.md](VERSION_WORKFLOW.md) for detailed version management information.

## Support

- **Coder Documentation**: https://coder.com/docs
- **Coder GitHub**: https://github.com/coder/coder
- **unRAID Forums**: [Create a support thread](https://forums.unraid.net/)

## License

This template is licensed under the MIT License. See [LICENSE](LICENSE) for details.

Coder itself is licensed under the AGPL-3.0 license. See [Coder's license](https://github.com/coder/coder/blob/main/LICENSE) for details.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## References

- [Coder Docker Installation Guide](https://coder.com/docs/install/docker)
- [unRAID Community Applications](https://docs.unraid.net/unraid-os/using-unraid-to/run-docker-containers/community-applications/)
