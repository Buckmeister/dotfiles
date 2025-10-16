# Configuration Profiles

This directory contains pre-configured dotfiles profiles for different use cases. Profiles provide a quick way to set up your development environment with sensible defaults.

## Available Profiles

### 🎯 Minimal (`minimal.yaml`)
**Perfect for:**
- Resource-constrained systems
- Quick setup on temporary machines
- Users who want manual control over additions
- Minimal bloat, maximum control

**Includes:**
- Essential editor setup (Neovim/Vim)
- Basic shell configuration
- Core language servers (Python, Lua)
- Minimal package installation

---

### ⭐ Standard (`standard.yaml`)
**Perfect for:**
- Most developers
- Balanced feature set
- Production-ready development environment
- Recommended default

**Includes:**
- Full editor setup with plugins
- Complete shell configuration
- Language servers for common languages (Python, JavaScript, Rust, Go, Lua)
- Recommended package set
- Essential development tools

---

### 🚀 Full (`full.yaml`)
**Perfect for:**
- Power users who want everything
- Primary development machine
- Users comfortable with large installations
- Maximum features and tools

**Includes:**
- All post-install scripts
- All language servers
- All development toolchains
- Full package set with optional tools
- All language ecosystems

---

### 💼 Work (`work.yaml`)
**Perfect for:**
- Corporate/professional development
- Focus on productivity tools
- Common enterprise languages
- Clean, professional setup

**Includes:**
- Professional editor setup
- Enterprise language support (Java, JavaScript, Python, TypeScript)
- Essential productivity tools
- Documentation and collaboration tools

---

### 🎨 Personal (`personal.yaml`)
**Perfect for:**
- Personal coding projects
- Learning new languages
- Experimentation and fun
- Side projects and hobbies

**Includes:**
- Comfortable editor setup
- Support for modern languages (Rust, Go, Python, JavaScript)
- Focus on developer experience
- Tools for exploration and learning

---

## Using Profiles

### Interactive Wizard
The easiest way to use profiles is through the interactive wizard:

```bash
cd ~/.config/dotfiles
./wizard
```

The wizard will prompt you to select a profile early in the setup process. If you choose a profile, it will pre-fill your configuration settings (which you can still modify).

### Profile Manager
You can also manage profiles directly using the profile manager:

```bash
# List all available profiles
./profile list

# Show detailed information about a profile
./profile show standard

# Apply a profile (run its post-install scripts)
./profile apply work

# Check currently active profile
./profile current
```

### Manual Selection
If you want to manually configure based on a profile, simply read the YAML file:

```bash
cat profiles/standard.yaml
```

Then use those settings when running setup scripts.

## Profile Structure

Each profile is defined in a YAML file with the following structure:

```yaml
name: profile_name
description: "Brief description of the profile"
emoji: "🎯"

post_install_scripts:
  - vim-setup.zsh
  - language-servers.zsh
  - fonts.zsh

packages:
  manifest: profiles/manifests/profile-packages.yaml
  level: recommended  # minimal, recommended, or full

settings:
  editor: nvim
  shell: zsh
  theme: onedark

dev_languages:
  - python
  - javascript
  - rust

features:
  fonts: true
  toolchains: false
  cargo_packages: false
```

### Package Manifests

**New in 2025**: Each profile now references a declarative package manifest that defines exactly which packages to install. This makes profiles fully reproducible and cross-platform.

- **Location**: `profiles/manifests/`
- **Format**: YAML manifest following the universal package management schema
- **Benefit**: One profile = complete, reproducible environment (packages + post-install scripts)

When you apply a profile with `./profile apply <name>`, it will:
1. Install all packages from the manifest (via `install_from_manifest`)
2. Run all post-install scripts
3. Save the profile as current

## Creating Custom Profiles

You can create your own custom profile:

1. Copy an existing profile as a template:
   ```bash
   cp profiles/standard.yaml profiles/custom.yaml
   ```

2. Edit the profile to your liking:
   ```bash
   nvim profiles/custom.yaml
   ```

3. Use your custom profile:
   ```bash
   ./profile show custom
   ./profile apply custom
   ```

## Profile Settings

### Package Levels
- **minimal** (`required`): Only essential packages
- **recommended**: Essential + commonly used tools
- **full** (`optional`): Everything including optional tools

### Post-Install Scripts
Available scripts from `post-install/scripts/`:
- `vim-setup.zsh` - Vim/Neovim plugin installation
- `bash-preexec.zsh` - Bash preexec hook
- `language-servers.zsh` - LSP servers (JDT.LS, rust-analyzer, etc.)
- `toolchains.zsh` - Language toolchains (Rust, Haskell, etc.)
- `fonts.zsh` - Font installation
- `lombok.zsh` - Java Lombok
- `cargo-packages.zsh` - Rust packages via cargo
- `npm-global-packages.zsh` - Node.js global packages
- `pip-packages.zsh` - Python packages via pip
- `ruby-gems.zsh` - Ruby gems

### Development Languages
Supported language identifiers:
- `python`, `javascript`, `typescript`
- `rust`, `go`, `java`, `ruby`
- `c`, `cpp`, `haskell`, `lua`
- `php`, `swift`, `kotlin`, `scala`, `r`, `elixir`

### Feature Flags
Boolean flags to enable/disable features:
- `fonts` - Install fonts
- `toolchains` - Install language toolchains
- `cargo_packages` - Install Rust packages
- `npm_packages` - Install Node.js packages
- `pip_packages` - Install Python packages
- `ruby_gems` - Install Ruby gems

## Integration with Wizard

The wizard integrates profiles seamlessly:

1. **Step 3** of the wizard prompts you to select a profile
2. If you choose a profile, it pre-fills settings (editor, shell, theme, languages, etc.)
3. You can still modify any pre-filled setting in subsequent steps
4. Your chosen profile is saved to `~/.config/dotfiles/personal.env`
5. At completion, the wizard offers to generate a **custom package manifest** based on your choices
6. The wizard shows you how to apply your profile or install from your custom manifest

### Custom Manifest Generation

The wizard can generate a personalized package manifest (new feature!):

```bash
./bin/wizard.zsh
# → Follow prompts and select preferences
# → At completion, choose "yes" to generate custom manifest
# → Creates: ~/.config/dotfiles/my-packages.yaml
```

Your custom manifest includes:
- Core essentials (git, curl, shell)
- Your chosen editor (nvim, vim, emacs)
- Modern CLI tools (ripgrep, fd, bat, etc.) based on package level
- Language-specific packages based on your dev_languages selection
- Optional tools if you selected "full" package level

Install your custom manifest anytime:
```bash
install_from_manifest -i ~/.config/dotfiles/my-packages.yaml
```

## Complete Workflow Examples

### Example 1: First-Time Setup with Standard Profile

**Scenario:** You're setting up dotfiles on a new development machine and want a balanced, production-ready environment.

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# Run the interactive wizard
./wizard

# Wizard prompts:
# → Welcome message
# → Select profile: [minimal, standard, full, work, personal, custom, none]
#   Choose: "standard" ⭐

# → Editor preference: [nvim, vim, emacs, nano, none]
#   Pre-filled: nvim (from profile, you can change)

# → Shell preference: [zsh, bash, fish]
#   Pre-filled: zsh (from profile, you can change)

# → Development languages: [python, javascript, rust, go, ...]
#   Pre-filled: python, javascript, rust, go, lua (from profile)
#   Add/remove as needed

# → Package level: [minimal, recommended, full]
#   Choose: "recommended" (balanced)

# → Generate custom manifest: [yes, no]
#   Choose: "yes" to create ~/.config/dotfiles/my-packages.yaml

# Installation begins:
# 1. Symlinks created
# 2. Packages installed from manifest
# 3. Post-install scripts executed
# 4. Profile saved as current

# Verify installation
./profile current
# Output: Current profile: standard

# Check what was installed
./librarian
# Shows comprehensive system status
```

**Result:** Full development environment with Neovim, language servers (Python, JavaScript, Rust, Go, Lua), recommended packages, and all standard configurations.

---

### Example 2: Minimal Profile for Docker Container

**Scenario:** You need a lightweight dotfiles setup for a Docker development container.

```bash
# In your Dockerfile or container
RUN git clone https://github.com/yourusername/dotfiles.git ~/.config/dotfiles && \
    cd ~/.config/dotfiles && \
    ./profile apply minimal

# Or using the wizard non-interactively (future feature):
# export DOTFILES_PROFILE=minimal
# ./setup --auto

# Verify minimal installation
./profile current
# Output: Current profile: minimal

# Check installed scripts (should be minimal)
ls -la ~/.config/dotfiles/post-install/scripts/*.zsh | wc -l
# Only 3-4 essential scripts

# Total installation time: ~2-3 minutes (vs 10-15 for full)
# Disk space: ~50-100 MB (vs 500+ MB for full)
```

**Result:** Lightweight setup with just essential tools (Neovim, basic shell, minimal packages), perfect for containers.

---

### Example 3: Switching from Work to Personal Profile

**Scenario:** You have a shared machine used for both work and personal projects. You want to switch profiles based on context.

```bash
# Currently on work profile
./profile current
# Output: Current profile: work

# Switch to personal profile for weekend project
./profile apply personal

# What happens:
# 1. Installs packages from personal.yaml manifest (if missing)
# 2. Runs personal profile's post-install scripts
# 3. Updates current profile

# Verify the switch
./profile current
# Output: Current profile: personal

# Check what changed
git diff ~/.config/dotfiles/personal.env
# Shows profile changed from 'work' to 'personal'

# Personal profile now active:
# - Rust, Go, Python, JavaScript support
# - Experimentation tools
# - Personal editor plugins
# - Different package set

# Switch back to work profile on Monday
./profile apply work
```

**Result:** Seamless context switching between work and personal development environments.

---

### Example 4: Custom Profile from Wizard

**Scenario:** You want a tailored setup with specific languages and tools.

```bash
cd ~/.config/dotfiles
./wizard

# Select "custom" profile (or "none" and configure manually)
# → Editor: nvim
# → Shell: zsh
# → Languages: python, javascript, java, lua
# → Package level: full
# → Generate custom manifest: yes

# Wizard creates:
# - ~/.config/dotfiles/my-packages.yaml (custom manifest)
# - ~/.config/dotfiles/personal.env (with your preferences)

# Review your custom manifest
cat ~/.config/dotfiles/my-packages.yaml

# Install packages from custom manifest
install_from_manifest -i ~/.config/dotfiles/my-packages.yaml

# Run specific post-install scripts manually
./post-install/scripts/language-servers.zsh
./post-install/scripts/npm-global-packages.zsh

# Save as reusable custom profile
cp profiles/standard.yaml profiles/mycustom.yaml
# Edit mycustom.yaml to match your preferences

# Future machines: just apply your custom profile
./profile apply mycustom
```

**Result:** Fully personalized environment saved as a reusable profile for future machines.

---

### Example 5: Profile + Manual Additions

**Scenario:** You want the standard profile but with extra tools for specific projects.

```bash
# Apply standard profile first
./profile apply standard

# Verify base installation
./librarian

# Add project-specific tools manually
./post-install/scripts/cargo-packages.zsh  # Add Rust tools
./post-install/scripts/ruby-gems.zsh       # Add Ruby tools

# Install additional packages via manifest
# Create project-specific manifest
cat > ~/my-project-packages.yaml <<EOF
name: "my-project-extras"
packages:
  brew:
    - postgresql
    - redis
  npm:
    - '@angular/cli'
    - typescript
EOF

# Install project extras
install_from_manifest -i ~/my-project-packages.yaml

# Profile remains "standard" but with additions
./profile current
# Output: Current profile: standard

# Optionally save as new profile
cp profiles/standard.yaml profiles/myproject.yaml
# Edit to include project-specific scripts and packages
```

**Result:** Standard base with project-specific customizations, optionally saved as new profile.

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: Profile application fails with "manifest not found"

**Symptoms:**
```bash
./profile apply work
Error: Package manifest not found: profiles/manifests/work-packages.yaml
```

**Cause:** Profile references a manifest that doesn't exist or path is incorrect.

**Solution:**
```bash
# Check if manifest directory exists
ls -la profiles/manifests/

# Check profile YAML for correct manifest path
cat profiles/work.yaml | grep manifest

# If manifest is missing, create it or update profile to use existing manifest
# Option 1: Create the missing manifest
cp profiles/manifests/standard-packages.yaml profiles/manifests/work-packages.yaml
# Edit work-packages.yaml to customize

# Option 2: Update profile to reference existing manifest
nvim profiles/work.yaml
# Change: manifest: profiles/manifests/existing-packages.yaml
```

---

#### Issue: Post-install scripts not running when applying profile

**Symptoms:**
```bash
./profile apply standard
# Profile applied but no post-install scripts executed
./librarian
# Shows scripts as "not run"
```

**Cause:** Profile may not specify post-install scripts, or scripts have .ignored/.disabled markers.

**Solution:**
```bash
# Check profile definition
cat profiles/standard.yaml | grep -A 10 post_install_scripts

# If missing, add scripts to profile YAML:
nvim profiles/standard.yaml
# Add:
# post_install_scripts:
#   - vim-setup.zsh
#   - language-servers.zsh

# Check for marker files that disable scripts
ls -la post-install/scripts/*.ignored
ls -la post-install/scripts/*.disabled

# Remove markers if they're preventing execution
rm post-install/scripts/*.ignored

# Re-apply profile
./profile apply standard
```

---

#### Issue: Switching profiles doesn't install new packages

**Symptoms:**
```bash
./profile apply full  # from minimal
# Executes quickly, but packages seem missing
```

**Cause:** Profile manager only runs post-install scripts by default, not package installation.

**Solution:**
```bash
# Manually install packages from the profile's manifest
# Check profile for manifest path
cat profiles/full.yaml | grep manifest

# Install from manifest explicitly
install_from_manifest -i profiles/manifests/full-packages.yaml

# Or run full setup
./setup  # Re-runs everything including package installation

# Future enhancement: ./profile apply should handle packages automatically
```

---

#### Issue: Custom manifest generation fails in wizard

**Symptoms:**
```bash
./wizard
# ... wizard completes, choose "yes" for custom manifest
Error: Failed to generate custom manifest
```

**Cause:** Missing dependencies, write permissions, or wizard.zsh bug.

**Solution:**
```bash
# Check write permissions in dotfiles directory
ls -la ~/.config/dotfiles/
# Should be writable by your user

# Check if manifest directory exists
mkdir -p ~/.config/dotfiles/packages/

# Check wizard.zsh for errors
./bin/wizard.zsh --help

# Run wizard with verbose output (if supported)
./wizard --verbose

# Create manifest manually using the wizard output as guide
cat > ~/.config/dotfiles/my-packages.yaml <<EOF
# Manual manifest based on your wizard selections
name: "my-custom-environment"
packages:
  brew:
    - git
    - curl
    - neovim
EOF

# Test manifest installation
install_from_manifest -i ~/.config/dotfiles/my-packages.yaml
```

---

#### Issue: Profile seems to use wrong package level

**Symptoms:**
```bash
./profile show standard
# Shows: level: recommended

# But installation includes "optional" packages
```

**Cause:** Package level filtering might not be working, or manifest includes all priorities.

**Solution:**
```bash
# Check the actual manifest content
cat profiles/manifests/standard-packages.yaml | grep -A 5 priority

# Ensure packages have correct priority tags
# Edit manifest to fix priorities:
nvim profiles/manifests/standard-packages.yaml

# Look for packages marked as "optional" that should be "recommended"
# Update priorities as needed

# Test with explicit level filter
install_from_manifest -i profiles/manifests/standard-packages.yaml --level recommended

# Update profile if needed
nvim profiles/standard.yaml
# Ensure: level: recommended
```

---

#### Issue: Can't find which profile was used

**Symptoms:**
```bash
./profile current
# Error: No profile information found
```

**Cause:** Profile not saved to personal.env, or personal.env missing.

**Solution:**
```bash
# Check if personal.env exists
ls -la ~/.config/dotfiles/personal.env

# Check if DOTFILES_PROFILE is set
cat ~/.config/dotfiles/personal.env | grep DOTFILES_PROFILE

# If missing, determine which profile you want
./profile list

# Set profile manually
echo 'export DOTFILES_PROFILE="standard"' >> ~/.config/dotfiles/personal.env

# Or re-apply a profile to save it
./profile apply standard
```

---

### Debugging Tips

**Check profile structure:**
```bash
# Validate YAML syntax
cat profiles/standard.yaml

# Check for required fields
grep -E "(name|description|post_install_scripts|packages)" profiles/standard.yaml
```

**Verify manifest paths:**
```bash
# List all manifests
ls -la profiles/manifests/

# Check manifest content
cat profiles/manifests/standard-packages.yaml | head -20
```

**Test profile components individually:**
```bash
# Test package installation
install_from_manifest -i profiles/manifests/minimal-packages.yaml --dry-run

# Test post-install scripts one by one
./post-install/scripts/vim-setup.zsh --help
./post-install/scripts/vim-setup.zsh
```

**Check logs:**
```bash
# Profile manager logs (if implemented)
cat ~/.cache/dotfiles/profile.log

# Wizard logs (if implemented)
cat ~/.cache/dotfiles/wizard.log
```

---

## FAQ

**Q: Can I change my profile after running the wizard?**
A: Yes! Just run `./profile apply <profile>` to switch profiles anytime.

**Q: Do I have to choose a profile?**
A: No. You can select "None" in the wizard and configure everything manually. Profiles are optional conveniences.

**Q: Can I modify a profile after applying it?**
A: Yes. Profile settings are just starting points. Edit `~/.config/dotfiles/personal.env` anytime to change preferences.

**Q: What if I want some features from multiple profiles?**
A: Create a custom profile that combines the features you want! Copy an existing profile as a template and customize it.

**Q: Will applying a profile overwrite my existing setup?**
A: Profiles only run specified post-install scripts and install packages from manifests. Your existing symlinks and configurations remain intact. It's safe to switch profiles.

**Q: What's the difference between profile and package manifest?**
A: A **profile** is a complete environment definition (scripts + packages + settings). A **manifest** is just the package list. Profiles reference manifests for their package installation.

**Q: Can I use profiles with Docker/CI/CD?**
A: Yes! Use `./profile apply <name>` in your Dockerfile or CI scripts. The minimal profile is perfect for containers.

**Q: How do I share my custom profile with my team?**
A: Commit your custom profile YAML and manifest to your dotfiles repo, then your team can `./profile apply yourcustom`.

---

## Cross-References

- **Package Management:** [`../packages/README.md`](../packages/README.md) - Universal package system details
- **Package Schema:** [`../packages/SCHEMA.md`](../packages/SCHEMA.md) - Manifest file format
- **Wizard Guide:** [`../bin/wizard.md`](../bin/wizard.md) - Interactive setup wizard (if exists)
- **Profile Manager Code:** [`../bin/profile_manager.zsh`](../bin/profile_manager.zsh) - Implementation details
- **Main README:** [`../README.md`](../README.md#profiles) - Quick start with profiles

---

*Profiles make getting started with dotfiles faster and easier while still giving you full control over your environment. Choose a preset or create your own - the choice is yours!* 🌸
