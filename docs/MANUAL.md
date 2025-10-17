# Dotfiles Configuration Manual

> A comprehensive guide to the applications, configurations, and utility scripts in this dotfiles repository

**For installation and setup instructions, see [README.md](../README.md) and [INSTALL.md](INSTALL.md).**

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

This manual documents the **configurations and tools** provided by the dotfiles repository, NOT the dotfiles management system itself (which is covered in [README.md](../README.md) and [INSTALL.md](INSTALL.md)).

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

**Location:** `~/.zshrc` (symlinked from `user/configs/shell/zsh/zshrc.symlink`)
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

**Location:** `~/.config/starship/starship.toml` (symlinked from `user/configs/prompts/starship/starship.symlink_config/`)
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

**Location:** `~/.tmux.conf` (symlinked from `user/configs/multiplexers/tmux/tmux.conf.symlink`)
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

**Location:** `~/.config/nvim/` (symlinked from `user/configs/editors/nvim/nvim.symlink_config/`)
**Project:** [Neovim](https://neovim.io/) | **Editor:** Hyperextensible Vim-based text editor
**Submodule:** [lualoves.nvim](https://github.com/Buckmeister/lualoves.nvim) - Custom Lua configuration

Neovim is the primary editor, configured as a **git submodule** with its own comprehensive documentation.

#### Documentation

Neovim has its own detailed manual. Please refer to:

**[Neovim Configuration Manual](https://github.com/Buckmeister/lualoves.nvim/blob/main/README.md)**

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

For complete keybindings and features, see the [Neovim README](https://github.com/Buckmeister/lualoves.nvim/blob/main/README.md).

---

### Vim

**Location:** `~/.vimrc` (symlinked from `vim/vimrc.symlink`)
**Project:** [Vim](https://www.vim.org/) | **Editor:** The ubiquitous text editor

Classic Vim is configured but will **redirect you to use Neovim instead**:

```vim
if has('nvim')
  echom "Please use my nvim config instead :-)"
  call input("Press any key to continue") | quit
  throw "Please use my nvim config instead :-)"
  finish
endif
```

If you absolutely must use classic Vim, this is a **comprehensive, IDE-like configuration** with:

#### Core Features

**Plugin Management:**
- **[vim-plug](https://github.com/junegunn/vim-plug)** - Minimalist plugin manager with auto-install on first run

**LSP & Completion:**
- **[coc.nvim](https://github.com/neoclide/coc.nvim)** - Full Language Server Protocol support with **30+ language servers** pre-configured
- **Auto-installed CoC extensions:**
  - **Web Development:** coc-angular, coc-html, coc-css, coc-emmet, coc-vetur (Vue), coc-tsserver (TypeScript)
  - **Systems Programming:** coc-clangd (C/C++), coc-rust-analyzer (Rust), coc-omnisharp (C#)
  - **Backend:** coc-java, coc-pyright (Python), coc-perl, coc-r-lsp (R)
  - **DevOps:** coc-docker, coc-nginx, coc-sh (shell), coc-yaml
  - **Data:** coc-json, coc-xml, coc-toml, coc-sqlfluff (SQL)
  - **Documentation:** coc-texlab (LaTeX), coc-swagger
  - **Tooling:** coc-prettier, coc-snippets, coc-spell-checker, coc-pairs, coc-git, coc-highlight
  - **AI:** coc-tabnine (AI completion)
  - **Utilities:** coc-vimlsp (VimScript LSP), coc-explorer (file explorer), coc-yank (yank history)

**Visual Enhancements:**
- **[onedark.vim](https://github.com/joshdick/onedark.vim)** - Primary color scheme (custom darker background: `#1F2329`)
- **[vim-one](https://github.com/rakr/vim-one)** - Alternative One colorscheme
- **[gruvbox-material](https://github.com/sainnhe/gruvbox-material)**, **[edge](https://github.com/sainnhe/edge)**, **[sonokai](https://github.com/sainnhe/sonokai)**, **[everforest](https://github.com/sainnhe/everforest)** - Additional premium themes
- **[lightline.vim](https://github.com/itchyny/lightline.vim)** - Minimalist statusline (see [Lightline Configuration](#lightline-configuration-vim) below)
- **[lightline-bufferline](https://github.com/mengelbrecht/lightline-bufferline)** - Buffer tabs with superscript numbers (⁰¹²³⁴⁵⁶⁷⁸⁹)
- **[vim-devicons](https://github.com/ryanoasis/vim-devicons)** - File type icons (requires Nerd Fonts)
- **[rainbow](https://github.com/luochen1990/rainbow)** - Rainbow parentheses for nested brackets
- **[rainbow_csv](https://github.com/mechatroner/rainbow_csv)** - CSV column highlighting
- **[coloresque.vim](https://github.com/ObserverOfTime/coloresque.vim)** - Display colors inline (#ff0000 → colored background)

**Navigation & Search:**
- **[fzf](https://github.com/junegunn/fzf)** + **[fzf.vim](https://github.com/junegunn/fzf.vim)** - Fuzzy file/text finding
- **[fzf-preview.vim](https://github.com/yuki-yano/fzf-preview.vim)** - Enhanced FZF with previews and CoC integration
- **[vim-fzy](https://github.com/bfrg/vim-fzy)** - Alternative fuzzy finder with popup window
- **[vim-which-key](https://github.com/liuchengxu/vim-which-key)** - Keybinding discovery popup
- **[vim-cool](https://github.com/romainl/vim-cool)** - Smart search highlighting (auto-clear after move)

**Editing Enhancements:**
- **[vim-commentary](https://github.com/tpope/vim-commentary)** - Toggle comments with `gc`
- **[vim-surround](https://github.com/tpope/vim-surround)** - Manipulate surrounding quotes/brackets
- **[vim-repeat](https://github.com/tpope/vim-repeat)** - Make `.` work with plugins
- **[neoformat](https://github.com/sbdchd/neoformat)** - Auto-format on save

**Git Integration:**
- **[vim-fugitive](https://github.com/tpope/vim-fugitive)** - Git commands, status, and blame

**Project Management:**
- **[netrw](https://www.vim.org/scripts/script.php?script_id=1075)** - Built-in file explorer (configured for tree view)
- **coc-explorer** (via CoC) - Modern file tree sidebar

**Terminals & Focus Modes:**
- **[vim-floaterm](https://github.com/voldikss/vim-floaterm)** - Floating/popup terminal windows
- **[goyo.vim](https://github.com/junegunn/goyo.vim)** - Distraction-free writing mode
- **[limelight.vim](https://github.com/junegunn/limelight.vim)** - Dim unfocused paragraphs (integrates with Goyo)

**Language-Specific:**
- **[haskell-vim](https://github.com/neovimhaskell/haskell-vim)** - Enhanced Haskell syntax
- **[java-syntax.vim](https://github.com/uiiaoo/java-syntax.vim)** - Better Java highlighting

**System Integration:**
- **[vim-eunuch](https://github.com/tpope/vim-eunuch)** - Unix commands (`:Delete`, `:Move`, `:Rename`, etc.)
- **[terminus](https://github.com/wincent/terminus)** - Better terminal integration (cursor shapes, focus events)
- **[battery.vim](https://github.com/lambdalisue/battery.vim)** - Battery status in statusline

**Utilities:**
- **[vim-bbye](https://github.com/Buckmeister/vim-bbye)** - Delete buffers without closing windows

#### Editor Settings Highlights

**Behavior:**
- Line numbers: absolute + relative
- Sign column always visible (for LSP diagnostics)
- Text width: 81 characters (with visual overlength highlighting)
- Auto-indent, smart-indent, smart-tab
- Persistent undo (`~/.tmp/vimbackup/undo`)
- Hidden buffers (switch without saving)
- Case-insensitive search (smart: case-sensitive if capitals present)

**UI:**
- Cursorline enabled (only in active window)
- Split below/right (natural reading order)
- Scrolloff: 8 lines (keep cursor centered)
- Mouse support enabled
- TrueColor support (when `$COLORTERM` = truecolor/24bit)
- Popup completion menu (height: 12, width: 60)

**Whitespace:**
- Tab = 2 spaces (expandtab)
- Visible whitespace: tabs as `>·`, trailing spaces as `·`

#### Keybindings

**Leader Keys:**
```vim
Leader: Space
Local Leader: ,
```

**Insert Mode:**
```
jk / kj             Exit insert mode (escape alternatives)
```

**Normal Mode Essentials:**
```
Ctrl+l              Clear search highlighting
Space               Leader key (mapped, not functional on its own)
```

**Window Navigation:**
```
Arrow Keys          Navigate windows (Up/Down/Left/Right)
Ctrl+H              Cycle to next window
```

**Window Resizing:**
```
Shift+Up            Decrease height (-2)
Shift+Down          Increase height (+2)
Shift+Left          Decrease width (-2)
Shift+Right         Increase width (+2)
```

**Buffer Navigation:**
```
Space j             Previous buffer
Space k             Next buffer
Ctrl+Left           Previous buffer (alternative)
Ctrl+Right          Next buffer (alternative)
```

**Line Movement (Alt+Up/Down):**
```
Alt+Up              Move line up (works in normal, insert, visual)
Alt+Down            Move line down
∆                   Move line up (macOS Option+J fallback)
º                   Move line down (macOS Option+K fallback)
```

**Visual Mode:**
```
<                   Indent left (stay in visual mode)
>                   Indent right (stay in visual mode)
Alt+Up/Down         Move selection up/down
```

**Clipboard Operations:**
```
Space d             Delete to black hole register (don't yank)
Space y             Yank to system clipboard
Space Y             Yank entire file to clipboard
Space p (visual)    Paste without yanking replaced text
```

**File Operations:**
```
Space r             Fuzzy file finder (FzyFind)
Space ew            Edit file in current directory
Space u             Update (save) file
```

**Buffer/Window Management:**
```
Space x             Close buffer (Bdelete - keeps window layout)
Space o             Close all other windows (only)
Space w             Cycle windows
Space aq            Quit all
```

**Utilities:**
```
Space ba            ASCII art banner (pipe to figlet)
Ctrl+a ä            Reload vimrc (bound to tmux prefix + ä)
```

**Quickfix Navigation:**
```
Shift+F1            Go to current quickfix item
F2                  Next quickfix item
Shift+F2            Previous quickfix item
F3                  Next file in quickfix
Shift+F3            Previous file in quickfix
F4                  First quickfix item
Shift+F4            Last quickfix item
```

**FZF-Preview Commands (`Space f` prefix):**
```
Space f f           Find files in directory
Space f p           Find from project MRU + git
Space f gs          Git status (interactive)
Space f ga          Git actions (stage, unstage, etc.)
Space f b           Switch buffers
Space f B           All buffers (across all tabs)
Space f o           Files from buffer + project MRU
Space f Ctrl+o      Jump list navigation
Space f g;          Change list navigation
Space f /           Search lines in current buffer
Space f *           Search word under cursor in buffer
Space f gr          Project-wide grep (interactive)
Space f t           Buffer tags (ctags)
Space f q           Quickfix list
Space f l           Location list
```

**Floating Terminal:**
```
Space tt            Toggle floating terminal
```

**Distraction-Free Mode:**
```
Space go            Toggle Goyo mode (auto-enables Limelight)
```

**Visual Star Search:**
```
* (visual)          Search for selected text forward
# (visual)          Search for selected text backward
```

<a name="lightline-configuration-vim"></a>
#### Lightline Configuration

Thomas's Lightline configuration is a **masterpiece of responsive design** with adaptive components:

**Features:**
- **Responsive Width Breakpoints:**
  - Small: 60 chars - Shows mode char, filename, percent
  - Medium: 90 chars - Adds line info, filetype icon
  - Large: 110 chars - Adds full mode name, git branch, encoding/format
- **Custom Separators:**
  - TrueColor terminals: Powerline arrows (``  ``)
  - Basic terminals: Vertical bars (`⁞`)
- **OneDark Color Scheme** - Matches editor theme
- **Buffer Tabs** - Top bar with superscript numbers (⁰¹²³⁴⁵⁶⁷⁸⁹)
- **Intelligent File Display:**
  - Large windows: Full path (`/u/l/b/vim`)
  - Medium windows: Relative path with ~ (`~/D/p/app`)
  - Small windows: Directory only
  - Tiny windows: Filename only
- **Git Branch** - Shows  branch name (when in git repo, large width only)
- **Battery Status** - Shows  with percentage and charging state
- **Smart Icons:**
  - Modified:  (yellow)
  - Readonly:  (red)
  - No filename: `[No Name]`
- **Special Filetype Handling:**
  - Hides statusline components for netrw, coc-explorer, fugitive, help

**Statusline Layout:**
```
┌─────────────────────────────────────────────────────────────────┐
│ NORMAL  master  ~/D/p/app/src/main.rs [+]  85％  42:17  UTF-8 │
└─────────────────────────────────────────────────────────────────┘
```

**Tabline Layout:**
```
⁰[No Name]  ¹main.rs  ²config.toml  ³README.md
```

#### Colorscheme Options

The vimrc includes **5 premium colorschemes** with extensive configuration:

**Available Themes:**
1. **[onedark](https://github.com/joshdick/onedark.vim)** (default) - Atom-inspired, warm, vibrant
2. **[one](https://github.com/rakr/vim-one)** - Clean, minimal Atom One
3. **[gruvbox-material](https://github.com/sainnhe/gruvbox-material)** - Earthy, warm, retro
4. **[edge](https://github.com/sainnhe/edge)** - Neon style, vibrant, modern
5. **[sonokai](https://github.com/sainnhe/sonokai)** - Maia variant, colorful
6. **[everforest](https://github.com/sainnhe/everforest)** - Green, comfortable, forest-inspired

**Change colorscheme:**
```vim
:ColorsSet gruvbox-material
:ColorsSet edge
:LightlineColorscheme gruvbox_material
```

**Theme Customization:**
- All themes support TrueColor with italics
- Hard contrast backgrounds
- Transparent backgrounds disabled (solid colors)
- Diagnostic text highlighting enabled
- Better performance mode enabled

#### Special Features

**Visual Star Search:**
Custom function allows searching for visually selected text with `*` or `#`:
```vim
vnoremap * :<C-u>call <SID>VSetSearch()<CR>/<CR>
```

**Netrw (Built-in File Browser):**
- No banner (clean interface)
- Tree-style listing
- Opens in 25% width vertical split
- Preview window enabled

**Auto-Format on Save:**
Neoformat automatically formats files on write (with undo-join for atomic operations):
```vim
autocmd BufWritePre * try | undojoin | Neoformat | catch | silent Neoformat | endtry
```

**Goyo + Limelight Integration:**
Entering Goyo distraction-free mode:
- Hides tmux status bar (if in tmux)
- Enables Limelight (dims unfocused paragraphs)
- Exiting Goyo restores all settings

**Window Auto-Resize:**
Windows automatically rebalance when Vim window is resized:
```vim
autocmd VimResized * tabdo wincmd =
```

**Smart Cursorline:**
Cursorline only shows in the active window (auto-disables in inactive):
```vim
autocmd WinLeave * set nocursorline
autocmd WinEnter * set cursorline
```

**Overlength Highlighting:**
Text beyond `textwidth + 2` is highlighted with `OverLength` group (custom red background):
```vim
match OverLength /\%83v.*/  " Highlights column 83+
```

#### GUI Settings (gVim/MacVim)

For GUI Vim:
- Font: FiraCode Nerd Font Mono, 14pt
- macOS ligatures enabled
- No toolbar, command height: 2
- Custom colorscheme for GUI (`g:gui_colorscheme`)

#### First-Time Setup

**Automatic Setup:**
- vim-plug auto-installs on first run if missing
- All plugins install automatically via `:PlugInstall`
- CoC extensions auto-install on first CoC startup

**Manual Font Installation:**
Required for icons to work:
```bash
# Run the fonts post-install script
./post-install/scripts/fonts.zsh
```

**CoC Configuration:**
CoC uses default settings with all extensions listed in `g:coc_global_extensions`.

#### Configuration Files

**Main Config:**
- `~/.vimrc` - Main configuration (786 lines)

**CoC Config:**
- CoC uses its own JSON configuration (not included in this dotfiles)
- Extensions auto-install based on `g:coc_global_extensions`

**Backup Directories:**
```bash
~/.tmp/vimbackup/swap/    # Swap files
~/.tmp/vimbackup/undo/    # Undo history (persistent across sessions)
```

#### Tips & Tricks

**Discover Keybindings:**
Press `Space` and wait - **which-key** will show available commands.

**CoC Commands:**
```vim
:CocList extensions       " List installed CoC extensions
:CocUpdate                " Update all CoC extensions
:CocCommand               " Run CoC command (tab-complete available)
```

**Lightline Commands:**
```vim
:LightlineColorscheme onedark    " Change statusline theme
```

**FZF-Preview Commands:**
All accessible via `Space f` prefix - see [Keybindings](#keybindings) for full list.

**Note:** This configuration is comprehensive and feature-complete but **maintained primarily as a fallback**. For the best experience with modern Neovim features (Lua config, native LSP, Treesitter), use the **[lualoves.nvim](#neovim)** configuration instead.

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

**Location:** `~/.config/kitty/kitty.conf` (symlinked from `user/configs/terminals/kitty/kitty.symlink_config/`)
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

Generates a **Brewfile** from your current Homebrew installation using the official `brew bundle dump` command. A Brewfile is Homebrew's recommended way to backup and restore packages across systems.

**Features:**
- Captures all **taps** (third-party Homebrew repositories)
- Captures all **formulae** (CLI tools)
- Captures all **casks** (GUI applications)
- Captures **Mac App Store apps** (if `mas` is installed)
- Uses official `brew bundle` commands for idempotent operations
- Beautiful OneDark-themed output with progress messages
- Shows statistics (tap/formula/cask/mas counts)

**Usage:**
```bash
# Generate Brewfile in default location
generate_brew_install_script

# Generate in custom location
generate_brew_install_script -o ~/Desktop/Brewfile

# Force overwrite existing file
generate_brew_install_script -f
```

**Options:**
- `-o, --output PATH` - Output file path (default: `~/.local/share/Brewfile`)
- `-f, --force` - Overwrite existing Brewfile without prompting
- `-h, --help` - Show help message with usage examples

**Output:**
Default location: `~/.local/share/Brewfile`

Example Brewfile content:
```ruby
tap "adoptopenjdk/openjdk"
tap "microsoft/git"
brew "bat"
brew "neovim"
brew "ripgrep"
cask "docker"
cask "firefox"
mas "Xcode", id: 497799835
```

**Using the Brewfile:**

Install all packages from Brewfile:
```bash
brew bundle install --file=~/.local/share/Brewfile
```

Preview what would be installed (dry run):
```bash
brew bundle install --file=~/.local/share/Brewfile --dry-run
```

Cleanup packages not in Brewfile:
```bash
brew bundle cleanup --file=~/.local/share/Brewfile
```

**Use cases:**
- System migration (backup on old Mac, restore on new Mac)
- Share your exact Homebrew setup with others
- Version control your Homebrew packages
- Disaster recovery (reinstall everything after fresh macOS install)
- Team standardization (everyone installs same tools)

**Requirements:**
- Homebrew installed
- `brew bundle` command (bundled with modern Homebrew)
- Optional: `mas` (Mac App Store CLI) for App Store app backup

**Note:** This script replaces the old `generate_brew_install_script.zsh` which generated custom shell scripts. The Brewfile approach is more robust, officially supported, and automatically handles taps (which the old script couldn't capture).

---

#### speak

**Location:** `~/.local/bin/speak`
**Platform:** macOS only (uses `say` command)

A delightful text-to-speech utility that brings audio feedback to your terminal workflow. Perfect for long-running tasks, test notifications, and making your dotfiles system more engaging.

**Usage:**
```bash
speak [options] "text to speak"
echo "text" | speak [options]
```

**Options:**
- `-v, --voice VOICE` - Select voice (default: Samantha)
- `-r, --rate RATE` - Speech rate in WPM (default: 175)
- `-f, --file FILE` - Read text from file
- `--celebrate` - Celebratory tone for success messages
- `--friendly` - Extra friendly greeting tone
- `--alert` - Alert tone for important messages
- `--list-voices` - List all available voices
- `-h, --help` - Show help message

**Features:**
- **ANSI Stripping:** Automatically removes color codes for clean speech
- **Multiple Voices:** Samantha (default), Alex, Victoria (British), Daniel (British), Karen (Australian), Moira (Irish), Fiona (Scottish)
- **Rate Control:** Adjust speech speed (words per minute)
- **Personality Modes:** Three built-in modes (celebrate, friendly, alert)
- **Flexible Input:** Supports arguments, stdin pipes, or file input

**Examples:**

Basic usage:
```bash
speak "Hello, friend!"
```

Pipe from commands:
```bash
echo "Build complete!" | speak
```

Different voices:
```bash
speak -v Alex "Testing different voice"
speak -v Daniel "Jolly good show, old chap!"  # British accent
```

Adjust speed:
```bash
speak -r 200 "Speaking quickly"
speak -r 150 "Speaking slowly"
```

Celebration mode:
```bash
speak --celebrate "All tests passing!"
speak --celebrate "Menu system refactoring complete!"
```

Friendly greeting:
```bash
speak --friendly "Welcome to your dotfiles"
```

Alert mode:
```bash
speak --alert "Tests failed!"
```

Read from file:
```bash
speak -f README.md
```

**Integration Examples:**

Task completion:
```bash
./setup && speak --celebrate "Dotfiles setup complete!"
```

Test notifications:
```bash
./tests/run_tests.zsh && speak "Tests passing!" || speak --alert "Tests failed!"
```

Background reminders:
```bash
(sleep 300; speak "Time to take a break!") &
```

Build notifications:
```bash
cargo build --release && speak --celebrate "Build succeeded!" || speak --alert "Build failed"
```

**Popular Voices:**
- **Samantha** - Friendly female voice (default, warm and clear)
- **Alex** - Professional male voice (clear and neutral)
- **Victoria** - British female voice (elegant)
- **Daniel** - British male voice (distinguished)
- **Karen** - Australian female voice (casual and friendly)
- **Moira** - Irish female voice (charming)
- **Fiona** - Scottish female voice (distinctive)

**Use Cases:**
- Long-running task completion notifications
- Test suite success/failure announcements
- Build status updates (success/failure)
- Timer and reminder notifications
- Code review feedback
- Making terminal output more accessible
- Adding personality to automation scripts

**Requirements:**
- macOS with `say` command (built-in)
- Works on all recent macOS versions

**Tips:**
- Use `speak --list-voices` to discover all available voices on your system
- Pipe colored terminal output directly - ANSI codes are automatically stripped
- Combine with background tasks (`&`) for non-blocking notifications
- Use in CI/CD scripts for audio feedback during development

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

### Package Management

The dotfiles include a **universal package management system** that enables defining packages once and installing them across any platform (macOS, Linux, Windows).

#### Overview

Instead of maintaining separate package lists for each platform (Brewfile for macOS, apt-packages.txt for Linux, etc.), the universal system uses a **single YAML manifest** that works everywhere.

**Key Benefits:**
- **Write Once, Run Anywhere** - Define packages once, install on any OS
- **Intelligent Mapping** - Automatic translation to platform-specific package names
- **Flexible Priorities** - Filter by required, recommended, or optional packages
- **Rich Metadata** - Descriptions, categories, dependencies built into manifest
- **Multi-Package Manager** - Supports brew, apt, cargo, npm, pipx, gem, and more

**Documentation:**
- **[packages/README.md](packages/README.md)** - Complete overview and workflow guide
- **[packages/SCHEMA.md](packages/SCHEMA.md)** - Full YAML schema reference
- **[packages/base.yaml](packages/base.yaml)** - Curated manifest with 50+ packages

---

#### generate_package_manifest

**Location:** `~/.local/bin/generate_package_manifest`

Scans your system and generates a universal YAML manifest from currently installed packages.

**Usage:**
```bash
# Generate manifest in default location
generate_package_manifest

# Generate in custom location
generate_package_manifest -o ~/my-packages.yaml

# Merge with existing manifest (preserve metadata)
generate_package_manifest --merge

# Interactive mode (prompt for package details)
generate_package_manifest --interactive
```

**Options:**
- `-o, --output PATH` - Output file (default: `~/.local/share/dotfiles/packages.yaml`)
- `-f, --force` - Overwrite existing manifest without prompting
- `-m, --merge` - Merge with existing manifest (smart update)
- `-i, --interactive` - Prompt for package metadata
- `-c, --category CAT` - Only export specific category
- `-h, --help` - Show help message

**Package Managers Scanned:**
- **Homebrew** - Formulae and casks (macOS/Linux)
- **APT** - Manually installed packages (Ubuntu/Debian)
- **Cargo** - Rust packages
- **NPM** - Node.js global packages
- **Pipx** - Python applications
- **Gem** - Ruby gems

**Example Output:**
```yaml
version: "1.0"

metadata:
  name: "Thomas's Development Environment"
  description: "Auto-generated package manifest"
  author: "Thomas"
  last_updated: "2025-10-14"

packages:
  - id: ripgrep
    install:
      brew: ripgrep
      apt: ripgrep

  - id: neovim
    install:
      brew: neovim
      apt: neovim
      choco: neovim
```

**Use Cases:**
- Export your current setup before system migration
- Share your package list with team members
- Version control your development environment
- Create a backup for disaster recovery

---

#### install_from_manifest

**Location:** `~/.local/bin/install_from_manifest`

Installs packages from a universal YAML manifest on any platform.

**Usage:**
```bash
# Install all required + recommended packages
install_from_manifest

# Install only required packages
install_from_manifest --required-only

# Install specific categories
install_from_manifest --category editor,git,search

# Dry run (preview what would be installed)
install_from_manifest --dry-run

# Use custom manifest
install_from_manifest -i ~/my-packages.yaml
```

**Options:**
- `-i, --input PATH` - Input manifest file (default: looks in standard locations)
- `--dry-run` - Preview what would be installed without actually installing
- `--category CATEGORIES` - Comma-separated list of categories to install
- `--required-only` - Install only packages marked as 'required'
- `--skip-optional` - Skip packages marked as 'optional'
- `-h, --help` - Show help message

**Features:**
- **Smart Detection** - Automatically skips already-installed packages
- **Platform Awareness** - Uses appropriate package manager (brew/apt/cargo)
- **Priority Filtering** - Install only what you need (required/recommended/optional)
- **Category Filtering** - Install specific tool categories (editor, shell, git, etc.)
- **Dry Run Mode** - Preview installation without making changes
- **Beautiful UI** - OneDark-themed output with progress indicators

**Example Workflow:**

On a fresh macOS system:
```bash
# Clone dotfiles
git clone --recurse-submodules https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# Link dotfiles (creates symlinks)
./setup --skip-pi

# Install all essential packages
install_from_manifest --category editor,shell,git
```

On a fresh Ubuntu system:
```bash
# Same manifest, different platform - automatically uses apt
install_from_manifest --required-only
```

---

#### sync_packages

**Location:** `~/.local/bin/sync_packages`

Keeps your package manifest synchronized with your system's actual state.

**Usage:**
```bash
# Update manifest from current system
sync_packages

# Update and commit to git
sync_packages --push

# Update with custom commit message
sync_packages --push --message "Add new development tools"
```

**Options:**
- `--update` - Regenerate manifest from current system (default)
- `--push` - Commit and push changes to git
- `--message MSG` - Custom commit message
- `-h, --help` - Show help message

**What It Does:**
1. Scans all package managers on your system
2. Regenerates the package manifest
3. Shows a diff of what changed (added/removed packages)
4. Optionally commits and pushes to git

**Features:**
- **Automatic Backup** - Creates timestamped backup before overwriting
- **Change Detection** - Shows what packages were added or removed
- **Git Integration** - Automatically commits with formatted messages
- **Safe Operation** - Preview changes before committing

**Example Workflow:**

After installing new tools:
```bash
# Install a new package
brew install htop

# Sync manifest to include it
sync_packages

# Review the changes
# If satisfied, push to git
sync_packages --push
```

**Use Cases:**
- Keep manifest synchronized after installing new packages
- Track package changes over time via git history
- Share updates with team (push manifest to shared repository)
- Maintain consistency across multiple machines

---

#### Package Manifest Structure

**Location:** `~/.local/share/dotfiles/packages.yaml` (user manifest)
**Template:** `~/.config/dotfiles/packages/base.yaml` (curated base)

Example manifest with common features:

```yaml
version: "1.0"

metadata:
  name: "My Development Environment"
  description: "Cross-platform packages for development"
  author: "Thomas"

settings:
  auto_confirm: false
  parallel_install: true
  skip_installed: true

packages:
  # Core editor - works everywhere
  - id: neovim
    name: "Neovim"
    description: "Hyperextensible Vim-based editor"
    category: editor
    priority: required
    platforms: [macos, linux, windows]
    install:
      brew: neovim
      apt: neovim
      choco: neovim
      winget: Neovim.Neovim
    alternatives:
      - method: cargo
        package: neovim
    dependencies: [git, curl]

  # Modern CLI tool with alternative installation
  - id: ripgrep
    name: "Ripgrep"
    description: "Ultra-fast text search"
    category: search
    priority: recommended
    install:
      brew: ripgrep
      apt: ripgrep
      choco: ripgrep
      winget: BurntSushi.ripgrep.MSVC
    alternatives:
      - method: cargo
        package: ripgrep

  # macOS-specific GUI application
  - id: docker
    name: "Docker Desktop"
    description: "Container platform"
    category: container
    priority: optional
    platforms: [macos, windows]
    install:
      brew_cask: docker
      choco: docker-desktop
      winget: Docker.DockerDesktop
    post_install:
      macos: "open /Applications/Docker.app"
```

**Key Fields:**
- `id` - Unique identifier (required)
- `name` - Display name
- `description` - What the package does
- `category` - Logical grouping (editor, shell, search, git, etc.)
- `priority` - Installation priority (required/recommended/optional)
- `platforms` - Supported platforms (macos, linux, windows, ubuntu, etc.)
- `install` - Package manager mappings (brew, apt, cargo, npm, etc.)
- `alternatives` - Alternative installation methods
- `dependencies` - Other packages needed first
- `post_install` - Commands to run after installation

**Supported Package Managers:**
- `brew` - Homebrew (macOS/Linux)
- `brew_cask` - Homebrew Casks (GUI apps on macOS)
- `apt` - APT (Debian/Ubuntu)
- `yum` / `dnf` - YUM/DNF (CentOS/Fedora)
- `pacman` - Pacman (Arch Linux)
- `choco` - Chocolatey (Windows)
- `winget` - Windows Package Manager
- `cargo` - Rust packages
- `npm` - Node.js global packages
- `pip` / `pipx` - Python packages/apps
- `gem` - Ruby gems
- `go` - Go packages

**Categories:**
- `editor` - Text editors (Neovim, VS Code)
- `shell` - Shells and utilities (zsh, bash)
- `search` - Search tools (ripgrep, fd, fzf)
- `git` - Version control (git, gh, delta)
- `language` - Programming languages (Node, Python, Rust)
- `network` - Network utilities (curl, wget, httpie)
- `terminal` - Terminal emulators (Kitty, Alacritty)
- `development` - Dev tools (LSP servers, formatters)
- `utilities` - System utilities (htop, jq, tree)
- `container` - Docker, Kubernetes
- `font` - Nerd Fonts

**Priorities:**
- `required` - Essential packages (always installed)
- `recommended` - Commonly used packages (installed by default)
- `optional` - Specialized packages (user must opt-in)

For complete schema documentation, see [packages/SCHEMA.md](packages/SCHEMA.md).

---

## System Integration

### Karabiner (macOS Keyboard Remapping)

**Location:** `~/.config/karabiner/` (symlinked from `user/configs/system/karabiner/karabiner.symlink_config/`)
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
~/.zshrc                    → dotfiles/user/configs/shell/zsh/zshrc.symlink
~/.bashrc                   → dotfiles/user/configs/shell/bash/bashrc.symlink
~/.aliases                  → dotfiles/user/configs/shell/aliases/aliases.symlink
~/.tmux.conf                → dotfiles/user/configs/multiplexers/tmux/tmux.conf.symlink
~/.vimrc                    → dotfiles/user/configs/editors/vim/vimrc.symlink
~/.emacs                    → dotfiles/user/configs/editors/emacs/emacs.symlink
~/.gitconfig                → dotfiles/user/configs/version-control/git/gitconfig.symlink
~/.config/nvim/             → dotfiles/user/configs/editors/nvim/nvim.symlink_config/
~/.config/kitty/            → dotfiles/user/configs/terminals/kitty/kitty.symlink_config/
~/.config/alacritty/        → dotfiles/user/configs/terminals/alacritty/alacritty.symlink_config/
~/.config/starship/         → dotfiles/user/configs/prompts/starship/starship.symlink_config/
```

#### Utility Scripts

```
~/.local/bin/get_github_url               → dotfiles/user/scripts/version-control/get_github_url.symlink_local_bin.zsh
~/.local/bin/get_jdtls_url                → dotfiles/user/scripts/version-control/get_jdtls_url.symlink_local_bin.zsh
~/.local/bin/shorten_path                 → dotfiles/user/scripts/shell/shorten_path.symlink_local_bin.zsh
~/.local/bin/battery                      → dotfiles/user/scripts/utilities/battery.symlink_local_bin.sh
~/.local/bin/generate_brew_install_script → dotfiles/user/scripts/package-managers/generate_brew_install_script.symlink_local_bin.zsh
~/.local/bin/shell                        → dotfiles/user/scripts/shell/shell.symlink_local_bin.zsh
~/.local/bin/speak                        → dotfiles/user/scripts/utilities/speak.symlink_local_bin.zsh
```

#### Repository Structure

```
~/.config/dotfiles/           # Main repository
├── bin/                      # Management scripts
├── post-install/scripts/     # Post-install automation
├── env/                      # Environment configuration
├── user/                     # All user-facing deployables
│   ├── configs/              # Application configurations
│   │   └── editors/nvim/nvim.symlink_config/ # Neovim submodule
│   └── scripts/              # User executables
├── README.md                 # Installation guide
├── docs/INSTALL.md           # Detailed setup instructions
├── docs/CLAUDE.md            # AI assistant guidance
└── docs/MANUAL.md            # This file
```

---

## 🎯 Common Workflows

Practical examples showing how to combine these tools for real-world development tasks.

### Workflow 1: Starting a Tmux Development Session

**Scenario:** Beginning your workday with a well-organized tmux environment.

```bash
# Start or attach to default tmux session
ta                  # Alias for: tmux attach -t λ

# Create your workspace layout:
Ctrl+a |            # Split vertically (editor | terminal)
Ctrl+a -            # Split bottom pane horizontally (terminal | logs)

# Navigate between panes
Ctrl+a Arrow keys   # Move focus

# Pane 1: Editor
nvim ~/.config/dotfiles/configs/shell/zsh/zshrc.symlink

# Pane 2: Watch for changes
cargo test --watch

# Pane 3: System logs
tail -f ~/app.log

# Zoom into editor pane when needed
Ctrl+a z            # Toggle zoom

# Copy mode for scrollback
Ctrl+a [            # Enter copy mode (vi keys)
/search term        # Search
v                   # Start visual selection
y                   # Copy
Ctrl+a ]            # Paste
```

**Result:** Organized, persistent workspace across terminal restarts.

---

### Workflow 2: Vim Power User Techniques

**Scenario:** Editing code efficiently with Vim's advanced features.

```bash
# Open Neovim in project root
cd ~/Development/my-project
nvim .

# Inside Neovim:
Space e             # Toggle file explorer
Space ff            # Fuzzy find files
Space fg            # Grep through project files

# Working with buffers:
Space ff readme     # Find README file
Space k             # Next buffer
Space j             # Previous buffer
Space x             # Close buffer (keeps window)

# Quick navigation:
gd                  # Go to definition (LSP)
gr                  # Find references
K                   # Show hover documentation

# Editing tricks:
ciw                 # Change inner word
ci"                 # Change inside quotes
>                   # Indent (visual mode)
gc                  # Toggle comment (visual/motion)

# Window management:
Ctrl+w v            # Vertical split
Ctrl+w s            # Horizontal split
Ctrl+w h/j/k/l      # Navigate windows
Ctrl+w =            # Equalize window sizes

# Search and replace:
:%s/old/new/gc      # Replace with confirmation
:g/pattern/d        # Delete lines matching pattern

# Save and quit:
Space u             # Save (update)
:wq                 # Save and quit
:qa                 # Quit all
```

**Result:** Lightning-fast code navigation and editing.

---

### Workflow 3: Shell Power Features

**Scenario:** Using zsh features for productivity.

```bash
# Vi-mode editing
#  Insert mode: type normally
#  Press jk/kj to enter normal mode
#  Use vim motions: w, b, $, 0, etc.
#  Press i/a to return to insert

# Auto-suggestions (based on history)
git sta[Tab]        # Completes to "git status" if in history
[Ctrl+Space]        # Accept suggestion

# History substring search
git[Up]             # Shows previous git commands
[k/j]               # Navigate in normal mode

# Fuzzy navigation
[Esc] gd            # Fuzzy directory change (in normal mode)
[Esc] gf            # Fuzzy file picker
[Esc] gh            # Fuzzy history search

# Directory shortcuts
cd ~/D[Tab]         # Expands to ~/Development (or similar)
cd -                # Return to previous directory
~/.config/dotfiles  # Just type path and hit enter (auto-cd)

# Command substitution
echo "Today is $(date +%Y-%m-%d)"

# Aliases in action
ls                  # → eza --icons --git
cat README.md       # → bat README.md (syntax highlighted)
gitgraph            # → git log --decorate --graph

# History recall
!!                  # Repeat last command
!git                # Repeat last command starting with "git"
!$                  # Last argument of previous command
^old^new            # Replace old with new in previous command

# Globbing
ls **/*.zsh         # Recursive search for .zsh files
ls **/test_*.zsh    # Find all test files
```

**Result:** Command-line mastery with minimal keystrokes.

---

### Workflow 4: Git Workflow with Delta

**Scenario:** Reviewing changes and committing code.

```bash
# Check status (enhanced with colors)
git status

# Review changes with beautiful diffs
git diff            # Uses delta - syntax highlighted, side-by-side
git diff --staged   # Review staged changes

# Stage interactively
git add -p          # Patch mode - stage hunks interactively
# y - stage this hunk
# n - don't stage
# s - split into smaller hunks
# e - edit hunk manually

# View history
gitgraph            # Alias: git log --decorate --graph
git log -p          # Show patches with delta
git log --oneline   # Condensed view

# Commit with detailed message
git commit -m "Add feature X

- Implement Y
- Refactor Z
- Fix issue #123"

# Amend if needed
git commit --amend  # Modify last commit

# Interactive rebase (clean history)
git rebase -i HEAD~3  # Last 3 commits

# Stash for quick context switching
git stash           # Save work in progress
git stash list      # View stashes
git stash pop       # Restore and remove stash
```

**Result:** Clean commit history with beautiful diffs.

---

### Workflow 5: Multi-Window Neovim + Tmux

**Scenario:** Working on a feature across multiple files.

```bash
# In tmux, create layout:
Ctrl+a |            # Split vertically
nvim src/main.rs    # Left pane: implementation
nvim tests/test.rs  # Right pane: tests

# In Neovim (both panes):
# Synchronize panes temporarily if needed:
Ctrl+a y            # Toggle pane synchronization

# Left pane workflow:
Space ff            # Find file
Space fg "func"     # Search for function

# Right pane workflow:
Space ff test       # Find test file
:term               # Open terminal in split
cargo test          # Run tests

# Share yanks between vim instances via system clipboard:
Space y             # Yank to system clipboard (left pane)
Space p             # Paste from system clipboard (right pane)

# Create new tmux window for terminal work:
Ctrl+a c            # New window
cargo build --release
Ctrl+a 1            # Back to window 1 (editors)
```

**Result:** Seamless multi-file editing with live test feedback.

---

### Workflow 6: Terminal Multiplexer Mastery

**Scenario:** Managing multiple projects in one tmux session.

```bash
# Create named windows for different projects
Ctrl+a c            # New window
Ctrl+a ,            # Rename window: "backend"

Ctrl+a c            # Another window
Ctrl+a ,            # Rename: "frontend"

Ctrl+a c            # Another window
Ctrl+a ,            # Rename: "docs"

# Navigate between windows
Ctrl+a n            # Next window
Ctrl+a p            # Previous window
Ctrl+a 0-9          # Jump to window number
Ctrl+a l            # Last window

# Window with multiple panes:
Ctrl+a |            # Split vertically
Ctrl+a -            # Split horizontally
Ctrl+a Arrow        # Navigate panes

# Resize panes
Ctrl+a Alt+Arrow    # Resize in direction

# Copy between panes/windows:
Ctrl+a [            # Copy mode
/search             # Find text
v                   # Visual select
y                   # Yank
Ctrl+a ]            # Paste in any pane/window

# Session management:
Ctrl+a d            # Detach (session keeps running)
tmux ls             # List sessions
tmux attach -t ƛ    # Reattach

# Save current layout:
# Tmux resurrect plugin would save layouts automatically
# Manual: rerun the split commands
```

**Result:** Professional multi-project workspace.

---

### Workflow 7: Search and Navigation

**Scenario:** Finding files and text across a large codebase.

**In Shell:**
```bash
# Find files
fd "pattern"        # Fast find alternative
fd -e rs            # Find .rs files
fd -e js src/       # Find .js files in src/

# Search file contents
rg "TODO"           # Ripgrep - ultra-fast search
rg -i "fixme"       # Case-insensitive
rg "pattern" -t rust # Search only Rust files
rg "pattern" --hidden # Include hidden files

# Fuzzy find with fzf (if installed)
fd | fzf            # Fuzzy select file
history | fzf       # Fuzzy search history
```

**In Neovim:**
```bash
nvim .

# Inside Neovim:
Space ff            # Telescope: fuzzy find files
Space fg            # Telescope: live grep
Space fb            # Telescope: find in buffers
Space fh            # Telescope: search help tags

# Navigate to symbol:
gd                  # Go to definition
gr                  # Find references
Space fs            # Find symbols in document

# Quick fix list:
:copen              # Open quickfix window
:cnext              # Next item
:cprev              # Previous item
```

**Result:** Find anything in seconds.

---

### Workflow 8: Terminal Customization On-The-Fly

**Scenario:** Adjusting your environment mid-session.

```bash
# Change terminal colorscheme (Kitty):
# Edit ~/.config/kitty/kitty.conf
vim ~/.config/kitty/kitty.conf
# Uncomment different theme
Ctrl+Cmd+,          # Reload Kitty config (macOS)

# Change shell prompt:
vim ~/.config/starship/starship.toml
# Edit prompt modules
exec zsh            # Reload shell

# Add new alias:
echo 'alias gp="git push"' >> ~/.aliases
source ~/.aliases

# Quick shell function:
function mkcd() { mkdir -p "$1" && cd "$1" }
mkcd ~/new-project

# Make it permanent:
vim ~/.zshrc        # Add function there
```

**Result:** Tailored environment without restart.

---

### Workflow 9: Debugging and Troubleshooting

**Scenario:** Something isn't working - time to debug.

**Check tool availability:**
```bash
# Verify commands exist
which nvim          # Check if in PATH
command -v git      # Another way

# Check versions
nvim --version
git --version
zsh --version
tmux -V

# Check symlinks
ls -la ~/.zshrc
ls -la ~/.config/nvim

# Verify PATH
echo $PATH | tr ':' '\n'  # Show PATH entries
```

**Shell debugging:**
```bash
# Enable debug mode
set -x              # Print commands as executed
# Your commands here
set +x              # Disable debug mode

# Check what's loading:
zsh -xv             # Very verbose zsh startup

# Profile zsh startup:
time zsh -i -c exit # Time shell initialization
```

**Vim debugging:**
```vim
:checkhealth        # Neovim health check
:messages           # View messages
:verbose set bg?    # See where option was set
:scriptnames        # List loaded scripts
```

**Tmux debugging:**
```bash
# List current settings
tmux show -g        # Show global options
tmux list-keys      # Show keybindings

# Check if tmux sees your terminal colors
tmux info           # Terminal info
```

**Result:** Quick problem identification and resolution.

---

### Workflow 10: Scripting and Automation

**Scenario:** Automating repetitive tasks with shell scripts.

```bash
# Create a script
vim ~/.local/bin/deploy

# Script content:
#!/usr/bin/env zsh

# Load dotfiles libraries for beautiful output
source "$HOME/.config/dotfiles/bin/lib/colors.zsh"
source "$HOME/.config/dotfiles/bin/lib/ui.zsh"

draw_header "Deployment Script" "Deploying application"
echo

draw_section_header "Building Project"
cargo build --release || {
    print_error "Build failed"
    exit 1
}
print_success "Build completed"
echo

draw_section_header "Running Tests"
cargo test || {
    print_error "Tests failed"
    exit 1
}
print_success "All tests passed"
echo

draw_section_header "Deploying"
scp target/release/app server:/opt/app/
print_success "Deployment complete!"
echo

print_success "$(get_random_friend_greeting)"

# Make executable:
chmod +x ~/.local/bin/deploy

# Use it:
deploy
```

**Result:** Professional-looking automated workflows.

---

## Getting Help

**For Management System:**
- [README.md](../README.md) - Quick start and overview
- [INSTALL.md](INSTALL.md) - Detailed installation guide
- [CLAUDE.md](CLAUDE.md) - Developer guidance

**For Neovim:**
- [lualoves.nvim README](https://github.com/Buckmeister/lualoves.nvim/blob/main/README.md) - Neovim manual

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
