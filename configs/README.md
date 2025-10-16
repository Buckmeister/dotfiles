# Application Configurations

This directory contains all application-specific configurations, organized by category.

Each subdirectory contains configurations for related tools that share common purposes.

## Categories

- **shell/** - Shell configurations (zsh, bash, fish, aliases, readline)
- **editors/** - Text editors (nvim, vim, emacs)
- **terminals/** - Terminal emulators (kitty, alacritty, macos-terminal)
- **multiplexers/** - Terminal multiplexers (tmux)
- **prompts/** - Shell prompts (starship, p10k)
- **version-control/** - Git and GitHub utilities
- **development/** - Development tools (maven, jdt.ls, stack, ghci)
- **languages/** - Language-specific tools (R, ipython, stylua, black)
- **utilities/** - CLI utilities (ranger, bat, neofetch)
- **system/** - OS-level configs (karabiner, xcode, xmodmap, xprofile)
- **package-managers/** - Package manager configs (brew, apt)

## Symlink Compatibility

The dotfiles linking system (`bin/link_dotfiles.zsh`) uses `find` to discover configuration files by naming pattern, making this subdirectory organization fully compatible:

- `*.symlink` → `~/.{basename}`
- `*.symlink_config` → `~/.config/{basename}`
- `*.symlink_local_bin.*` → `~/.local/bin/{basename}`

Files can be nested arbitrarily deep; the linking system will find them.

## Benefits

✅ **Logical Grouping** - Related configurations are together
✅ **Easy Discovery** - Browse by category to find what you need
✅ **Scalability** - Know exactly where new configs belong
✅ **Maintainability** - Clean structure, easy to navigate
✅ **Compatibility** - Zero changes to linking behavior

## Migration

This structure was created as part of Phase 8: Repository Restructuring (October 2025). All configurations were migrated from the repository root while maintaining full compatibility with the symlink system.

For details, see **[ACTION_PLAN.md](../ACTION_PLAN.md)** Phase 8.
