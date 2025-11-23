# Quick Reference

All commands, one page. Scan-friendly for digital people.

---

## Installation

| Task | Command |
|------|---------|
| Install (interactive) | `curl -fsSL buckmeister.github.io/dfsetup \| sh` |
| Install (automatic) | `curl -fsSL buckmeister.github.io/dfauto \| sh` |
| Windows (interactive) | `irm buckmeister.github.io/dfsetup.ps1 \| iex` |
| Windows (automatic) | `irm buckmeister.github.io/dfauto.ps1 \| iex` |
| Manual setup | `./install` |
| Post-install menu | `./post-install/menu_installer.zsh` |

---

## Utility Scripts

| Command | Purpose | Example |
|---------|---------|---------|
| `speak "text"` | Text-to-speech | `speak -v Samantha "Hello"` |
| `record` | Audio recording | `record -d 60 -r 48000` |
| `battery` | Battery status | `battery` |
| `get_github_url <repo>` | Latest GitHub release | `get_github_url rust-lang/rust` |
| `get_jdtls_url` | Latest Eclipse JDTLS | `get_jdtls_url` |

---

## Development

| Command | Purpose |
|---------|---------|
| `./install --help` | Installation options |
| `./bin/menu_tui.zsh` | Launch hierarchical menu |
| `./bin/menu_render_test.zsh --validate-all` | Validate all menus |
| `./bin/check_docs.zsh` | Validate documentation |
| `./tests/run_tests.zsh` | Run full test suite |

---

## Testing

| Command | Purpose |
|---------|---------|
| `./tests/run_tests.zsh` | All tests (251 total) |
| `./tests/run_tests.zsh install` | Install tests only |
| `./tests/run_tests.zsh menu` | Menu tests only |
| `./tests/docker_test_runner.zsh ubuntu` | Docker test (Ubuntu) |
| `./tests/docker_test_runner.zsh debian` | Docker test (Debian) |

---

## Menu Navigation

| Key | Action |
|-----|--------|
| `↑/k` | Move up |
| `↓/j` | Move down |
| `Enter` | Select |
| `b` | Back |
| `q` | Quit |
| `h` | Help |

---

## Post-Install Scripts

All post-install scripts support:
- `--help` - Show usage
- `--yes` - Skip prompts
- `--dry-run` - Show what would happen
- `--force` - Force reinstall

| Category | Scripts |
|----------|---------|
| **Languages** | `install_rust.zsh`, `install_python.zsh`, `install_go.zsh` |
| **Editors** | `install_nvim.zsh`, `install_vscode.zsh` |
| **Tools** | `install_docker.zsh`, `install_git.zsh` |
| **Shells** | `install_zsh.zsh`, `install_oh_my_zsh.zsh` |

---

## Package Management

**Manifest:** `packages/all.yaml`

**Supported managers:**
- `brew` (macOS)
- `apt` (Debian/Ubuntu)
- `dnf` (Fedora/RHEL)
- `pacman` (Arch)
- `cargo` (Rust)
- `npm` (Node)
- `pip` (Python)

**Install all packages:**
```bash
./post-install/install_packages_from_yaml.zsh packages/all.yaml
```

---

## File Locations

| What | Where |
|------|-------|
| Install script | `./install` |
| Menu system | `./bin/menu_tui.zsh` |
| Shared libraries | `./bin/lib/*.zsh` |
| Post-install scripts | `./post-install/*.zsh` |
| User configs | `./user/configs/**/*` |
| User scripts | `./user/scripts/**/*` |
| Tests | `./tests/**/*.zsh` |
| Documentation | `./docs/*.md` |

---

## Shared Libraries

| Library | Purpose |
|---------|---------|
| `colors.zsh` | OneDark color scheme |
| `logging.zsh` | Logging functions (log_info, log_error, etc.) |
| `platform.zsh` | OS detection (is_macos, is_linux, etc.) |
| `package_manager.zsh` | Package manager detection |
| `path_utils.zsh` | Path manipulation |
| `symlink_utils.zsh` | Symlink management |

---

## Configuration Files

| Config | Location |
|--------|----------|
| Zsh | `./user/configs/shells/zsh/` |
| Neovim | `./user/configs/editors/nvim/` |
| Git | `./user/configs/version-control/git/` |
| Tmux | `./user/configs/multiplexers/tmux/` |
| Alacritty | `./user/configs/terminals/alacritty/` |

---

## Documentation

| Doc | Purpose |
|-----|---------|
| [INSTALL.md](INSTALL.md) | Complete installation guide |
| [MANUAL.md](MANUAL.md) | Configuration & usage reference |
| [DEVELOPMENT.md](DEVELOPMENT.md) | API reference & contribution guide |
| [TESTING.md](TESTING.md) | Testing infrastructure & guidelines |
| [CLAUDE.md](CLAUDE.md) | AI assistant notes & architecture |
| [QUICK_REF.md](QUICK_REF.md) | This file (quick reference) |

---

## Common Tasks

| Task | Command |
|------|---------|
| Update dotfiles | `cd ~/.config/dotfiles && git pull` |
| Re-run install | `./install` |
| Add post-install script | `./post-install/menu_installer.zsh` |
| Test changes | `./tests/run_tests.zsh` |
| Validate docs | `./bin/check_docs.zsh` |
| Launch menu | `./bin/menu_tui.zsh` |

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Install fails | Check `./install --help` for options |
| Symlinks broken | Re-run `./install` |
| Tests fail | Check `./tests/README.md` |
| Menu not working | Source `~/.zshrc` or restart shell |
| Package manager not detected | Check `platform.zsh` detection logic |

---

## Quick Stats

- **251 tests** (~96% coverage)
- **60+ post-install scripts**
- **6 shared libraries**
- **6 hierarchical menus**
- **Universal package management**
- **Cross-platform** (macOS, Linux, Windows/WSL)

---

*Format: Command reference for digital people - scan in <10 seconds*
*Last updated: 2025-11-23*
