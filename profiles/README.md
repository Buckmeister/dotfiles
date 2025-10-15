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

## FAQ

**Q: Can I change my profile after running the wizard?**
A: Yes! Just run `./profile apply <profile>` to switch.

**Q: Do I have to choose a profile?**
A: No. You can select "None" in the wizard and configure everything manually.

**Q: Can I modify a profile after applying it?**
A: Yes. Profile settings are just starting points. Edit `~/.config/dotfiles/personal.env` anytime.

**Q: What if I want some features from multiple profiles?**
A: Create a custom profile that combines the features you want!

**Q: Will applying a profile overwrite my existing setup?**
A: Profiles only run specified post-install scripts. Your existing symlinks and configurations remain intact.

---

*Profiles make getting started with dotfiles faster and easier while still giving you full control over your environment. Choose a preset or create your own - the choice is yours!* 🌸
