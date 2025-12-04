# Hosting Icons on GitHub for unRAID Templates

This guide explains how to host your application icon on GitHub and reference it in your unRAID template.

## Step 1: Prepare Your Icon

1. **Recommended format**: PNG (64x64 or 128x128 pixels)
2. **File name**: Use a descriptive name like `coder-icon.png` or `icon.png`
3. **Location**: Create an `assets/` directory in your repository root

## Step 2: Add Icon to Repository

### Option A: Using Git Command Line

```bash
# Create assets directory (if it doesn't exist)
mkdir -p assets

# Add your icon file
git add assets/coder-icon.png

# Commit
git commit -m "Add Coder icon for unRAID template"

# Push to GitHub
git push origin main
```

### Option B: Using GitHub Web Interface

1. Navigate to your repository on GitHub
2. Click "Add file" → "Upload files"
3. Create or navigate to `assets/` folder
4. Upload your icon file
5. Commit the changes

## Step 3: Get the Raw URL

GitHub provides raw content URLs in this format:

```
https://raw.githubusercontent.com/USERNAME/REPO/BRANCH/PATH/TO/FILE
```

### For Your Repository

Based on your repository structure (`ascheel/coder-unraid`), the URL would be:

```
https://raw.githubusercontent.com/ascheel/coder-unraid/main/assets/coder-icon.png
```

**Replace:**
- `ascheel` → Your GitHub username
- `coder-unraid` → Your repository name
- `main` → Your default branch (could be `master`)
- `assets/coder-icon.png` → Path to your icon file

## Step 4: Update coder.xml

Update the `<Icon>` tag in your `coder.xml` file:

```xml
<Icon>https://raw.githubusercontent.com/ascheel/coder-unraid/main/assets/coder-icon.png</Icon>
```

## Step 5: Verify the URL

Test that the URL works by:
1. Opening the URL in a web browser
2. The image should display directly
3. If you see a GitHub page instead, check the URL format

## Best Practices

### ✅ Recommended Structure

```
coder-unraid/
├── assets/
│   ├── coder-icon.png      # Main icon (64x64 or 128x128)
│   └── coder-icon-large.png # Optional: larger version
├── coder.xml
└── README.md
```

### ✅ URL Tips

1. **Use main/master branch**: Avoid using commit SHAs for icons (they change)
2. **Keep it simple**: Use descriptive but short filenames
3. **PNG format**: Most compatible with unRAID
4. **Square aspect ratio**: Icons look best as squares

### ✅ Alternative: Using a Release Tag

For version-specific icons (if needed):

```
https://raw.githubusercontent.com/ascheel/coder-unraid/v2.28.5/assets/coder-icon.png
```

However, for icons, using `main` branch is usually fine since icons rarely change.

## Troubleshooting

### Icon Not Displaying

1. **Check URL**: Make sure the URL is correct and accessible
2. **File exists**: Verify the file is in the repository
3. **Branch name**: Ensure you're using the correct branch name
4. **File format**: Confirm it's a supported format (PNG, SVG, ICO, WEBP)

### Testing the URL

```bash
# Test if URL is accessible
curl -I https://raw.githubusercontent.com/ascheel/coder-unraid/main/assets/coder-icon.png

# Should return HTTP 200 OK
```

## Example: Complete Workflow

```bash
# 1. Create assets directory
mkdir -p assets

# 2. Add your icon (assuming you have coder-icon.png)
cp /path/to/coder-icon.png assets/

# 3. Update coder.xml
# Edit coder.xml and change:
# <Icon>https://coder.com/favicon.ico</Icon>
# To:
# <Icon>https://raw.githubusercontent.com/ascheel/coder-unraid/main/assets/coder-icon.png</Icon>

# 4. Commit and push
git add assets/coder-icon.png coder.xml
git commit -m "Add Coder icon hosted on GitHub"
git push origin main
```

## Current Setup

Your template currently uses:
```xml
<Icon>https://coder.com/favicon.ico</Icon>
```

This works, but hosting on GitHub gives you:
- ✅ Full control over the icon
- ✅ Version control for icon changes
- ✅ No dependency on external sites
- ✅ Consistent with your template hosting

