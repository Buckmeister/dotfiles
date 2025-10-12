# Package Mapping: macOS Homebrew → Linux APT

This document maps Thomas's macOS Homebrew packages to their Linux APT equivalents and alternatives.

## 📦 Direct APT Equivalents

| Homebrew Package | APT Package | Notes |
|------------------|-------------|-------|
| `cmake` | `cmake` | Same name |
| `cowsay` | `cowsay` | Same name |
| `figlet` | `figlet` | Same name |
| `git` | `git` | Same name |
| `gnupg` | `gnupg` | Same name |
| `htop` | `htop` | Same name |
| `jq` | `jq` | Same name |
| `maven` | `maven` | Same name |
| `neofetch` | `neofetch` | Same name |
| `python@3.8` | `python3` | Default Python 3 |
| `ranger` | `ranger` | Same name |
| `subversion` | `subversion` | Same name |
| `telnet` | `telnet` | Same name |
| `tmux` | `tmux` | Same name |
| `wget` | `wget` | Same name |

## 🔄 Different Package Names

| Homebrew Package | APT Package | Command/Notes |
|------------------|-------------|---------------|
| `fd` | `fd-find` | Command: `fdfind` |
| `ipython` | `ipython3` | Python 3 version |
| `most` | `most` | Available in apt |
| `black` | `python3-black` | Or via pip |
| `flake8` | `flake8` or `python3-flake8` | |

## 🏗️ Alternative Installation Methods

### Via Rust Cargo
- `eza` (modern `ls` replacement)
- `bat-extras`
- `rust-analyzer`

### Via NPM (Node.js)
- `@angular/cli`
- `http-server`
- `typescript-language-server`
- `vscode-langservers-extracted`

### Via Python pip/pipx
- `black`
- `python-lsp-server`
- `httpie` + `httpie-jwt-auth`

### Via Direct Download/Script
- `starship` (shell prompt)
- `fzf` (fuzzy finder)
- `neovim` (AppImage)
- `gh` (GitHub CLI - via official repo)
- `docker` (via get.docker.com)

### Via Snap (if available)
- `code` (Visual Studio Code)
- `brave`
- `postman`
- `skype`
- `blender`
- `alacritty`

### Via Flatpak (if available)
- `org.mozilla.firefox`
- `com.getpostman.Postman`
- `org.blender.Blender`

## 🚫 macOS-Specific (No Linux Equivalent)

| Package | Linux Alternative |
|---------|-------------------|
| `amethyst` | i3, sway, bspwm (window managers) |
| `hammerspoon` | autokey, espanso |
| `karabiner-elements` | xmodmap, setxkbmap |
| `sizeup` | Built into modern window managers |
| `macos-trash` | `trash-cli` package |

## 🎨 Fonts

| Homebrew Font | Linux Installation |
|---------------|-------------------|
| `font-fira-code` | `fonts-firacode` (apt) |
| `font-jetbrains-mono` | `fonts-jetbrains-mono` (apt) |
| Nerd Fonts | Manual download from GitHub |

## 🖥️ GUI Applications

### Browsers
- **Chrome**: Direct download from Google
- **Firefox**: `firefox-esr` (apt)
- **Brave**: Snap or direct download
- **Tor Browser**: Direct download

### Development
- **Visual Studio Code**: Snap, Flatpak, or .deb
- **Postman**: Snap, Flatpak, or AppImage

### Terminal Emulators
- **kitty**: Available in apt
- **alacritty**: Snap, cargo, or AppImage
- **wezterm**: AppImage or build from source

## 🛠️ Language-Specific Tools

### Haskell
- `ghc` → `ghc`
- `haskell-stack` → `haskell-stack`
- `hlint` → `hlint`

### Ruby
- `solargraph` → Install via gem

### Python
- Most tools available via apt or pip
- Use `pipx` for isolated tool installation

### Rust
- Install via `rustup` (not apt packages)

## 📋 Installation Strategy

1. **Install base APT packages**: Use `packages-updated.list`
2. **Run special installer**: Execute `install-special-packages.zsh`
3. **Manual installations**: For remaining GUI apps and fonts

## 🔧 Post-Installation Configuration

Some tools may need additional setup:
- Docker: Add user to docker group
- Fonts: Refresh font cache with `fc-cache -fv`
- Shell: Configure zsh, starship, etc.
- Language servers: May need additional configuration

This mapping provides ~85% coverage of your macOS setup on Linux systems!