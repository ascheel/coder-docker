# Version Management Workflow

This repository uses **version-pinned releases** that match Coder's versioning. Each template release corresponds to a specific Coder version, allowing users to easily rollback if needed.

## Versioning Strategy

- **Template version** = **Coder version** (e.g., `v2.27.7`)
- Each Git tag/release uses the exact Coder version it's pinned to
- Users can install specific versions or upgrade/downgrade as needed

### Dual-Path Versioning

This project uses **two versioning paths** for each primary version:

1. **Development Path**: `v2.27.7-dev.1`, `v2.27.7-dev.2`, etc.
   - For development pushes and testing
   - Uses semver pre-release identifiers (`-dev.N`)
   - Docker image tag uses base version (e.g., `v2.27.7`)

2. **Stable Path**: `v2.27.7`
   - Final, tested, production-ready release
   - Created after development versions are validated

**Example Workflow:**
```
v2.27.7-dev.1  → Test iteration 1
v2.27.7-dev.2  → Test iteration 2  
v2.27.7        → Stable release
```

## Workflow: Updating for a New Coder Release

### For Development Versions

When creating a development/testing iteration:

```bash
# Use the update script with a dev version
./update-version.sh v2.27.7-dev.1

# Or manually:
# 1. Update coder.xml to use base version (v2.27.7)
# 2. Test
# 3. Commit and tag with dev version (v2.27.7-dev.1)
git tag -a v2.27.7-dev.1 -m "Coder v2.27.7 - Development iteration 1"
git push origin v2.27.7-dev.1
```

### For Stable Releases

When Coder releases a new version (e.g., `v2.9.0`) or you're ready to release stable:

### 1. Check Coder Releases

Visit https://github.com/coder/coder/releases to see the latest version and release notes.

### 2. Test the New Version Locally

```bash
# Pull and test the new Coder image
docker run --rm -it \
  -v $(pwd)/test-data:/home/coder/.config \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(stat -c %g /var/run/docker.sock) \
  ghcr.io/coder/coder:v2.9.0
```

### 3. Update Template Files

**Update `coder.xml`:**
```xml
<Repository>ghcr.io/coder/coder:v2.9.0</Repository>
```

**Check for breaking changes:**
- Review Coder's release notes
- Check if new environment variables are needed
- Verify Docker socket requirements haven't changed
- Update documentation if needed

### 4. Update Documentation

**Update `README.md`:**
- Update any version-specific instructions
- Note any breaking changes in the changelog section
- Update compatibility notes if needed

**Update `VERSIONING.md`:**
- Add the new version to examples
- Update any version-specific notes

### 5. Test Template on unRAID

1. Copy updated `coder.xml` to unRAID
2. Test installation with the new version
3. Verify all configuration options work
4. Test workspace creation

### 6. Create Git Tag and Release

**For Development Versions:**
```bash
# Stage changes
git add coder.xml README.md VERSIONING.md

# Commit with version number
git commit -m "Update to Coder v2.27.7-dev.1"

# Create tag matching template version (includes -dev.N)
git tag -a v2.27.7-dev.1 -m "Coder v2.27.7 - Development iteration 1"

# Push commits and tags
git push origin main
git push origin v2.27.7-dev.1
```

**For Stable Releases:**
```bash
# Stage changes
git add coder.xml README.md VERSIONING.md

# Commit with version number
git commit -m "Update to Coder v2.9.0 (stable release)"

# Create tag matching Coder version (no -dev suffix)
git tag -a v2.9.0 -m "Coder v2.9.0 - Stable release"

# Push commits and tags
git push origin main
git push origin v2.9.0
```

### 7. Create GitHub Release

**For Development Versions:**
1. Go to GitHub → Releases → Draft a new release
2. **Tag**: `v2.27.7-dev.1` (select existing tag)
3. **Title**: `Coder v2.27.7-dev.1 (Development)`
4. **Description**:
   ```markdown
   ## Development Release
   This is a development/testing iteration. Use `v2.27.7` for stable releases.
   
   ## Changes
   - Updated to Coder v2.27.7
   - [List any template-specific changes]
   
   ## Testing
   Please test and report any issues before stable release.
   ```
5. **Attach**: `coder.xml` file
6. Mark as **Pre-release** (important!)
7. Publish release

**For Stable Releases:**
1. Go to GitHub → Releases → Draft a new release
2. **Tag**: `v2.9.0` (select existing tag)
3. **Title**: `Coder v2.9.0`
4. **Description**:
   ```markdown
   ## Stable Release
   This is a stable, production-ready release.
   
   ## Changes
   - Updated to Coder v2.9.0
   - [List any template-specific changes]
   
   ## Coder Release Notes
   [Link to Coder's release notes]
   
   ## Upgrade Instructions
   1. Stop your Coder container
   2. Update the template (or reinstall from Community Applications)
   3. Start the container
   ```
5. **Attach**: `coder.xml` file
6. **Do NOT** mark as pre-release
7. Publish release

### 8. Update Support Thread

Post in your unRAID forums support thread:
- Announce new version availability
- Highlight any breaking changes
- Provide upgrade instructions
- Link to release notes

## Handling Buggy Releases

If Coder releases a buggy version:

### Option 1: Skip the Version

Don't create a release for that version. Users stay on the previous stable version.

### Option 2: Create a Hotfix Release

If users already upgraded:

1. Create a release pointing to the previous stable version
2. Update support thread with rollback instructions
3. Document the issue

### Option 3: Quick Fix Release

If a patch is released quickly (e.g., `v2.9.1` fixes `v2.9.0`):

1. Create release for the patch version
2. Note in release that it fixes issues in previous version

## Version History Tracking

Maintain a `CHANGELOG.md` or track versions in README:

```markdown
## Version History

- **v2.9.0** (2025-01-XX) - Updated to Coder v2.9.0
- **v2.27.7** (2025-01-XX) - Initial release, Coder v2.27.7
```

## Automation Ideas

Consider creating a script to automate version updates:

```bash
#!/bin/bash
# update-version.sh

NEW_VERSION=$1
if [ -z "$NEW_VERSION" ]; then
  echo "Usage: ./update-version.sh v2.9.0"
  exit 1
fi

# Update coder.xml
sed -i "s/ghcr.io\/coder\/coder:v[0-9.]*/ghcr.io\/coder\/coder:${NEW_VERSION}/" coder.xml

# Update version in README if needed
# sed -i "s/Version: v[0-9.]*/Version: ${NEW_VERSION}/" README.md

echo "Updated to ${NEW_VERSION}"
echo "Don't forget to:"
echo "1. Test the new version"
echo "2. Update documentation"
echo "3. Create git tag: git tag -a ${NEW_VERSION}"
echo "4. Create GitHub release"
```

## Best Practices

1. **Always test** before releasing
2. **Read release notes** - check for breaking changes
3. **Document changes** - help users understand what's new
4. **Monitor issues** - watch Coder's GitHub for known issues
5. **Be responsive** - quickly address problems in your releases
6. **Maintain compatibility** - don't break existing configurations unnecessarily

## Checking Current Version

To see what version your template is currently pinned to:

```bash
grep "Repository" coder.xml
```

Or check Git tags:

```bash
git tag -l
```

## Resources

- [Coder Releases](https://github.com/coder/coder/releases)
- [Coder Changelog](https://github.com/coder/coder/blob/main/CHANGELOG.md)
- [Coder Docker Images](https://github.com/orgs/coder/packages/container/coder)

