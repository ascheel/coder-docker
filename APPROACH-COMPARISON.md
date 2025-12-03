# Approach Comparison: Docker Image Modification vs Post-Install Script

## Option 1: Custom Docker Image (Modify Base Image)

### How It Works
- Fork the official Coder Docker image
- Add template import logic to the entrypoint
- Build and publish a custom image (e.g., `ghcr.io/ascheel/coder-unraid:v2.27.7`)
- Update `coder.xml` to use the custom image

### Pros
- ✅ Fully automated - no user intervention needed
- ✅ Template imports automatically on first start
- ✅ Works seamlessly with Community Applications

### Cons
- ❌ **Maintenance burden** - Must rebuild image for every Coder version update
- ❌ **Version lag** - Users wait for you to rebuild when new Coder versions release
- ❌ **Complexity** - Requires Docker build pipeline, CI/CD, image hosting
- ❌ **Security** - Users must trust your custom image instead of official Coder image
- ❌ **Breaking changes** - If Coder changes entrypoint, your image may break
- ❌ **Storage** - Need to host/store custom images
- ❌ **Updates** - Users can't easily get official Coder updates

### Implementation Example
```dockerfile
FROM ghcr.io/coder/coder:v2.27.7

COPY entrypoint-wrapper.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint-wrapper.sh

ENTRYPOINT ["/usr/local/bin/entrypoint-wrapper.sh"]
```

## Option 2: Entrypoint Wrapper (Mount Script, Don't Modify Image)

### How It Works
- Keep using official Coder image
- Create a wrapper script that runs Coder + template import
- Mount the script and use it as entrypoint via `ExtraParams` in `coder.xml`

### Pros
- ✅ Uses official Coder image (no maintenance)
- ✅ Automatic template import
- ✅ No custom image to maintain
- ✅ Users get official Coder updates

### Cons
- ⚠️ More complex `coder.xml` configuration
- ⚠️ Script must be available on host
- ⚠️ Entrypoint override can be fragile

### Implementation Example
```xml
<ExtraParams>--entrypoint /home/coder/.config/entrypoint-wrapper.sh --group-add $(stat -c %g /var/run/docker.sock)</ExtraParams>
```

## Option 3: Post-Install Script (Current Approach)

### How It Works
- Use official Coder image as-is
- Provide a script users run after installation
- Script handles template import

### Pros
- ✅ **Zero maintenance** - Uses official image directly
- ✅ **Always up-to-date** - Users get latest Coder versions automatically
- ✅ **Simple** - No custom images or complex entrypoints
- ✅ **Transparent** - Users see exactly what happens
- ✅ **Flexible** - Users can customize or skip
- ✅ **Works with CA** - Standard Community Applications workflow

### Cons
- ⚠️ Requires one command after installation
- ⚠️ Not fully "zero-touch"

## Option 4: Init Container / Sidecar Pattern

### How It Works
- Run Coder container normally
- Run a separate "init" container that waits for Coder and imports template
- Use docker-compose or multiple containers

### Pros
- ✅ Uses official Coder image
- ✅ Separation of concerns

### Cons
- ❌ Complex for unRAID (requires multiple containers)
- ❌ Not well-suited for Community Applications templates
- ❌ More moving parts

## Recommendation: **Option 3 (Post-Install Script)** for Community Applications

### Why?

1. **Community Applications Best Practice**
   - CA templates should use official images when possible
   - Custom images create maintenance burden for template maintainers
   - Users expect to get official updates

2. **Maintenance Reality**
   - Coder releases frequently
   - Maintaining a custom image means rebuilding for every release
   - Version pinning becomes a burden

3. **User Experience**
   - One command (`curl ... | bash`) is acceptable
   - Many CA apps require post-install steps
   - Users can see what's happening

4. **Flexibility**
   - Users can customize the template before importing
   - Users can skip if they want different setup
   - Easy to update script without rebuilding images

## Alternative: Hybrid Approach

If you want automation without image maintenance, consider **Option 2 (Entrypoint Wrapper)**:

1. Create `entrypoint-wrapper.sh` in the repository
2. Users copy it to `/mnt/user/appdata/coder/` during installation
3. Update `coder.xml` to use it as entrypoint
4. Script runs Coder + auto-imports template

This gives automation without custom image maintenance.

## Decision Matrix

| Factor | Custom Image | Entrypoint Wrapper | Post-Install Script |
|--------|-------------|-------------------|---------------------|
| Automation | ✅ Full | ✅ Full | ⚠️ One command |
| Maintenance | ❌ High | ✅ Low | ✅ None |
| User Updates | ❌ Manual | ✅ Automatic | ✅ Automatic |
| Complexity | ❌ High | ⚠️ Medium | ✅ Low |
| CA Best Practice | ❌ No | ⚠️ Acceptable | ✅ Yes |
| Trust/Security | ⚠️ Custom | ✅ Official | ✅ Official |

## Conclusion

For Community Applications, **post-install script (Option 3)** is most appropriate because:
- Maintains use of official Coder images
- Zero maintenance burden
- Follows CA best practices
- Simple and transparent

If full automation is critical, **entrypoint wrapper (Option 2)** is a good compromise that provides automation without custom image maintenance.

