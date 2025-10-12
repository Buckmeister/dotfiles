# Neovim Configuration - lua.loves.nvim Reborn 🎵

*A modern, user-friendly Neovim configuration built with love and thoughtful design*

## 🌟 Philosophy

This configuration represents a fresh start for Thomas's Neovim journey, built with these principles:

- **Anxiety-Free Development**: Clean, well-documented, and easy to modify
- **Modern Lua Architecture**: Pure Lua configuration with clear module separation
- **Thoughtful Package Selection**: Each plugin chosen for a specific purpose
- **Guard Rails**: Structure and documentation to build confidence
- **Performance First**: Fast startup and responsive editing experience

## 🏗️ Architecture

### Directory Structure
```
nvim.symlink_config/
├── init.lua                    # Clean entry point
├── lua/
│   ├── config/                 # Core configuration
│   │   ├── options.lua         # Vim options & settings
│   │   ├── keymaps.lua         # Key mappings
│   │   └── autocmds.lua        # Auto commands
│   ├── plugins/               # Plugin configurations
│   │   ├── init.lua           # Plugin manager (lazy.nvim)
│   │   ├── ui.lua             # UI enhancements
│   │   ├── editor.lua         # Editor functionality
│   │   ├── lsp.lua            # Language Server Protocol
│   │   └── tools.lua          # Development tools
│   └── utils/                 # Utility functions
└── CLAUDE.md                  # This documentation
```

### Design Principles

1. **Modular Organization**: Each feature in its own file
2. **Clear Dependencies**: Explicit plugin loading order
3. **Minimal Core**: Only essential plugins, each serving a purpose
4. **Documentation**: Every choice explained and justified
5. **Evolution-Friendly**: Easy to add, remove, or modify features

## 🎯 Features Planned

### Core Editor Features
- **Plugin Manager**: lazy.nvim (modern, fast, lazy-loading)
- **Colorscheme**: OneDark (darker style) - Thomas's signature aesthetic
- **Welcome Screen**: Alpha dashboard with "LUA LOVES NVIM" ASCII art
- **Icons**: nvim-web-devicons with custom overrides
- **Statusline**: Lualine with Thomas's artistic Unicode numbers and responsive design
- **File Explorer**: nvim-tree with enhanced git integration and beautiful icons
- **Fuzzy Finding**: Telescope with fzf-native for blazing fast searching

### Language Support
- **LSP**: Native Neovim LSP with nvim-lspconfig
- **Completion**: nvim-cmp (most mature and flexible)
- **Treesitter**: Syntax highlighting and text objects
- **Formatting**: conform.nvim (successor to null-ls)
- **Diagnostics**: Native LSP + trouble.nvim for nice display

### Developer Experience
- **Git Integration**: To be discussed (gitsigns, fugitive, or neogit)
- **Terminal**: Integrated terminal support
- **Session Management**: To be discussed if needed
- **Debugging**: To be discussed (DAP integration)

## 📚 Migration Strategy

Features will be migrated from `/Users/Thomas/Development/nvim-nightly` through thoughtful discussion:

1. **Analyze Current Feature**: What does it do?
2. **Evaluate Necessity**: Do we still need this?
3. **Modern Alternative**: Is there a better plugin now?
4. **Clean Implementation**: Implement with modern best practices
5. **Document Decision**: Record why we chose this approach

## 🔄 Development Workflow

1. **Feature Discussion**: Talk through what we want to achieve
2. **Plugin Research**: Evaluate options and alternatives
3. **Implementation**: Add plugin with clean configuration
4. **Testing**: Ensure it works as expected
5. **Documentation**: Update this file with decisions made

## 🎵 Historical Context

This configuration is the spiritual successor to Thomas's original nvim-nightly and lua.loves.nvim projects. It maintains the passion for Lua + Neovim while providing a fresh, user-friendly foundation for continued development.

**Previous Projects:**
- `nvim-nightly`: Original experimental config with nightly downloader
- `lua.loves.nvim`: Evolved configuration that became too precious to modify
- `lualoves.nvim`: Kickstart.nvim-based restart attempt

**This Version:** Clean slate with guard rails, documentation, and confidence-building structure.

---

## 🚀 Getting Started

This configuration is automatically symlinked to `~/.config/nvim` via the dotfiles setup.zsh script.

**Commands:**
- `:Lazy` - Plugin manager interface
- `:checkhealth` - Neovim health check
- `:help` - Built-in help system

**Key Design Decision Log:**

**Visual Identity & UI:**
- **OneDark "darker" style**: Preserves Thomas's beloved aesthetic from original config
- **Alpha dashboard**: Migrated exact ASCII art and "LUA LOVES NVIM" branding
- **Enhanced welcome**: Added modern plugin stats and inspirational footer
- **Color highlighting**: nvim-colorizer for CSS/hex color visualization
- **Indent guides**: Clean vertical lines for code structure visualization

**Editor Experience:**
- **Lualine statusline**: Thomas's masterpiece with Unicode numbers (𝟏𝟐𝟑) and artistic progress display
- **Responsive design**: Components intelligently hide/show based on window width
- **nvim-tree**: Enhanced file explorer with git integration, diagnostics, and beautiful icons
- **Telescope**: Modern fuzzy finding with fzf-native for lightning-fast file/text search

---

*Built with love by Thomas & Aria - Combining technical precision with artistic vision* 💙