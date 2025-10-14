# Dotfiles Configuration Manual

> A comprehensive guide to the applications, configurations, and utility scripts in this dotfiles repository

**For installation and setup instructions, see [README.md](README.md) and [INSTALL.md](INSTALL.md).**

## Table of Contents

- [Overview](#overview)
- [Shell Configurations](#shell-configurations)
  - [Zsh (Primary Shell)](#zsh-primary-shell)
  - [Bash (Backup Shell)](#bash-backup-shell)
  - [Shared Aliases](#shared-aliases)
  - [Starship Prompt](#starship-prompt)
- [Terminal Multiplexer](#terminal-multiplexer)
  - [Tmux](#tmux)
- [Editor Configurations](#editor-configurations)
  - [Neovim](#neovim)
  - [Vim](#vim)
  - [Emacs](#emacs)
- [Terminal Emulators](#terminal-emulators)
  - [Kitty (Primary)](#kitty-primary)
  - [Alacritty (Alternative)](#alacritty-alternative)
- [Development Tools](#development-tools)
  - [Git](#git)
  - [IPython](#ipython)
  - [Language-Specific Configs](#language-specific-configs)
- [Utility Scripts](#utility-scripts)
  - [GitHub Tools](#github-tools)
  - [System Utilities](#system-utilities)
  - [Recording & Screenshots](#recording--screenshots)
- [System Integration](#system-integration)
  - [Karabiner (macOS Keyboard Remapping)](#karabiner-macos-keyboard-remapping)
- [Appendix](#appendix)
  - [Color Scheme](#color-scheme)
  - [Fonts](#fonts)
  - [File Locations](#file-locations)

---

## Overview

This manual documents the **configurations and tools** provided by the dotfiles repository, NOT the dotfiles management system itself (which is covered in [README.md](README.md) and [INSTALL.md](INSTALL.md)).

After running the setup, you'll have access to:
- A powerful shell environment with vi-mode keybindings
- Terminal multiplexer with custom status bar
- Multiple editor configurations (Neovim, Vim, Emacs)
- Modern terminal emulators with beautiful themes
- Utility scripts for GitHub downloads, system monitoring, and more

**Design Philosophy:**
- **OneDark Color Scheme** - Consistent across all applications
- **Vi-Mode Keybindings** - Muscle memory across shell, editor, and multiplexer
- **Nerd Fonts** - Beautiful icons and symbols
- **Cross-Platform** - Works on macOS and Linux

---

## Shell Configurations

### Zsh (Primary Shell)

**Location:** `~/.zshrc` (symlinked from `zsh/zshrc.symlink`)
**Project:** [Zsh](https://www.zsh.org/) | **Shell:** Modern, powerful shell with advanced features

Zsh is configured as the primary shell with extensive customizations.

#### Features

**Plugin Management:**
- Uses **[zplug](https://github.com/zplug/zplug)** for plugin management
- Auto-installs missing plugins on first run

**Installed Plugins:**
- **[zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)** - Search history with substring matching
- **[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)** - Fish-like autosuggestions (suggestions based on history)
- **[zsh-completions](https://github.com/zsh-users/zsh-completions)** - Additional completion definitions
- **[zsh-nvm](https://github.com/lukechilds/zsh-nvm)** - Node Version Manager integration
- **[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)** - Fish-like syntax highlighting
- **[zsh-fzy](https://github.com/aperezdc/zsh-fzy)** - Fuzzy finder integration with **[fzy](https://github.com/jhawthorn/fzy)**

**Vi-Mode Enhancements:**
- Vi keybindings enabled by default
- Custom cursor shapes for insert/normal mode (via ZSH-VI-Mode-Cursor)
- Menu completion with hjkl navigation

#### Key Bindings

**Insert Mode:**
- `kj` or `jk` - Exit insert mode (escape alternative)
- `Ctrl+g` - Insert last word forward
- `Ctrl+h` - Insert last word
- `Ctrl+Space` - Accept autosuggestion
- `Ctrl+Enter` - Accept and execute autosuggestion

**Normal Mode (Vicmd):**
- `k` / `j` - History substring search up/down
- `ö` - Show buffer contents (debugging)
- `gd` - Fuzzy cd (directory navigation)
- `gf` - Fuzzy file picker
- `gh` - Fuzzy history search
- `gp` - Fuzzy process picker

**Menu Completion:**
- `h` / `l` - Navigate left/right
- `j` / `k` - Navigate up/down

#### Custom Functions

**Directory Shortening:**
```zsh
shorten_pwd
```
Intelligently shortens the current directory path by unique prefixes (e.g., `/u/l/s` for `/usr/local/share`).

**JDK Version Switcher (macOS):**
```zsh
jdk 11      # Switch to Java 11
jdk 1.8     # Switch to Java 1.8
jdk 14      # Switch to Java 14
```

**Enhanced Diff:**
```zsh
diff file1 file2  # Uses batdiff with diff-so-fancy if available
```

**Neofetch with Custom Args:**
```zsh
neofetch  # Displays system info with Kitty backend and custom styling
```

#### Shell Integration

**[The Fuck](https://github.com/nvbn/thefuck):**
- Corrects previous command mistakes with AI-like suggestions
- Invoked automatically via `fuck` alias
- Example: `git psuh` → `fuck` → suggests `git push`

**Starship Prompt:**
- Fast, customizable prompt (see [Starship section](#starship-prompt))
- **[Starship](https://starship.rs/)** - The minimal, blazing-fast, and infinitely customizable prompt

**Completion Systems:**
- Docker CLI completions
- .NET CLI completions
- Ionic CLI completions

---

### Bash (Backup Shell)

**Location:** `~/.bashrc` (symlinked from `bash/bashrc.symlink`)

Provides compatibility for systems where zsh isn't available or when bash is needed.

---

### Shared Aliases

**Location:** `~/.aliases` (symlinked from `aliases/aliases.symlink`)

Aliases work across both zsh and bash.

#### Modern CLI Replacements

```bash
ls      # → eza --icons --git (modern ls with colors and icons)
bat     # → batcat (on Ubuntu/Debian)
cat     # → bat (optional, commented out by default)
fd      # → fdfind (on Ubuntu/Debian)
vi      # → nvim (Neovim)
```

**Tools:**
- **[eza](https://github.com/eza-community/eza)** - Modern replacement for `ls` with git integration and icons
- **[bat](https://github.com/sharkdp/bat)** - Cat clone with syntax highlighting and git integration
- **[fd](https://github.com/sharkdp/fd)** - Simple, fast alternative to `find`
- **[ripgrep](https://github.com/BurntSushi/ripgrep)** - Ultra-fast text search tool

#### Git Shortcuts

```bash
gitgraph    # → git log --decorate --graph
```

#### Docker Shortcuts

```bash
dddubd      # → docker-compose down && docker-compose up --build -d
```

#### Tmux Shortcuts

```bash
ta          # → tmux attach -t λ (attach to default session)
```

#### Misc

```bash
R           # → R -q (quiet R console)
ponysay     # → ponysay -bround
ponythink   # → ponythink -bunicode
```

---

### Starship Prompt

**Location:** `~/.config/starship/starship.toml` (symlinked from `starship/starship.symlink_config/`)
**Project:** [Starship](https://starship.rs/) | **Prompt:** The minimal, blazing-fast, and infinitely customizable prompt for any shell

A fast, cross-shell prompt with language detection and git integration.

#### Features

- **Shell Detection** - Shows which shell is running (zsh, bash)
- **Directory Display** - Shows current path with read-only indicator
- **Git Branch** - Displays current git branch with custom icon
- **Language Context** - Auto-detects and shows:
  - Python (🐍)
  - Rust (🦀)
  - Go (🐹)
  - Java (☕)
  - Node.js
  - Ruby (💎)
  - And many more...
- **Docker Context** - Shows active docker context
- **Shell Level** - Warns when nested shells are detected (threshold: 2)

#### Configuration Highlights

```toml
command_timeout = 10000  # Generous timeout for slow operations

[shlvl]
threshold = 2           # Show warning at 2+ shell levels
format = "[$shlvl level(s) down]($style) => "

[directory]
read_only = " "        # Read-only indicator

[git_branch]
symbol = " "          # Git branch symbol
```

---

## Terminal Multiplexer

### Tmux

**Location:** `~/.tmux.conf` (symlinked from `tmux/tmux.conf.symlink`)
**Project:** [tmux](https://github.com/tmux/tmux) | **Terminal Multiplexer:** Powerful terminal multiplexer for managing multiple terminal sessions

Tmux is configured with vi-mode, custom status bar, and smart keybindings.

#### Prefix Key

```
Ctrl+a (instead of default Ctrl+b)
```

#### Key Bindings

**Session Management:**
- `Ctrl+a c` - Create new window
- `Ctrl+a d` - Detach from session
- `Ctrl+a $` - Rename session

**Window Navigation:**
- `Ctrl+a n` - Next window
- `Ctrl+a p` - Previous window
- `Ctrl+a 0-9` - Jump to window number
- `Ctrl+a ,` - Rename window

**Pane Management:**
- `Ctrl+a |` - Split horizontally
- `Ctrl+a -` - Split vertically
- `Ctrl+a d` - Smart kill pane (custom script)
- `Ctrl+a Arrow` - Navigate between panes
- `Ctrl+a z` - Toggle pane zoom
- `Ctrl+a y` - Toggle pane synchronization

**Pane Resizing:**
- `Ctrl+a Alt+Arrow` - Resize pane

**Configuration:**
- `Ctrl+a ä` - Reload tmux config
- `Ctrl+a ö` - Open tmux config in editor

**Copy Mode (Vi-style):**
- `Ctrl+a [` - Enter copy mode
- `v` - Begin selection
- `y` - Copy selection
- `Ctrl+a ]` - Paste

#### Status Bar

**Layout:**
- **Top Bar:** Empty (reserved)
- **Bottom Bar:** Window list, system info, date/time

**Left Side:**
- Window index and shortened path (e.g., `1:~/D/p/app`)
- Active window highlighted in yellow

**Right Side:**
- CPU/Memory usage (via `tmux-mem-cpu-load`)
- Battery status with icon and percentage
- Date: `Fri 2025-01-14`
- Time: `14:30:45` (updates every 15 seconds)

#### Special Features

**Nested Session Warning:**
- When running tmux inside tmux, status bar turns RED as a warning

**Shortened Paths:**
- Uses `shorten_path` script to intelligently abbreviate directory names

**Predefined Sessions:**
- `λ` (lambda) - Default session with 2 windows
- `ƛ` (lambda variant) - Alternative session with 4 windows

#### Dependencies

- **[tmux-mem-cpu-load](https://github.com/thewtex/tmux-mem-cpu-load)** - System resource monitoring for tmux status bar
- `battery` - Battery status script (see [Utility Scripts](#utility-scripts))
- `shorten_path` - Path abbreviation script (see [Utility Scripts](#utility-scripts))

---

## Editor Configurations

### Neovim

**Location:** `~/.config/nvim/` (symlinked from `nvim/nvim.symlink_config/`)
**Project:** [Neovim](https://neovim.io/) | **Editor:** Hyperextensible Vim-based text editor
**Submodule:** [lualoves.nvim](https://github.com/Buckmeister/lualoves.nvim) - Custom Lua configuration

Neovim is the primary editor, configured as a **git submodule** with its own comprehensive documentation.

#### Documentation

Neovim has its own detailed manual. Please refer to:

**[Neovim Configuration Manual](nvim/nvim.symlink_config/README.md)**

Key highlights:
- Modern Lua configuration with modular architecture
- **[lazy.nvim](https://github.com/folke/lazy.nvim)** plugin manager - Fast, feature-rich plugin management
- **[OneDark](https://github.com/navarasu/onedark.nvim)** "darker" theme - Beautiful dark colorscheme
- Full LSP support (Python, Rust, Go, TypeScript, Java, and more)
- **[Telescope](https://github.com/nvim-telescope/telescope.nvim)** - Fuzzy finder for files, text, and more
- **[Treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** - Advanced syntax highlighting and code understanding
- **[Alpha](https://github.com/goolord/alpha-nvim)** - Custom "LUA LOVES NVIM" welcome screen

**Quick reference:**
- Leader key: `Space`
- File finder: `<Space>ff`
- Text search: `<Space>fg`
- File explorer: `<Space>e`

For complete keybindings and features, see the [Neovim README](nvim/nvim.symlink_config/README.md).

---

### Vim

**Location:** `~/.vimrc` (symlinked from `vim/vimrc.symlink`)
**Project:** [Vim](https://www.vim.org/) | **Editor:** The ubiquitous text editor

Classic Vim is configured but will redirect you to use Neovim instead:

```vim
if has('nvim')
  echom "Please use my nvim config instead :-)"
  call input("Press any key to continue") | quit
  throw "Please use my nvim config instead :-)"
  finish
endif
```

If you absolutely must use classic Vim, the configuration includes:

**Features:**
- **[OneDark](https://github.com/joshdick/onedark.vim)** color scheme
- **[CoC](https://github.com/neoclide/coc.nvim)** (Conquer of Completion) with 30+ language servers
- **[Vim-Plug](https://github.com/junegunn/vim-plug)** plugin manager
- **[Lightline](https://github.com/itchyny/lightline.vim)** statusline with **[bufferline](https://github.com/mengelbrecht/lightline-bufferline)**
- **[FZF](https://github.com/junegunn/fzf.vim)** integration for fuzzy finding
- **[vim-floaterm](https://github.com/voldikss/vim-floaterm)** - Floating terminal window
- **[Neoformat](https://github.com/sbdchd/neoformat)** - Auto-formatting on save
- **[vim-fugitive](https://github.com/tpope/vim-fugitive)** - Git integration

**Keybindings:**
- Leader: `Space`
- Local leader: `,`
- `jk` / `kj` - Exit insert mode
- `Space+f` - FZF commands
- `Space+tt` - Toggle floating terminal
- Full CoC keybindings for LSP features

**Note:** This configuration is comprehensive but maintained primarily as a fallback. Use Neovim for the best experience.

---

### Emacs

**Location:** `~/.emacs` (symlinked from `emacs/emacs.symlink`)
**Project:** [GNU Emacs](https://www.gnu.org/software/emacs/) | **Editor:** An extensible, customizable, free/libre text editor

A comprehensive Emacs configuration featuring **[Evil mode](https://github.com/emacs-evil/evil)** (Vim emulation), modern IDE features, and beautiful aesthetics.

#### Core Features

**Evil Mode (Vim Emulation):**
- **[Evil](https://github.com/emacs-evil/evil)** - Extensible Vi layer with **[evil-collection](https://github.com/emacs-evil/evil-collection)** for consistent bindings
- **[evil-leader](https://github.com/cofi/evil-leader)** - `<Space>` as leader key (Vim-style)
- **[evil-surround](https://github.com/emacs-evil/evil-surround)** - Surround text objects (like vim-surround)
- **[evil-commentary](https://github.com/linktohack/evil-commentary)** - Comment/uncomment with `gc`
- **[evil-matchit](https://github.com/redguardtoo/evil-matchit)** - Jump between matching tags with `%`
- **[evil-visualstar](https://github.com/bling/evil-visualstar)** - Search for visual selection with `*`
- **[undo-tree](https://www.emacswiki.org/emacs/UndoTree)** - Visual undo system integrated with Evil

**Visual Enhancements:**
- **[doom-themes](https://github.com/doomemacs/themes)** - Beautiful themes (using `doom-vibrant`)
- **[doom-modeline](https://github.com/seaycaat/doom-modeline)** - Fancy modeline with icons and git info
- **[centaur-tabs](https://github.com/ema2159/centaur-tabs)** - Modern tab bar with rounded style
- **[all-the-icons](https://github.com/domtronn/all-the-icons.emacs)** - Beautiful icon set throughout
- **[rainbow-delimiters](https://github.com/Fanael/rainbow-delimiters)** - Color-coded parentheses
- **[rainbow-mode](https://elpa.gnu.org/packages/rainbow-mode.html)** - Display colors inline (#ff0000)
- Borderless window with internal padding
- Nerd Fonts: FiraCode (default), VictorMono (variable-pitch), JetBrainsMono (fixed-pitch)

**LSP & Language Support:**
- **[lsp-mode](https://github.com/emacs-lsp/lsp-mode)** - Full Language Server Protocol support
- **[lsp-ui](https://github.com/emacs-lsp/lsp-ui)** - UI improvements for LSP (sideline, doc popups)
- **[dap-mode](https://github.com/emacs-lsp/dap-mode)** - Debug Adapter Protocol support
- **[lsp-treemacs](https://github.com/emacs-lsp/lsp-treemacs)** - Treemacs integration for LSP
- **Languages supported:**
  - **Python**: [lsp-pyright](https://github.com/emacs-lsp/lsp-pyright) with IPython integration
  - **Java**: [lsp-java](https://github.com/emacs-lsp/lsp-java) with Eclipse JDT.LS
  - **Haskell**: [lsp-haskell](https://github.com/emacs-lsp/lsp-haskell) with haskell-language-server
  - **Rust**: [rust-mode](https://github.com/rust-lang/rust-mode) with rust-analyzer
  - **TypeScript**: [typescript-mode](https://github.com/emacs-typescript/typescript.el) with typescript-language-server
  - **C#**: Built-in csharp-mode with OmniSharp
  - **Perl**: cperl-mode with Perl Navigator
  - **YAML**: [yaml-mode](https://github.com/yoshiki/yaml-mode) with yaml-language-server

**Completion & Search:**
- **[company](https://github.com/company-mode/company-mode)** - Modular completion framework
- **[company-box](https://github.com/sebastiencs/company-box)** - Company UI with icons
- **[ivy](https://github.com/abo-abo/swiper)** - Generic completion frontend with fuzzy matching
- **[counsel](https://github.com/abo-abo/swiper)** - Enhanced Ivy commands (M-x, describe-*, etc.)
- **[swiper](https://github.com/abo-abo/swiper)** - Ivy-powered isearch replacement
- **[ivy-rich](https://github.com/Yevgnen/ivy-rich)** - Enhanced candidate display
- **[embark](https://github.com/oantolin/embark)** - Context menu actions

**Project Management:**
- **[projectile](https://github.com/bbatsov/projectile)** - Project management (find files, switch projects)
- **[counsel-projectile](https://github.com/ericdanan/counsel-projectile)** - Projectile + Counsel integration
- **[treemacs](https://github.com/Alexander-Miller/treemacs)** - File tree sidebar with git integration
- **[treemacs-evil](https://github.com/Alexander-Miller/treemacs)** - Evil keybindings for Treemacs
- **[treemacs-projectile](https://github.com/Alexander-Miller/treemacs)** - Projectile integration
- **[treemacs-magit](https://github.com/Alexander-Miller/treemacs)** - Magit integration
- **[neotree](https://github.com/jaypei/emacs-neotree)** - Alternative file tree

**Git Integration:**
- **[magit](https://github.com/magit/magit)** - Best-in-class Git interface
- **[diff-hl](https://github.com/dgutov/diff-hl)** - Highlight uncommitted changes in margin
- Integrated with Treemacs and doom-themes

**Org Mode:**
- Enhanced **[org-mode](https://orgmode.org/)** with beautiful formatting
- **[org-bullets](https://github.com/sabof/org-bullets)** - Pretty bullet points (◉ ○ ●)
- **[visual-fill-column](https://github.com/joostkremers/visual-fill-column)** - Centered text for writing
- Custom font setup with variable-pitch for prose
- Relative heading sizes for visual hierarchy
- Syntax highlighting in code blocks

**Development Tools:**
- **[paredit](https://www.emacswiki.org/emacs/ParEdit)** - Structured editing for Lisp
- **[tree-sitter](https://github.com/emacs-tree-sitter/elisp-tree-sitter)** - Better syntax highlighting
- **[highlight-indentation](https://github.com/antonj/Highlight-Indentation-for-Emacs)** - Indent guides for Python/YAML
- **[which-key](https://github.com/justbur/emacs-which-key)** - Keybinding discovery

**File Management:**
- **[dired](https://www.gnu.org/software/emacs/manual/html_node/emacs/Dired.html)** - Built-in directory editor with Evil bindings
- **[dired-single](https://github.com/crocket/dired-single)** - Reuse dired buffers
- **[dired-hide-dotfiles](https://github.com/mattiasb/dired-hide-dotfiles)** - Toggle hidden files
- **[all-the-icons-dired](https://github.com/jtbm37/all-the-icons-dired)** - Icons in dired
- **[treemacs-icons-dired](https://github.com/Alexander-Miller/treemacs)** - Treemacs-style icons in dired

**Help & Documentation:**
- **[helpful](https://github.com/Wilfred/helpful)** - Better help buffers with examples
- **[dash](https://github.com/magnars/dash.el)** - Modern list library with fontification
- **[which-key](https://github.com/justbur/emacs-which-key)** - Shows available keybindings in popup

**Utilities:**
- **[auto-package-update](https://github.com/radian-software/auto-package-update)** - Automatic package updates (weekly at 9:00 AM)
- **[default-text-scale](https://github.com/purcell/default-text-scale)** - Easy text scaling
- **[monitor](https://github.com/GuiltyDolphin/monitor)** - System monitoring
- Server mode enabled for `emacsclient`

#### Keybindings

**Leader Key (`<Space>`):**
```
<Space> ee    Eval last s-expression
<Space> er    Toggle Neotree
<Space> fb    Switch buffer (Counsel)
<Space> ff    Find file in project (Projectile)
<Space> ft    Open Treemacs
<Space> gs    Magit status
<Space> hc    Helpful command
<Space> hf    Describe function (Counsel)
<Space> hk    Helpful key
<Space> hv    Describe variable (Counsel)
<Space> hw    Which-key top-level
<Space> j     Previous buffer
<Space> k     Next buffer
<Space> s     Text scale adjust
<Space> u     Save buffer
<Space> x     Delete buffer
```

**Centaur Tabs:**
```
C-<prior>     Previous tab (Page Up)
C-<next>      Next tab (Page Down)
gt            Next tab (Evil normal mode)
gT            Previous tab (Evil normal mode)
<right>       Next tab (Evil normal mode)
<left>        Previous tab (Evil normal mode)
```

**macOS-Specific:**
```
Cmd+x         Cut
Cmd+c         Copy
Cmd+v         Paste
Cmd+z         Undo
Cmd+s         Save
Cmd+w         Delete window
Cmd+q         Quit Emacs
```

**Ivy/Counsel:**
```
C-j / C-k     Navigate completion candidates
C-#           Swiper (search in buffer)
M-x           Counsel M-x (enhanced command palette)
```

**Dired:**
```
h             Up directory (Evil)
l             Open file/directory (Evil)
H             Toggle hidden files
C-x C-j       Jump to dired
```

**Org Mode:**
```
C-j / C-k     Next/previous visible heading
M-j / M-k     Move heading up/down
```

**Treemacs:**
```
M-0           Select Treemacs window
C-x t t       Toggle Treemacs
C-x t C-t     Find current file in Treemacs
```

#### macOS Optimizations

- **Menu bar enabled** - Fixes window focus and virtual desktop issues on macOS
- **PATH from shell** - Automatically inherits PATH from login shell
- **Modifier keys:**
  - Left Option → Meta (for Emacs bindings)
  - Right Option → Normal (for typing special characters)
  - Command → Super (for macOS shortcuts)
- **Ligatures enabled** - Requires Emacs for Mac
- **Native fullscreen** - Maximized on launch

#### Configuration Highlights

**UI:**
- No toolbar, tooltip, scrollbar, or menu bar (except macOS)
- Borderless window with 7px internal padding
- Smooth scrolling with 5-line margin
- Relative line numbers in prog/text modes
- Fringe width: 10px

**Files:**
- Backups stored in `~/.tmp/emacsbackup/`
- Trash instead of delete
- UTF-8 encoding by default
- Auto-detects dotfile modes (`.zshrc.symlink` → `sh-mode`)

**Editing:**
- Tab width: 2 spaces
- Spaces instead of tabs
- Show matching parentheses
- History: 25 entries
- Package repository: MELPA

#### First-Time Setup

**Install fonts (one-time):**
```elisp
M-x all-the-icons-install-fonts
```

This downloads and installs all icon fonts needed for the UI.

**Package Installation:**
Packages are automatically installed on first launch via `use-package`.

#### Development Projects

**Projectile Configuration:**
- Project search path: `~/Development/`
- Switch project action: Open dired
- Keybinding: `C-c p` (projectile command map)

**Note:** This configuration is comprehensive and primarily designed for macOS. It provides a modern IDE-like experience with Vim keybindings, making it familiar for Vim users while leveraging Emacs' extensibility and package ecosystem.

---

## Terminal Emulators

### Kitty (Primary)

**Location:** `~/.config/kitty/kitty.conf` (symlinked from `kitty/kitty.symlink_config/`)
**Project:** [Kitty](https://sw.kovidgoyal.net/kitty/) | **Terminal:** The fast, feature-rich, GPU based terminal emulator

Modern, GPU-accelerated terminal with extensive customization.

#### Features

- **Font:** JetBrainsMono Nerd Font, 14pt
- **Theme:** OneDark
- **Ligatures:** Enabled (disabled at cursor for clarity)
- **Remote Control:** Enabled via Unix socket
- **Tab Bar:** Custom style with shortened titles
- **Window:** Borderless with custom margins and padding

#### Key Bindings

**Window Navigation:**
- `Ctrl+Shift+Up` - Move to window above
- `Ctrl+Shift+Down` - Move to window below

**Clearing:**
- `Ctrl+Shift+l` - Clear terminal scrollback
- `Cmd+l` - Clear (macOS alternative)

**Scrollback:**
- `Ctrl+Shift+b` - Launch scrollback in clipboard
- `Ctrl+Shift+h` - Open last command output in Neovim

**Tab Management:**
- Uses standard Kitty tab shortcuts

#### macOS Settings

```conf
macos_show_window_title_in none
macos_traditional_fullscreen yes
macos_custom_beam_cursor yes
macos_option_as_alt no
```

#### Theme Configuration

Multiple themes available (comment/uncomment in config):
- OneDark (active)
- Ayu Mirage
- City Lights
- Gruvbox Material
- Monokai Pro
- Sonokai Maia
- And more...

#### Font Options

Multiple Nerd Fonts available (comment/uncomment in config):
- JetBrainsMono (active)
- FiraCode
- Hack
- Iosevka
- MesloLGS
- VictorMono

---

### Alacritty (Alternative)

**Location:** `~/.config/alacritty/alacritty.toml` (symlinked from `alacritty/alacritty.symlink_config/`)
**Project:** [Alacritty](https://alacritty.org/) | **Terminal:** A cross-platform, OpenGL terminal emulator

Lightweight, cross-platform terminal emulator.

#### Features

- **Font:** VictorMono Nerd Font, 14pt
- **Theme:** OneDark
- **Shell:** Auto-launches zsh with tmux session 'ƛ'
- **Blinking:** Disabled for cursor
- **Decorations:** None (borderless)

#### Key Bindings

**Config Access:**
- `Cmd+,` - Open Alacritty config in Neovim

**Navigation:**
- `Alt+Left` - Move word backward
- `Alt+Right` - Move word forward
- `Alt+Space` - Send space
- `Ctrl+Space` - Send null

**Tmux Integration:**
- `Cmd+1` through `Cmd+9` - Jump to tmux window 1-9
- `Ctrl+Shift+Left` - Previous tmux pane
- `Ctrl+Shift+Right` - Next tmux pane

**Editing:**
- `Cmd+Backspace` - Delete to start of line

#### Tmux Auto-Attach

Alacritty is configured to automatically attach to tmux session `ƛ`:

```toml
[terminal.shell]
args = ["-l", "-c", "tmux attach -t ƛ"]
program = "/bin/zsh"
```

---

## Development Tools

### Git

**Location:** `~/.gitconfig` and related files
**Project:** [Git](https://git-scm.com/) | **Version Control:** Distributed version control system

Git is configured with **[delta](https://github.com/dandavison/delta)** for beautiful diffs (see `post-install/scripts/git-delta-config.zsh`).

**Key Features:**
- **[Delta](https://github.com/dandavison/delta)** pager for syntax-highlighted diffs with side-by-side view
- Gruvbox Material color theme
- Line numbers enabled
- Diff-so-fancy compatibility mode
- Enhanced git status and git log output

---

### IPython

**Location:** `~/.ipython/` (symlinked from `ipython/ipython.symlink/`)
**Project:** [IPython](https://ipython.org/) | **Python REPL:** Powerful interactive shell for Python

Enhanced Python REPL with custom configuration, syntax highlighting, and magic commands.

---

### Language-Specific Configs

#### R

**Location:** `~/.Rprofile` (symlinked from `r/Rprofile.symlink`)

Configuration for the R programming language.

#### Haskell

**Location:** `~/.ghci` (symlinked from `haskell/ghci.symlink`)

GHCi REPL configuration for Haskell development.

---

## Utility Scripts

All utility scripts are installed to `~/.local/bin/` and are available in your PATH.

### GitHub Tools

#### get_github_url

**Location:** `~/.local/bin/get_github_url`
**Type:** Zsh script for GitHub API interaction

A powerful script for downloading GitHub release and tag URLs. Uses the **[GitHub REST API](https://docs.github.com/en/rest)** to fetch download URLs for releases and tags.

**Usage:**
```bash
get_github_url -u username -r repository [options]
```

**Options:**
- `-u, --username` - GitHub username (required)
- `-r, --repository` - Repository name (required)
- `-l, --release` - Release name (default: 'latest')
- `-t, --tag` - Tag name (alternative to release)
- `-p, --pattern` - Regex pattern to filter filenames
- `-f, --fallback-recent` - Use most recent release if 'latest' fails
- `-s, --silent` - Print URLs only (no headers)
- `-c, --count` - Limit number of results

**Examples:**

Get latest Neovim stable release URLs:
```bash
get_github_url -u neovim -r neovim
```

Get latest Neovim nightly for macOS:
```bash
get_github_url -u neovim -r neovim -l nightly -p 'macos.*\.tar\.gz$'
```

Get source for specific tag:
```bash
get_github_url -u neovim -r neovim -t v0.6.0
```

Get most recent release (for projects where 'latest' doesn't work):
```bash
get_github_url -u eclipse-jdtls -r eclipse.jdt.ls -f -p 'jdt-language-server.*\.tar\.gz$'
```

**Features:**
- Supports both releases and tags
- Regex filtering for asset names
- Fallback for projects with quirky release patterns
- Silent mode for scripting
- Result limiting

---

#### get_jdtls_url

**Location:** `~/.local/bin/get_jdtls_url`

Specialized downloader for Eclipse JDT.LS (Java Language Server).

**Usage:**
```bash
get_jdtls_url [--version VERSION] [--silent]
```

**Why it exists:**
JDT.LS has a non-standard release naming scheme that doesn't work with GitHub's 'latest' endpoint. This script wraps `get_github_url` with the correct fallback logic.

**Examples:**

Get latest JDT.LS:
```bash
get_jdtls_url
```

Get specific version:
```bash
get_jdtls_url --version 1.9.0
```

Silent mode for scripting:
```bash
jdtls_url=$(get_jdtls_url --silent)
```

---

### System Utilities

#### battery

**Location:** `~/.local/bin/battery`

Cross-platform battery status script with support for different output formats.

**Usage:**
```bash
battery [OPTIONS]
```

**Options:**
- `--numeric` - Print percentage only
- `--ansi` - ANSI color output for terminal
- `--tmux` - Tmux status bar format
- `--kitty` - Kitty terminal format
- `-r, --remain` - Show time remaining

**Output Formats:**

Terminal (ANSI colors):
```bash
battery --ansi
# → 85%  (blue if > 20%, red if ≤ 20%, green if charging)
```

Tmux status bar:
```bash
battery --tmux
# → #[fg=blue]󰂑 85%#[default]
```

Kitty status:
```bash
battery --kitty
# → 󰂑 85%
```

**Features:**
- Battery icons change based on level and charging status
- Color-coded warnings (red below 20%)
- Charging indicator
- Works on macOS (pmset/ioreg)

**Integration:**
- Used in tmux status bar
- Can be used in shell prompts

---

#### shorten_path

**Location:** `~/.local/bin/shorten_path`

Intelligently shortens directory paths by finding unique prefixes.

**Usage:**
```bash
shorten_path /path/to/directory
```

**Examples:**
```bash
shorten_path /usr/local/share
# → /u/l/share

shorten_path ~/Development/projects/myapp
# → ~/D/p/myapp
```

**How it works:**
- Finds the shortest unique prefix for each directory component
- If only one match exists, stops shortening
- Preserves `~` for home directory
- Last directory component always shown in full

**Integration:**
- Used in tmux window titles
- Used in zsh prompt

---

#### generate_brew_install_script

**Location:** `~/.local/bin/generate_brew_install_script`

Generates a shell script to reinstall all currently installed Homebrew packages.

**Usage:**
```bash
generate_brew_install_script
```

**Output:**
Creates `~/.local/share/generated_brew_install.sh` with:
- All installed formulae
- All installed casks
- Installation commands

**Use case:**
- System migration
- Backup current package list
- Share your Homebrew setup

---

### Recording & Screenshots

#### record-demo

**Location:** `~/.local/bin/record-demo`

Records terminal sessions using asciinema.

**Usage:**
```bash
record-demo [output-file]
```

---

#### screenshot-* Scripts

Multiple screenshot utilities:

- `screenshot-code` - Screenshots code with Silicon
- `screenshot-with-fallback` - Screenshot with fallback options

---

### Development Utilities

#### shell

**Location:** `~/.local/bin/shell`

Utility for shell-related operations.

---

#### rustp

**Location:** `~/.local/bin/rustp`

Rust project utility.

---

#### iperl

**Location:** `~/.local/bin/iperl`

Interactive Perl REPL.

---

#### create_hie_yaml

**Location:** `~/.local/bin/create_hie_yaml`

Creates hie.yaml for Haskell projects (Haskell IDE Engine configuration).

---

#### install_maven_wrapper

**Location:** `~/.local/bin/install_maven_wrapper`

Installs Maven wrapper to Java projects.

---

#### jdt.ls

**Location:** `~/.local/bin/jdt.ls`

Java Development Tools Language Server launcher.

---

## System Integration

### Karabiner (macOS Keyboard Remapping)

**Location:** `~/.config/karabiner/` (symlinked from `karabiner/karabiner.symlink_config/`)
**Project:** [Karabiner-Elements](https://karabiner-elements.pqrs.org/) | **macOS Tool:** Powerful keyboard customizer

Advanced keyboard customization for macOS.

**Features:**
- Custom key mappings
- Application-specific shortcuts
- Complex modifications

**Management:**
- Configuration via Karabiner-Elements app
- JSON-based configuration files
- Auto-backups excluded from version control

---

## Appendix

### Color Scheme

The entire dotfiles configuration uses the **OneDark** color scheme for consistency:

**Base Colors:**
- Background: `#1f2329` (darker variant)
- Foreground: `#abb2bf`
- Black: `#1f2329`
- Red: `#e06c75`
- Green: `#98c379`
- Yellow: `#d19a66`
- Blue: `#61afef`
- Magenta: `#c678dd`
- Cyan: `#56b6c2`
- White: `#abb2bf`

**Applications using OneDark:**
- Neovim
- Vim
- Kitty
- Alacritty
- Tmux (via custom colors)
- All UI libraries in management scripts

---

### Fonts

**[Nerd Fonts](https://www.nerdfonts.com/)** are used throughout for icon support:

**Primary Fonts:**
- **[JetBrainsMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/JetBrainsMono)** - Primary monospace (Kitty)
- **[VictorMono Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/VictorMono)** - Alternative with cursive italics (Alacritty)
- **[FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/FiraCode)** - Alternative with ligatures
- **[MesloLGS Nerd Font](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/Meslo)** - Alternative for Powerline compatibility

**Installation:**
Nerd Fonts are installed via `post-install/scripts/fonts.zsh`

**Features:**
- Programming ligatures for better code readability
- Icon glyphs (file types, git, etc.) from **[devicons](https://github.com/ryanoasis/nerd-fonts#glyph-sets)**
- Powerline symbols for statuslines
- Font Awesome, Material Design Icons, and more

---

### File Locations

#### Configuration Files (symlinked)

```
~/.zshrc                    → dotfiles/zsh/zshrc.symlink
~/.bashrc                   → dotfiles/bash/bashrc.symlink
~/.aliases                  → dotfiles/aliases/aliases.symlink
~/.tmux.conf                → dotfiles/tmux/tmux.conf.symlink
~/.vimrc                    → dotfiles/vim/vimrc.symlink
~/.emacs                    → dotfiles/emacs/emacs.symlink
~/.gitconfig                → dotfiles/git/gitconfig.symlink
~/.config/nvim/             → dotfiles/nvim/nvim.symlink_config/
~/.config/kitty/            → dotfiles/kitty/kitty.symlink_config/
~/.config/alacritty/        → dotfiles/alacritty/alacritty.symlink_config/
~/.config/starship/         → dotfiles/starship/starship.symlink_config/
```

#### Utility Scripts

```
~/.local/bin/get_github_url              → dotfiles/github/get_github_url.symlink_local_bin.zsh
~/.local/bin/get_jdtls_url               → dotfiles/github/get_jdtls_url.symlink_local_bin.zsh
~/.local/bin/shorten_path                → dotfiles/tmux/shorten_path.symlink_local_bin.zsh
~/.local/bin/battery                     → dotfiles/tmux/battery.symlink_local_bin.bash
~/.local/bin/generate_brew_install_script → dotfiles/brew/generate_brew_install_script.symlink_local_bin.zsh
```

#### Repository Structure

```
~/.config/dotfiles/           # Main repository
├── bin/                      # Management scripts
├── post-install/scripts/     # Post-install automation
├── config/                   # Configuration files
├── nvim/nvim.symlink_config/ # Neovim submodule
├── README.md                 # Installation guide
├── INSTALL.md                # Detailed setup instructions
├── CLAUDE.md                 # AI assistant guidance
└── MANUAL.md                 # This file
```

---

## Getting Help

**For Management System:**
- [README.md](README.md) - Quick start and overview
- [INSTALL.md](INSTALL.md) - Detailed installation guide
- [CLAUDE.md](CLAUDE.md) - Developer guidance

**For Neovim:**
- [nvim/nvim.symlink_config/README.md](nvim/nvim.symlink_config/README.md) - Neovim manual

**For System Health:**
```bash
./bin/librarian.zsh    # Comprehensive system status check
```

**For Testing:**
```bash
./tests/test_docker_install.zsh    # Test installation in Docker
```

---

<p align="center">
  <i>Built with love by Thomas - Enjoy your dotfiles! 💙</i>
</p>
