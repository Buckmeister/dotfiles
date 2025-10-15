# Obsolete Web Hosting Files

**Status:** Archived (October 15, 2025)
**Reason:** Superseded by dedicated buckmeister.github.io repository

## What Was This?

This directory contains the old GitHub Pages setup that served web installers from the `/dotfiles/` subdirectory path.

### Old Setup (Using docs/ folder)
```
Repository: Buckmeister/dotfiles
GitHub Pages: Enabled (from docs/ folder)
URLs: https://buckmeister.github.io/dotfiles/dfauto
      https://buckmeister.github.io/dotfiles/dfsetup
```

**Problems:**
- Long, awkward URLs with `/dotfiles/` path
- Served from source repo docs/ folder
- Required repository-level GitHub Pages settings

### New Setup (Dedicated Repository)
```
Repository: Buckmeister/buckmeister.github.io (User Pages)
GitHub Pages: Automatic (root of repo)
URLs: https://buckmeister.github.io/dfauto  ✅ Clean!
      https://buckmeister.github.io/dfsetup  ✅ Clean!
```

**Benefits:**
- ✅ Shorter, memorable URLs (no `/dotfiles/` path)
- ✅ Dedicated repository for web hosting
- ✅ Automatic GitHub Pages deployment
- ✅ Cleaner separation of concerns

## What's Archived Here?

- **`docs/index.html`** - Old landing page with installation instructions
- **`docs/dfauto`** - Old copy of automatic installer (had wrong URLs)
- **`docs/dfsetup`** - Old copy of interactive installer (had wrong URLs)
- **`docs/dfauto.ps1`** - Old copy of Windows automatic installer
- **`docs/dfsetup.ps1`** - Old copy of Windows interactive installer

## Current Setup

**Source of Truth:** Root installer files in dotfiles repository
- `dfauto` - Unix automatic installer
- `dfsetup` - Unix interactive installer
- `dfauto.ps1` - Windows automatic installer
- `dfsetup.ps1` - Windows interactive installer

**Deployment:** Automated GitHub Actions workflow
- Workflow: `.github/workflows/sync-installers.yml`
- Target: `Buckmeister/buckmeister.github.io` repository
- Trigger: Push to main when installer files change
- Result: Installers automatically synced to GitHub Pages

**Landing Page:** Served from buckmeister.github.io repository
- `index.html` in root of buckmeister.github.io repo
- Automatically deployed via GitHub Pages
- Clean URLs without path prefix

## Timeline

- **Unknown Date:** Initial docs/ setup with `/dotfiles/` path
- **Commit db0880e:** URLs updated (incorrectly added `/dotfiles/` path)
- **Later:** Root installers corrected, docs/ forgotten
- **October 14, 2025:** Created buckmeister.github.io repository
- **October 15, 2025:** Archived docs/ directory (this archive)

## Why Archive Instead of Delete?

Preserving historical context:
- Shows evolution of web installer hosting approach
- Contains old index.html that might have useful content
- Maintains git history for reference
- Allows future recovery if needed

## References

- **Current Repository:** https://github.com/Buckmeister/dotfiles
- **GitHub Pages Site:** https://github.com/Buckmeister/buckmeister.github.io
- **Live Site:** https://buckmeister.github.io
- **Automation Workflow:** `.github/workflows/sync-installers.yml`

---

**Archived by:** Aria (Claude Code)
**Date:** October 15, 2025
**Commit:** Archive obsolete docs/ directory (old GitHub Pages setup)
