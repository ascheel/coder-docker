# Version Management Guide

This guide explains how to manage versions for the Coder unRAID Community Application.

## Versioning Strategy

**This template uses version-pinned releases** where each template version matches a specific Coder version. This allows users to:
- Pin to stable, tested versions
- Easily rollback if a buggy Coder release occurs
- Know exactly which Coder version they're running
- Upgrade/downgrade with confidence

**Template Version = Coder Version** (e.g., template `v2.27.7` uses Coder `v2.27.7`)

### Dual-Path Versioning

This project uses a **dual-path versioning strategy** for each primary version:

1. **Development/Testing Path**: `v2.27.7-dev.1`, `v2.27.7-dev.2`, etc.
   - Used for development pushes and testing
   - Pre-release identifiers following [Semantic Versioning](https://semver.org/) spec
   - Allows multiple iterations before stable release
   - Example: `v2.27.7-dev.1` → `v2.27.7-dev.2` → `v2.27.7` (stable)

2. **Stable Release Path**: `v2.27.7`
   - Final, tested, production-ready release
   - Three-component version (MAJOR.MINOR.PATCH)
   - Only created after development versions are tested and validated

**Workflow Example:**
```
v2.27.7-dev.1  → Development/testing iteration 1
v2.27.7-dev.2  → Development/testing iteration 2
v2.27.7        → Stable release (after testing)
```

This approach allows you to:
- Push multiple development versions for testing (`-dev.X`)
- Maintain a clear stable release (`v2.27.7`)
- Follow semantic versioning standards
- Keep development and stable versions clearly separated

## Current Version

The template is currently pinned to: **Coder v2.27.7**

Check the `Repository` tag in `coder.xml` to see the current version.

#### Available Coder Image Tags

Coder publishes images with these tag patterns:
- `:latest` - Latest stable release (current default)
- `:v2.x.x` - Specific version (e.g., `v2.27.7`)
- `:v2.x` - Minor version (e.g., `v2.8`) - points to latest patch
- `:main` - Development/preview builds (not recommended for production)

#### How to Check Available Versions

1. Visit: https://github.com/coder/coder/releases
2. Or check GHCR: https://github.com/orgs/coder/packages/container/coder/versions

#### How Versions Work

Each template release is pinned to a specific Coder version:
```xml
<Repository>ghcr.io/coder/coder:v2.27.7</Repository>
```

When a new Coder version is released, a new template release is created with the matching version tag. See [VERSION_WORKFLOW.md](VERSION_WORKFLOW.md) for the update process.

### Template Versioning

Template versions match Coder versions exactly:

**For Development Versions:**
```bash
# Create development/testing version
git tag -a v2.27.7-dev.1 -m "Coder v2.27.7 - Development iteration 1"
git push origin v2.27.7-dev.1
```

**For Stable Releases:**
```bash
# When ready for stable release, create final version
git tag -a v2.27.7 -m "Coder v2.27.7 - Stable release"
git push origin v2.27.7
```

**Version Format:**
- Development: `vMAJOR.MINOR.PATCH-dev.N` (e.g., `v2.27.7-dev.1`)
- Stable: `vMAJOR.MINOR.PATCH` (e.g., `v2.27.7`)

**Benefits**:
- Clear mapping: template v2.9.0 = Coder v2.9.0
- Easy rollback: install template v2.27.7 to rollback Coder
- Version clarity: users know exactly what they're running
- No confusion: one version number to track

### 3. Repository Releases (GitHub)

Create GitHub releases for major template updates:

1. Go to GitHub → Releases → Create a new release
2. Tag: `v1.0.0`
3. Title: "Coder Template v1.0.0"
4. Description: Include changelog
5. Attach `coder.xml` file

## Recommended Strategy

### For Template Maintainers

1. **Pin to specific Coder versions** in each release
   - Each template release matches a Coder version
   - Test each version before releasing
   - Document any breaking changes

2. **Release workflow** (see [VERSION_WORKFLOW.md](VERSION_WORKFLOW.md)):
   - Monitor Coder releases
   - Test new versions
   - Create matching Git tag/release
   - Update documentation

3. **Handle buggy releases**:
   - Skip problematic versions
   - Create hotfix releases pointing to previous stable version
   - Document issues in support thread

### For End Users

**Installation**:
- Install specific template version (e.g., `v2.27.7`) to get that Coder version
- Check release notes before upgrading
- Test upgrades in non-production first

**Upgrading**:
- Wait for template release matching new Coder version
- Review Coder release notes for breaking changes
- Backup data before upgrading

**Rolling Back**:
- Install previous template version (e.g., `v2.7.0`)
- Your data persists, just the Coder version changes

## How unRAID Handles Updates

### Automatic Updates (with `:latest`)
- unRAID checks for new images periodically
- Users can click "Force Update" to pull latest
- Container restarts with new image

### Manual Updates (with specific version)
- Change the tag in template
- Click "Force Update"
- Container restarts with new version

### Template Updates
- Community Applications checks TemplateURL
- Users see "Update Available" if template changes
- Template updates don't affect running containers

## Best Practices

1. **Test before updating**: Always test new versions in a non-production environment first

2. **Document breaking changes**: If a Coder version has breaking changes, note it in your template's support thread

3. **Monitor Coder releases**: Watch Coder's GitHub releases for security updates

4. **Version your template**: Use Git tags for template versions

5. **Keep README updated**: Document which Coder version the template was tested with

## Example Workflow

See [VERSION_WORKFLOW.md](VERSION_WORKFLOW.md) for the complete workflow. Quick example:

```bash
# 1. Coder releases v2.9.0
# 2. Update coder.xml: <Repository>ghcr.io/coder/coder:v2.9.0</Repository>
# 3. Test locally and on unRAID
# 4. Create matching Git tag
git tag -a v2.9.0 -m "Coder v2.9.0"
git push origin v2.9.0

# 5. Create GitHub release with matching version
# 6. Update support thread
```

## Making Version Configurable (Advanced)

You can add a Config option to let users choose the version:

```xml
<Config
  Name="Coder Version Tag"
  Target="CODER_VERSION"
  Default="latest"
  Mode=""
  Description="Docker image tag/version. Use 'latest' for auto-updates, or specific version like 'v2.27.7' for stability."
  Type="Variable"
  Display="always"
  Required="false"
  Mask="false">latest</Config>
```

Then use it in Repository (though this requires template modification logic that unRAID doesn't natively support - users would need to manually edit).

**Simpler approach**: Document in README how users can edit the template to change versions.

## Checking Current Version

Users can check which version is running:

```bash
# SSH into unRAID
docker exec coder coder version
```

Or check the container image:
```bash
docker inspect coder | grep Image
```

## Resources

- [Coder Releases](https://github.com/coder/coder/releases)
- [Coder Docker Images](https://github.com/orgs/coder/packages/container/coder)
- [Semantic Versioning](https://semver.org/)
- [Git Tagging Guide](https://git-scm.com/book/en/v2/Git-Basics-Tagging)

