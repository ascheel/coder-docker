# Versioning Quick Reference

## Dual-Path Versioning Strategy

This project uses **semver-compliant dual-path versioning** for each primary version.

### Version Formats

| Type | Format | Example | Use Case |
|------|--------|---------|----------|
| **Development** | `vX.Y.Z-dev.N` | `v2.27.7-dev.1` | Development pushes, testing iterations |
| **Stable** | `vX.Y.Z` | `v2.27.7` | Production-ready releases |

### Quick Commands

#### Create Development Version
```bash
# First development iteration
./update-version.sh v2.27.7-dev.1

# Subsequent iterations
./update-version.sh v2.27.7-dev.2
./update-version.sh v2.27.7-dev.3
```

#### Create Stable Release
```bash
# After testing dev versions, create stable release
./update-version.sh v2.27.7
```

### Important Notes

1. **Docker Image Tag**: Always uses the **base version** (e.g., `v2.27.7`)
   - Development versions (`v2.27.7-dev.1`) still use Docker tag `v2.27.7`
   - The `-dev.N` suffix is only for Git tags and GitHub releases

2. **Git Tags**: Use the full version including `-dev.N` for development
   ```bash
   git tag -a v2.27.7-dev.1 -m "Development iteration 1"
   git tag -a v2.27.7 -m "Stable release"
   ```

3. **GitHub Releases**:
   - Development: Mark as **Pre-release**
   - Stable: Mark as **Release** (not pre-release)

### Workflow Example

```
1. Start development:
   ./update-version.sh v2.27.7-dev.1
   → Updates files to use Docker tag v2.27.7
   → Creates Git tag v2.27.7-dev.1
   → Creates GitHub pre-release v2.27.7-dev.1

2. Iterate on testing:
   ./update-version.sh v2.27.7-dev.2
   → Updates files to use Docker tag v2.27.7
   → Creates Git tag v2.27.7-dev.2
   → Creates GitHub pre-release v2.27.7-dev.2

3. Release stable:
   ./update-version.sh v2.27.7
   → Updates files to use Docker tag v2.27.7
   → Creates Git tag v2.27.7
   → Creates GitHub release v2.27.7 (not pre-release)
```

### Version Comparison

Semver comparison rules apply:
- `v2.27.7-dev.1` < `v2.27.7-dev.2` < `v2.27.7`
- Development versions are considered "less than" stable versions
- This allows proper version ordering in package managers and Git

### Benefits

✅ **Semver Compliant**: Follows [Semantic Versioning 2.0.0](https://semver.org/) spec  
✅ **Clear Separation**: Development vs stable versions are easily distinguishable  
✅ **Multiple Iterations**: Can create multiple dev versions before stable release  
✅ **Tool Compatibility**: Works with Git, GitHub, and version comparison tools  
✅ **Docker Consistency**: Docker image tag stays consistent during development

