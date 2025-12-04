# unRAID Community Applications Submission Guide

This guide will help you submit the Coder template to the unRAID Community Applications repository.

## Prerequisites

Before submitting, ensure you have:

1. ✅ Tested the template on your unRAID server
2. ✅ Created a support thread on the unRAID forums
3. ✅ Verified all configuration options work correctly
4. ✅ Updated the README with clear instructions

## Step 1: Create Support Thread

1. Go to [unRAID Forums](https://forums.unraid.net/)
2. Navigate to the appropriate section (usually "Docker Containers" or "Community Applications")
3. Create a new thread with:
   - Title: "Coder - Remote Development Environments"
   - Description of the application
   - Installation instructions
   - Link to this repository
   - Basic troubleshooting tips

**Important**: Save the URL of your support thread - you'll need it for submission.

## Step 2: Prepare Your Repository

Ensure your repository includes:

- ✅ `coder.xml` - The unRAID template file
- ✅ `README.md` - Comprehensive documentation
- ✅ `LICENSE` - Appropriate license file
- ✅ `.gitignore` - Git ignore file

## Step 3: Host Your Template

The template XML file needs to be accessible via a direct URL. You can:

1. **Use GitHub Raw URL** (Recommended):
   - Upload `coder.xml` to your repository
   - Use URL: `https://raw.githubusercontent.com/ascheel/coder-unraid/main/coder.xml`
   - Update the `<TemplateURL>` in the XML if needed

2. **Use GitHub Releases**:
   - Create a release and attach the XML file
   - Use the release asset URL

## Step 4: Update Template URL (if needed)

If you're hosting the template on GitHub, update the `<TemplateURL>` tag in `coder.xml`:

```xml
<TemplateURL>https://raw.githubusercontent.com/ascheel/coder-unraid/main/coder.xml</TemplateURL>
```

## Step 5: Submit to Community Applications

1. Go to the [Community Applications Submission Form](https://forums.unraid.net/forum/137-community-applications/)
2. Fill out the submission form with:
   - **Application Name**: Coder
   - **Support Thread URL**: [Your forum thread URL]
   - **Template URL**: [Direct URL to your coder.xml file]
   - **Repository URL**: https://github.com/ascheel/coder-unraid
   - **Description**: Brief description of Coder
   - **Category**: Development Tools
   - **Icon URL**: https://coder.com/favicon.ico

3. Submit the form and wait for moderation team review (typically 24-48 hours)

## Step 6: After Submission

- Monitor your support thread for user questions
- Respond promptly to any issues
- **Version Management**: When Coder releases new versions, create matching template releases (see [VERSION_WORKFLOW.md](VERSION_WORKFLOW.md))
- Keep documentation up to date
- Maintain CHANGELOG.md with version history

## Template Testing Checklist

Before submitting, verify:

- [ ] Container starts successfully
- [ ] Web UI is accessible
- [ ] Data persists after container restart
- [ ] Docker socket access works (for workspace creation)
- [ ] Environment variables are configurable
- [ ] Port mapping works correctly
- [ ] Template displays correctly in unRAID UI

## Common Issues

### Template not appearing in unRAID
- Verify XML syntax is correct
- Check that TemplateURL is accessible
- Ensure file encoding is UTF-8

### Container fails to start
- Check Docker logs
- Verify port is not in use
- Ensure Docker socket permissions are correct

### Workspace creation fails
- Verify Docker socket is mounted correctly
- Check group permissions
- Ensure Docker is running on host

## Resources

- [unRAID Community Applications Documentation](https://docs.unraid.net/unraid-os/using-unraid-to/run-docker-containers/community-applications/)
- [Coder Documentation](https://coder.com/docs)
- [unRAID Forums](https://forums.unraid.net/)

## Notes

- The moderation team may request changes before approval
- Be patient during the review process
- Maintain your application after publication
- Keep Coder updated to the latest stable version

