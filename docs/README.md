# GitHub Pages Setup

This directory contains a beautiful landing page for your dotfiles installation.

## 🌐 Enabling GitHub Pages

To make your installation accessible at `https://USERNAME.github.io/dotfiles`:

### Option 1: Via GitHub Web Interface (Easiest)

1. Go to your repository on GitHub
2. Click **Settings** (gear icon)
3. Scroll down to **Pages** in the left sidebar
4. Under **Source**, select:
   - Branch: `main`
   - Folder: `/docs`
5. Click **Save**
6. Wait ~1 minute for deployment
7. Your site will be live at: `https://USERNAME.github.io/dotfiles`

### Option 2: Via GitHub CLI

```bash
# Enable GitHub Pages
gh repo edit --enable-pages --pages-branch main --pages-path /docs

# Check status
gh api repos/:owner/:repo/pages
```

## 🎨 Features

The landing page (`index.html`) includes:

- ✅ **Platform detection** - Auto-selects macOS/Linux or Windows
- ✅ **OneDark theme** - Matches your dotfiles aesthetic
- ✅ **Copy buttons** - One-click copying of installation commands
- ✅ **Responsive design** - Works on mobile and desktop
- ✅ **Direct links** - To GitHub repo, README, and INSTALL.md

## 🔗 Short URLs

Once GitHub Pages is enabled, you can share:

**Instead of:**
```
https://raw.githubusercontent.com/USERNAME/dotfiles/main/install.sh
```

**Use:**
```
https://USERNAME.github.io/dotfiles
```

Much more memorable! Users can copy the installation command directly from the landing page.

## 🎯 Custom Domain (Optional)

Want to use your own domain like `dotfiles.yourdomain.com`?

1. Add a `CNAME` file in this directory:
   ```bash
   echo "dotfiles.yourdomain.com" > docs/CNAME
   ```

2. Add a CNAME record in your DNS settings:
   ```
   CNAME: dotfiles -> USERNAME.github.io
   ```

3. Wait for DNS propagation (~5-60 minutes)

4. Enable HTTPS in GitHub Pages settings

## 📝 Customization

Edit `index.html` to customize:

- **Repository URL**: Update all `Buckmeister/dotfiles` references
- **Colors**: Modify CSS variables in `:root`
- **Features**: Update the feature list
- **Links**: Add or remove buttons

## 🚀 Testing Locally

To preview before pushing:

```bash
# Simple Python server
cd docs
python3 -m http.server 8000

# Open http://localhost:8000 in your browser
```

## 💡 Benefits

- **Professional presentation** - Beautiful landing page for your dotfiles
- **Easy sharing** - Shorter, more memorable URLs
- **Platform awareness** - Auto-detects and shows appropriate commands
- **SEO friendly** - Can be indexed by search engines
- **Free hosting** - No external server or cost required

---

**Pro tip:** After enabling GitHub Pages, update your repository description to include the GitHub Pages URL!
