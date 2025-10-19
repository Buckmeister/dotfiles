# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 📚 CRITICAL: Documentation Consistency and Artifact Cross-Checking

**⚠️ HIGHEST PRIORITY - PREVENT DOCUMENTATION DRIFT ⚠️**

Documentation examples that become outdated are worse than no documentation at all. This repository uses **artifact cross-checking** to automatically validate that documentation examples match actual script capabilities.

### The Problem: Documentation Drift

Documentation examples can become outdated when:
- Flags are renamed or removed from scripts
- New features are added but examples aren't updated
- Refactoring changes command-line interfaces
- Copy-paste errors introduce invalid examples

**Bad example** (outdated documentation):
```bash
# This flag doesn't exist anymore!
my_script --old-flag value
```

### The Solution: Artifact Markers

Link documentation code blocks to actual scripts using HTML comment markers. The `check_docs.zsh` validator will automatically cross-check examples against the script's `--help` output.

**Marker Syntax:**
```markdown
<!-- check_docs:script=./path/to/script.zsh -->
```bash
script_name --flag value
script_name -v "another example"
```
<!-- /check_docs -->
```

**What this does:**
1. Marks a code block for validation
2. Extracts all command examples within the block
3. Runs `script_name --help` to get available flags
4. Reports any undocumented or non-existent flags
5. Ensures documentation stays synchronized with code

### Real Example from README.md

```markdown
<!-- check_docs:script=./user/scripts/utilities/speak.symlink_local_bin.zsh -->
```bash
speak "Hello world"
speak -v Samantha "Hello from Samantha"
speak --voice "Alex" "Testing male voice"
speak -r 200 "Speaking quickly"
speak -f README.md
speak --list-voices
```
<!-- /check_docs -->
```

Running `./bin/check_docs.zsh` validates all these examples:
- ✅ All flags exist in speak's `--help` output
- ⚠️ Any invalid flags are immediately reported
- 🎯 Documentation stays accurate automatically

### When to Use Artifact Markers

**ALWAYS mark for validation:**
- 📖 **Usage examples** - Any command-line examples in documentation
- 🎓 **Tutorials** - Step-by-step instructions with commands
- 📋 **Quick reference** - Command syntax documentation
- 🔧 **Configuration guides** - Examples showing script options

**Skip marking for:**
- 📝 Conceptual explanations (no actual commands)
- 🗣️ Natural language descriptions
- 🎨 Output examples (not commands)

### Using check_docs.zsh

**Run validation anytime:**
```bash
./bin/check_docs.zsh              # Quick check
./bin/check_docs.zsh --verbose    # Detailed output
```

**What it checks:**
1. ✅ Broken markdown links to local files
2. ✅ References to removed/renamed scripts
3. ✅ Script references in docs vs actual files
4. ✅ Artifact example validation (if markers present)
5. ✅ Common outdated command patterns
6. ✅ Cross-reference consistency

**Best Practices:**
- Add artifact markers when documenting new scripts
- Run `check_docs.zsh` before committing documentation changes
- Fix any warnings about undocumented flags
- Keep markers up to date when refactoring scripts

**Example output:**
```
✅ All artifact examples valid (3 checked)
⚠️ Undocumented flag in example: --fake-flag
❌ Script referenced in docs not found: ./bin/old_script.zsh
```

### Rule of Thumb

**If you document command-line usage, wrap it in artifact markers!** This prevents examples from going stale and saves future debugging time.

---

## 📋 CRITICAL: Project Documentation Management

**⚠️ HIGHEST PRIORITY - ORGANIZATIONAL FRAMEWORK ⚠️**

These three files work together to track project progress. Understanding this system is essential for effective AI assistance!

### ACTION_PLAN.md - Concise Todo List
- **Purpose**: Short, scannable todo list of active and pending work
- **Format**: ~200-300 lines maximum - must stay concise!
- **Content**: Only active/pending tasks with current priorities
- **When to Update**:
  - Mark tasks complete (✅) as you finish them
  - Add new tasks as they arise
  - Adjust priorities based on user feedback
- **What NOT to do**:
  - Never let it grow beyond ~500 lines
  - Don't include detailed analysis or documentation
  - Don't archive completed phases here forever

### Meetings.md - Historical Archive (Deprecated)
- **Status**: NO LONGER PART OF WORKFLOW - kept for sentimental/historical reasons only
- **Git Status**: In `.gitignore` - NEVER commit!
- **Note**: Commit messages provide comprehensive documentation; Meetings.md archiving removed to reduce overhead

### CHANGELOG.md - Public Release History
- **Purpose**: Version-based changelog for public releases
- **Git Status**: Committed to repository
- **Format**: Follows Keep a Changelog format
- **When to Update**:
  - When making user-facing changes
  - Before tagging releases
  - For features, fixes, deprecations, breaking changes
- **Content**: User-facing changes only (not internal refactoring)

### Workflow for Completing Major Work

1. **During Work**: Mark tasks in ACTION_PLAN.md as complete (✅)
2. **After Completion**: Write comprehensive commit message with:
   - Summary and phase name
   - What was delivered (files, features, changes)
   - Impact and results
   - Technical details and decisions made
3. **For User-Facing Changes**: Update CHANGELOG.md [Unreleased] section
4. **Cleanup ACTION_PLAN.md**: Keep it lean (~200-300 lines max)
   - Move recently completed phases to "Recently Completed" section
   - Archive very old completed work (delete from ACTION_PLAN.md - it's in git history)
5. **Commit**: ACTION_PLAN.md and CHANGELOG.md together

### Example: After Completing Phase 7
```markdown
# In ACTION_PLAN.md (keep it short):
### Recently Completed (Last 30 Days) ✅
- Phase 7: Hierarchical Menu System (October 16, 2025)

### Active Projects
- Phase 8: Repository Restructuring (IN PROGRESS)
...

# In CHANGELOG.md (user-facing changes):
## [Unreleased]
### Added
- Hierarchical menu system with submenus for better organization
- Profile management integration in main menu
- Package management interface in TUI menu

# In git commit message (comprehensive details):
Complete Phase 7: Hierarchical Menu System

Delivered: Hierarchical menu, 3 new libraries, 15 tests
Impact: Unified interface for all dotfiles management
[Full technical details and implementation notes...]
```

### Key Principle: Keep ACTION_PLAN.md Lean

ACTION_PLAN.md is a **todo list**, not a **documentation repository**. Keep it focused on:
- **Active work** (currently in progress)
- **Pending tasks** (upcoming work)
- **Recently completed** (last 30 days)

**Target size**: 200-300 lines maximum

When it grows beyond this:
- Delete very old completed phases (they're in git history and commit messages)
- Move active work to the top for visibility
- Ensure every item is actionable or recently relevant

This ensures ACTION_PLAN.md remains scannable, survives context switches, and serves as a useful quick-reference task list.

---

## 🥪 CRITICAL: The Sandwich Approach

**⚠️ HIGHEST PRIORITY - PROVEN METHODOLOGY ⚠️**

The **Sandwich Approach** is our proven methodology for making high-quality changes to the repository. It earned its name because, like a delicious sandwich, documentation forms the "bread" that wraps around the implementation "filling" - and this combination creates something far better than the sum of its parts!

### Why This Works

The deployment system (bin/deploy.zsh) demonstrated this approach perfectly:

1. **Bottom Bread (Study Phase)**: By reading existing documentation and scripts first, we understood:
   - Established patterns and conventions
   - Shared library usage
   - Argument parsing styles
   - UI consistency requirements
   - Testing approaches

2. **The Filling (Implementation)**: Armed with this knowledge, we created:
   - Well-structured implementation matching existing patterns
   - Consistent use of shared libraries
   - Proper argument handling
   - Beautiful OneDark-themed UI
   - 26 comprehensive tests

3. **Top Bread (Documentation Update)**: We completed the sandwich by:
   - Updating README.md with user-facing documentation
   - Updating CLAUDE.md with architecture details
   - Creating clear usage examples
   - Documenting all features and options

**Result**: A feature that harmonizes perfectly with the existing codebase, feels native to the system, and is thoroughly documented!

### When to Use The Sandwich Approach

**ALWAYS use for:**
- 🎯 **New major features** (new scripts, systems, or subsystems)
- 🔧 **Significant refactoring** (affecting multiple files or patterns)
- 📦 **New integrations** (adding external tools or services)
- 🧪 **Test infrastructure changes** (new testing approaches)
- 📚 **Documentation overhauls** (restructuring or major additions)

**Can skip for:**
- 🐛 Quick bug fixes (single file, obvious solution)
- 📝 Typo corrections
- 🎨 Minor UI tweaks
- ⚙️ Small configuration adjustments

**Rule of Thumb**: If the work involves 3+ files or adds new patterns, use The Sandwich Approach!

### The Sandwich Approach Workflow

#### Phase 1: Study (Bottom Bread) 🔍

**Goal**: Understand before you build

```bash
# 1. Read relevant existing documentation
Read docs/CLAUDE.md          # Understand architecture and patterns
Read docs/README.md          # Understand user-facing features
Read docs/INSTALL.md         # Understand installation flows
Read ACTION_PLAN.md          # Check for related planned work

# 2. Study similar existing code
Read bin/setup.zsh           # For setup patterns
Read bin/menu_hierarchical.zsh  # For interactive UIs and hierarchical navigation
Read bin/librarian.zsh       # For status reporting
Read bin/lib/ui.zsh          # For UI functions
Read bin/lib/utils.zsh       # For utility functions

# 3. Study related test files
Read tests/unit/test_ui.zsh  # For testing patterns
Read tests/integration/      # For integration test approaches
```

**Deliverable**: Deep understanding of:
- How the system works
- What patterns are established
- Where your feature fits
- What documentation needs updating

#### Phase 2: Plan (Preparing the Filling) 📋

**Goal**: Create comprehensive implementation plan

```bash
# 1. Create or update ACTION_PLAN.md
Edit ACTION_PLAN.md

# Add new section with phases:
## Phase X: [Feature Name]

### Context
[Why this feature? What problem does it solve?]

### Goals
- Goal 1: [Specific deliverable]
- Goal 2: [Specific deliverable]

### Implementation Tasks
- [ ] Task 1: Study existing patterns
- [ ] Task 2: Design core functionality
- [ ] Task 3: Implement feature
- [ ] Task 4: Add tests
- [ ] Task 5: Update documentation

### Success Criteria
- Criterion 1: [How we know it's done]
- Criterion 2: [Quality standard]
```

**Deliverable**: Clear roadmap with:
- All tasks identified
- Dependencies understood
- Success criteria defined
- Estimated scope

#### Phase 3: Implement (The Filling) 🛠️

**Goal**: Build the feature following established patterns

```bash
# 1. Create implementation files
Write bin/new-script.zsh     # Following existing patterns
Write tests/test_new.zsh     # With comprehensive coverage

# 2. Use shared libraries consistently
# - Source colors.zsh, ui.zsh, utils.zsh
# - Use draw_section_header, print_success, etc.
# - Follow argument parsing patterns
# - Maintain OneDark theme

# 3. Follow coding standards
# - ~80 column width where readable
# - DRY principle (use existing functions)
# - Default values for parameters
# - Cross-platform compatibility

# 4. Test thoroughly
./tests/run_tests.zsh        # Run full test suite
./tests/test_new.zsh         # Run your new tests
```

**Deliverable**: Working feature that:
- Matches existing code style
- Uses shared libraries
- Has comprehensive tests
- Is cross-platform compatible

#### Phase 4: Document (Top Bread) 📚

**Goal**: Complete the documentation sandwich

```bash
# 1. Update user-facing documentation
Edit README.md
# - Add feature to appropriate section
# - Include usage examples
# - Document options and flags
# - Show common workflows

# 2. Update developer documentation
Edit docs/CLAUDE.md
# - Add to architecture overview
# - Document design decisions
# - Note patterns and conventions
# - Add to relevant sections

# 3. Update changelog
Edit CHANGELOG.md
# - Add to [Unreleased] section
# - Categorize: Added/Changed/Fixed
# - User-facing changes only

# 4. Update ACTION_PLAN.md
Edit ACTION_PLAN.md
# - Mark completed tasks ✅
# - Update progress notes
# - Adjust remaining work if needed

# 5. Archive to MEETINGS.md (for major features)
Edit MEETINGS.md
# - Add dated milestone entry
# - Document what was delivered
# - Note key decisions and results
# - Include metrics (lines, files, tests)
```

**Deliverable**: Complete documentation showing:
- How to use the feature
- How it works internally
- What changed (changelog)
- Historical record (meetings)

#### Phase 5: Commit & Celebrate 🎉

**Goal**: Ship it with confidence!

```bash
# 1. Final quality check
./tests/run_tests.zsh        # All tests pass?
./bin/librarian.zsh          # System healthy?
git status                   # All changes staged?

# 2. Create meaningful commit
git add .
git commit -m "Add [feature]: [clear description]

- Implementation: [brief notes]
- Tests: [test coverage]
- Documentation: [what was updated]

Co-Authored-By: Claude <noreply@anthropic.com>"

# 3. Push to remote
git push origin main

# 4. Celebrate!
speak --celebrate "Feature complete! All tests passing!"
```

**Deliverable**:
- Clean git history
- All changes committed
- Documentation in sync
- Tests passing
- Feature shipped! 🚀

### Example: The Deployment System Success Story

**Phase 1 - Study (Bottom Bread)**:
- Read bin/setup.zsh, bin/wizard.zsh, bin/backup_dotfiles_repo.zsh
- Studied shared libraries (colors.zsh, ui.zsh, utils.zsh, arguments.zsh)
- Reviewed existing test patterns
- Examined web installer architecture (dfauto/dfsetup)

**Phase 2 - Plan**:
- Created comprehensive 5-phase implementation plan
- Identified all requirements and edge cases
- Mapped out test coverage needed
- Planned documentation updates

**Phase 3 - Implement**:
- Created bin/deploy.zsh (560+ lines)
- Followed all existing patterns
- Used shared libraries consistently
- Created tests/test_deploy.zsh (26 tests)
- Created POSIX wrapper ./deploy
- Achieved 100% test pass rate

**Phase 4 - Document**:
- Updated README.md with Remote Deployment section
- Updated CLAUDE.md with deployment architecture
- Added usage examples and feature documentation
- Documented SSH setup and web installer modes

**Phase 5 - Ship**:
- Committed all changes (800ae3b)
- Pushed to GitHub
- All tests passing
- Feature ready to use!

**Result**: A feature that feels like it was always part of the system! 🎯

### Integration with ACTION_PLAN.md

The Sandwich Approach works beautifully with ACTION_PLAN.md:

1. **Phase 2 (Plan)**: Create or update ACTION_PLAN.md with your feature phases
2. **During Implementation**: Mark tasks complete as you work
3. **Phase 4 (Document)**: Update ACTION_PLAN.md status
4. **After Completion**: Archive milestone to MEETINGS.md

This creates a complete development lifecycle:
- **ACTION_PLAN.md**: Current work and future plans
- **MEETINGS.md**: Historical record of completed work
- **Documentation**: Always in sync with implementation

### Quick Reference Checklist

Before starting any significant feature:

- [ ] **Study Phase**: Read relevant docs and similar code
- [ ] **Plan Phase**: Create/update ACTION_PLAN.md
- [ ] **Implement Phase**: Build feature using established patterns
- [ ] **Test Phase**: Achieve comprehensive test coverage
- [ ] **Document Phase**: Update README, CLAUDE, CHANGELOG
- [ ] **Commit Phase**: Clean git history, meaningful messages
- [ ] **Celebrate Phase**: speak --celebrate "Done!"

### Benefits of The Sandwich Approach

✅ **Higher Quality**: Understanding patterns first leads to better implementations
✅ **Consistency**: New features feel native to the existing system
✅ **Maintainability**: Well-documented features are easier to maintain
✅ **Confidence**: Comprehensive testing and documentation provide peace of mind
✅ **Collaboration**: Clear documentation helps future contributors
✅ **Beautiful Code**: When everything harmonizes, the result is elegant
✅ **User Experience**: Users get complete, well-documented features

**Remember**: Documentation isn't overhead - it's an integral part of the development process that makes everything better! The "bread" makes the "sandwich" complete! 🥪

---

## Project Overview

This is a personal dotfiles repository featuring a beautifully crafted, cross-platform configuration management system. It uses a symlink-based architecture to manage configuration files across different applications and tools, with intelligent OS detection, an interactive TUI menu, and comprehensive automation.

The repository showcases a harmonious blend of technical sophistication and user-friendly design, with every component working together like a well-orchestrated symphony.

## Repository Architecture

### Repository Structure

The dotfiles are organized into logical categories for easy navigation and maintenance:

```
~/.config/dotfiles/
├── 📚 Documentation/              README, CLAUDE.md, ACTION_PLAN, guides
├── 🌐 install/                    Web installer scripts (dfauto, dfsetup, .ps1 versions)
├── 🎯 Entry Points/               setup, wizard, backup, librarian, update
├── 🛠️ Core Infrastructure/
│   ├── bin/                      Main scripts + shared libraries (lib/)
│   ├── tests/                    Test suite (251 tests across 15 suites)
│   ├── post-install/             Post-install script system
│   ├── packages/                 Universal package management
│   ├── profiles/                 Configuration profiles
│   └── env/                      Environment variables (versions, paths, packages)
├── 🎨 user/                       All user-facing deployables
│   ├── configs/                  Application configurations (→ ~/.*, ~/.config/*)
│   │   ├── shell/                zsh, bash, fish, aliases, readline
│   │   ├── editors/              nvim, vim, emacs
│   │   ├── terminals/            kitty, alacritty, macos-terminal
│   │   ├── multiplexers/         tmux
│   │   ├── prompts/              starship, p10k
│   │   ├── version-control/      git, github
│   │   ├── development/          maven, jdt.ls, ghci
│   │   ├── languages/            R, ipython, stylua, black
│   │   ├── utilities/            ranger, neofetch, bat, fzf
│   │   ├── system/               karabiner, xcode, xmodmap, xprofile
│   │   └── package-managers/     brew, apt
│   └── scripts/                  User executables (→ ~/.local/bin/*)
│       ├── shell/                shell, shorten_path
│       ├── development/          jdt.ls, install_maven_wrapper
│       ├── utilities/            battery, iperl, rustp, create_hie_yaml
│       ├── version-control/      get_github_url, get_jdtls_url
│       └── package-managers/     generate_brew_install_script
└── 📦 resources/                  screenshots, snippets, shared assets
```

**Benefits of the organized structure:**
- ✅ **Easy Discovery** - Browse by category to find configurations
- ✅ **Logical Grouping** - Related tools are together
- ✅ **Scalability** - Clear place for new configurations
- ✅ **Maintainability** - Clean, professional appearance
- ✅ **Full Compatibility** - Symlink system works seamlessly with subdirectories

The repository structure follows these conventions:

### Symlink Patterns
- `*.symlink` files → linked to `~/.{basename}`
- `*.symlink_config` directories → linked to `~/.config/{basename}`
- `*.symlink_local_bin.*` files → linked to `~/.local/bin/{basename}`

**Examples:**
- `user/configs/shell/zsh/zshrc.symlink` → `~/.zshrc`
- `user/configs/editors/nvim/nvim.symlink_config/` → `~/.config/nvim/`
- `user/scripts/version-control/get_github_url.symlink_local_bin.zsh` → `~/.local/bin/get_github_url`

The `link_dotfiles.zsh` script uses `find` to discover files by pattern, making subdirectory organization transparent to the linking system.

### Core Infrastructure

The system is built on a shared library architecture:

- **`bin/setup.zsh`** - Cross-platform setup orchestrator with automatic OS detection
- **`bin/menu_hierarchical.zsh`** - Hierarchical menu with breadcrumb navigation and organized categories (primary menu)
- **`bin/menu_tui.zsh`** - Legacy flat menu (available with `--flat-menu` flag)
- **`bin/librarian.zsh`** - System health checker and status reporter
- **`bin/link_dotfiles.zsh`** - Symlink creation engine
- **`bin/backup_dotfiles_repo.zsh`** - Comprehensive backup system
- **`bin/deploy.zsh`** - Remote deployment script for SSH-based distribution

### Shared Libraries (`bin/lib/`)

- **`colors.zsh`** - OneDark color scheme constants and theming
- **`ui.zsh`** - Progress bars, headers, and beautiful terminal output
- **`utils.zsh`** - OS detection, common utilities, and helper functions
- **`greetings.zsh`** - Friendly, encouraging messages for user interaction
- **`arguments.zsh`** - Standardized argument parsing (flags, validation, help messages)
- **`validators.zsh`** - Input validation and sanity checking
- **`dependencies.zsh`** - Dependency detection and resolution
- **`package_managers.zsh`** - Package manager abstractions and installation helpers

### Convenience Wrappers

- **`./setup`** - POSIX shell wrapper that ensures zsh is available before running `bin/setup.zsh`
- **`./backup`** - POSIX shell wrapper for `bin/backup_dotfiles_repo.zsh`
- **`./update`** - POSIX shell wrapper for `bin/update_all.zsh`
- **`./deploy`** - POSIX shell wrapper for `bin/deploy.zsh`

These wrappers provide helpful error messages and OS-specific installation instructions if zsh is missing.

### Update System (Phase 2 Enhancement)

The update system provides a centralized way to update all packages and toolchains:

- **`bin/update_all.zsh`** - Central update script with category filtering and dry-run mode
- **Version Pinning** - Control updates via `env/versions.env` (empty = auto-update, specific = pin)
- **Individual --update Flags** - Post-install scripts support `--update` for granular control
- **Menu Integration** - Press `u` in menu for one-click updates

### Test Infrastructure (Phase 3 Complete)

Comprehensive testing system with **251 tests across 15 suites** providing ~96% code coverage:

- **`tests/lib/test_framework.zsh`** - Lightweight zsh testing framework with beautiful OneDark output
- **`tests/unit/`** - 105 unit tests for shared libraries (colors, ui, utils, validators, package_managers, greetings)
- **`tests/integration/`** - 64 integration tests for workflows (symlinks, updates, librarian, post-install scripts)
- **`tests/test_docker.zsh`** - Unified Docker testing with PI script filtering and multiple test modes
- **`tests/run_tests.zsh`** - Test runner with detailed reporting and suite summaries
- **100% Pass Rate** - All tests consistently pass with fast execution (~90 seconds for full suite)
- **Test Coverage** - Comprehensive assertions, setup/teardown, mocking, and smoke tests

### One-Line Installation Scripts

The repository provides two installation modes accessible via GitHub Pages. The installer scripts are located in the `install/` directory and are automatically synced to GitHub Pages via the `sync-installers` workflow:

- **`install/dfsetup`** - Interactive installation with menu-driven post-install script selection
- **`install/dfauto`** - Automatic installation with all modules (non-interactive, installs everything)

Both scripts are available in Unix (sh) and Windows (PowerShell) versions, accessible at:
- `https://buckmeister.github.io/dfsetup` (Unix interactive)
- `https://buckmeister.github.io/dfauto` (Unix automatic)
- `https://buckmeister.github.io/dfsetup.ps1` (Windows interactive)
- `https://buckmeister.github.io/dfauto.ps1` (Windows automatic)

The workflow automatically copies files from `install/` to the GitHub Pages repository whenever changes are pushed to main.

### OS Detection and Context

The setup.zsh script automatically detects the operating system and exports context variables that all post-install scripts receive:

- `DF_OS`: Detected OS (macos, linux, windows, unknown)
- `DF_PKG_MANAGER`: Package manager (brew, apt, choco)
- `DF_PKG_INSTALL_CMD`: Installation command for the detected package manager

This allows all scripts to adapt their behavior cross-platform automatically.

## Common Commands

### Primary Setup (Recommended)

```bash
# Full cross-platform setup (creates symlinks, launches interactive menu)
./setup

# Skip post-install scripts (symlinks only)
./bin/setup.zsh --skip-pi

# Show help and detected OS information
./bin/setup.zsh --help
```

### Update System (New!)

```bash
# Quick and easy - use the convenient wrapper
./update                            # Update everything

# Or call the update script directly
./bin/update_all.zsh                # Same as ./update

# Update specific categories
./update --system                   # System packages only
./update --npm                      # npm packages only
./update --cargo                    # Rust packages only
./update --packages                 # All language packages

# Preview updates without applying
./update --dry-run

# Individual script updates
./post-install/scripts/npm-global-packages.zsh --update
./post-install/scripts/cargo-packages.zsh --update
./post-install/scripts/ruby-gems.zsh --update
```

### Testing

```bash
# Run all tests (251 tests across 15 suites)
./tests/run_tests.zsh

# Run unit tests only (105 tests)
./tests/run_tests.zsh unit

# Run integration tests only (146 tests)
./tests/run_tests.zsh integration

# Docker-based installation testing (requires Docker)
./tests/test_docker.zsh --quick                       # Fast smoke test
./tests/test_docker.zsh --comprehensive --quick       # Full feature validation
./tests/test_docker.zsh --enable-pi "git-*" --quick   # Test specific PI scripts
./tests/test_docker.zsh --skip-pi --all-distros       # Test all distros without PI
```

### Interactive Menu

The hierarchical menu system (`bin/menu_hierarchical.zsh`) provides an elegant, multi-level interface for dotfiles management:

**Hierarchical Navigation:**
- `↑`/`↓` or `j`/`k` - Move through options
- `Enter` - Execute action or enter submenu
- `ESC` or `h` - Return to parent menu
- `Space` - Select/deselect items (multi-select menus)
- `a` - Select all (multi-select menus)
- `q` - Quit from any level
- `?` - Show help

**Menu Organization:**
- 📦 Post-Install Scripts - Configure system components
- 👤 Profile Management - Configuration profiles
- 🧙 Configuration Wizard - Interactive setup
- 📋 Package Management - Universal package system
- 🔧 System Tools - Update, backup, health check

**Legacy Flat Menu:**
The original flat menu (`bin/menu_tui.zsh`) remains available with `./setup --flat-menu` flag for users who prefer the single-level interface

### Post-Install Scripts

All scripts in `post-install/scripts/` are modular and OS-aware:

```bash
# Individual post-install scripts
./post-install/scripts/cargo-packages.zsh       # Rust packages
./post-install/scripts/npm-global-packages.zsh  # Node.js global packages
./post-install/scripts/pip-packages.zsh         # Python packages
./post-install/scripts/ruby-gems.zsh            # Ruby gems
./post-install/scripts/language-servers.zsh     # LSP servers
./post-install/scripts/haskell-toolchain.zsh    # Haskell toolchain (GHCup, GHC, Stack)
./post-install/scripts/rust-toolchain.zsh       # Rust toolchain (rustup, cargo)
./post-install/scripts/starship-prompt.zsh      # Starship cross-shell prompt
./post-install/scripts/fonts.zsh                # Font installation
./post-install/scripts/vim-setup.zsh            # Vim/Neovim setup
./post-install/scripts/bash-preexec.zsh         # Bash preexec hook
./post-install/scripts/lombok.zsh               # Java Lombok

# Run all post-install scripts silently
./bin/librarian.zsh --all-pi
```

### Post-Install Script Control (.ignored and .disabled)

Users can selectively disable post-install scripts without deleting them:

```bash
# Temporarily disable (local-only, git-ignored)
touch post-install/scripts/fonts.zsh.ignored

# Permanently disable (can be checked into git and shared)
touch post-install/scripts/bash-preexec.zsh.disabled

# Re-enable by removing marker file
rm post-install/scripts/fonts.zsh.ignored
```

**How it works:**
- `is_post_install_script_enabled()` in `bin/lib/utils.zsh` checks for these markers
- Used by: `setup.zsh`, `menu_hierarchical.zsh` (and legacy `menu_tui.zsh`), `librarian.zsh`
- `.ignored` files are in `.gitignore` (local-only)
- `.disabled` files can be committed (team/profile sharing)

**Effect of disabled scripts:**
- Don't appear in the TUI menu
- Are skipped by `./setup --all-modules`
- Are excluded from `./bin/librarian.zsh --all-pi`
- Show count in Librarian's status: "💤 2 script(s) disabled/ignored"

**Use cases:**
- **Machine-specific configurations**: VM with no fonts needed
- **Profile-based setups**: Minimal vs. full development environment
- **Temporary testing**: Disable problematic scripts during debugging
- **Team standardization**: Share `.disabled` files via git
- **Containerized environments**: Skip GUI/desktop installations in Docker
- **Resource constraints**: Disable heavy installations on low-resource machines

**Example - Minimal Docker Profile:**
```bash
# Clone repository
git clone https://github.com/Buckmeister/dotfiles.git ~/.config/dotfiles
cd ~/.config/dotfiles

# Disable GUI/desktop-related scripts for containerized environments
touch post-install/scripts/fonts.zsh.disabled
touch post-install/scripts/karabiner.zsh.disabled

# Commit to git so all containers use this profile
git add post-install/scripts/*.disabled
git commit -m "Add Docker profile - disable desktop scripts"

# Now setup will skip GUI installations
./setup
```

**Testing:**
Comprehensive test coverage ensures this feature works correctly:
- Unit tests: `tests/unit/test_utils.zsh` (7 test cases)
- Integration tests: `tests/integration/test_post_install_filtering.zsh` (10 test cases)
- Test helpers: `tests/lib/test_pi_helpers.zsh` (for writing new tests)

### System Management

```bash
# Comprehensive system health check and status report
./bin/librarian.zsh

# System health check with test suite execution
./bin/librarian.zsh --with-tests

# Create a backup of the dotfiles repository
./backup

# Generate new brew install script from current system (deprecated)
~/.local/bin/generate_brew_install_script
```

### Remote Deployment

Deploy your dotfiles to remote servers via SSH with beautiful progress tracking:

```bash
# Interactive mode - prompts for hosts
./deploy

# Deploy to specific hosts
./deploy --hosts server1.example.com server2.example.com

# Deploy using hosts file
./deploy --hosts-file production_servers.txt

# Automatic deployment (non-interactive)
./deploy --auto --hosts server.example.com

# Parallel deployment to multiple hosts
./deploy --parallel --hosts host1 host2 host3

# Dry-run to test without executing
./deploy --dry-run --hosts testserver.local

# Custom SSH timeout for slow networks
./deploy --timeout 30 --hosts remote-server.example.com
```

**Features:**
- **Multi-Host Support**: Deploy to single or multiple servers with one command
- **Smart SSH Authentication**: Prefers key-based auth, falls back to password
- **Web Installer Integration**: Uses `dfauto` (automatic) or `dfsetup` (interactive) installers
- **Beautiful Progress Tracking**: OneDark-themed UI with status updates
- **Parallel or Sequential**: Choose deployment strategy based on your needs
- **Dry-Run Mode**: Test configuration before deploying
- **Hosts File Support**: Manage server lists in text files

**Hosts File Format:**
```
# Production servers
server1.example.com
server2.example.com

# Staging
staging.example.com
```

**SSH Setup:**
For best results, configure SSH key-based authentication:
```bash
ssh-keygen -t ed25519
ssh-copy-id user@host
```

**Web Installer Modes:**
- `dfsetup` (interactive): Guided installation with prompts
- `dfauto` (automatic): Non-interactive, installs everything

**Implementation:**
- Script: `bin/deploy.zsh` (560+ lines)
- Wrapper: `./deploy` (POSIX shell wrapper)
- Tests: `tests/test_deploy.zsh` (26 tests, 100% pass rate)
- Uses: Shared libraries (colors, ui, utils, arguments)

### Universal Package Management System (NEW!)

The dotfiles now include a **complete universal package management system** for cross-platform package installation and synchronization:

```bash
# Generate manifest from your current system
generate_package_manifest
# → Creates ~/.local/share/dotfiles/packages.yaml

# Install packages on a new machine
install_from_manifest
# → Installs all packages from manifest

# Keep manifest synchronized
sync_packages --push
# → Regenerates manifest and commits to git

# Additional options
generate_package_manifest -o ~/my-packages.yaml  # Custom location
install_from_manifest --dry-run                   # Preview only
install_from_manifest --required-only             # Essential packages only
install_from_manifest --category editor           # Specific category
sync_packages --push --message "Add new tools"    # Custom commit
```

**Features:**
- **Cross-Platform**: Works on macOS (Homebrew), Ubuntu/Debian (APT), and more
- **Universal Manifest**: One YAML file works everywhere
- **Package Manager Support**: brew, apt, cargo, npm, pipx, gem (with more planned)
- **Intelligent Installation**: Skips already installed, detects available package managers
- **Git Integration**: Version control your entire package environment
- **Beautiful UI**: OneDark-themed with progress indicators
- **Flexible Filtering**: By category, priority, or platform

**Documentation:**
- `packages/README.md` - Overview and usage guide
- `packages/SCHEMA.md` - Complete YAML specification
- `packages/base.yaml` - Curated base manifest with 50+ packages

**Use Cases:**
- System migration (export from old machine, install on new)
- Team standardization (share identical development environment)
- Disaster recovery (one-command reinstall everything)
- Multi-platform development (same packages on macOS and Linux)

**The Librarian** provides comprehensive system health reporting including:
- **Core System Status** - Dotfiles location, setup scripts, symlink counts, git status
- **Essential Tools** - Detection of git, curl, jq, zsh
- **Development Toolchains** - Version checking for Rust, Node.js, Python, Ruby, Go, Haskell, Java
- **Language Servers** - Detection of rust-analyzer, typescript-language-server, pyright, lua-language-server, gopls, haskell-language-server-wrapper, solargraph
- **Test Suite Status** - Test runner availability, unit/integration test counts, optional execution with `--with-tests`
- **Post-Install Scripts Catalog** - Lists all available scripts with executable status
- **GitHub Downloaders** - Status of get_github_url and get_jdtls_url tools
- **Configuration Health** - Checks for .zshrc, .vimrc, .tmux.conf, .gitconfig
- **Detailed Symlink Inventory** - Complete listing of symlinks in ~/.local/bin, ~/.config, and ~/ with broken link detection

### GitHub Downloaders

```bash
# General GitHub release/tag downloader
~/.local/bin/get_github_url -u username -r repository [options]

# Specialized JDT.LS downloader (handles quirky release patterns)
~/.local/bin/get_jdtls_url [--version VERSION] [--silent]
```

### Text-to-Speech (speak)

The `speak` utility provides delightful cross-platform audio feedback with automatic TTS engine detection:

```bash
# Basic usage
speak "Hello, friend!"

# Pipe from commands
echo "Build complete!" | speak

# Use different voices (macOS)
speak -v Alex "Testing different voice"
speak -v Daniel "Jolly good show!"  # British accent
speak -v "Serena (Premium)" "Premium neural voice"  # High-quality neural TTS

# Adjust speech rate (words per minute)
speak -r 200 "Speaking quickly"

# Celebration mode (enthusiastic tone)
speak --celebrate "All tests passing!"
speak --celebrate "Menu system refactoring complete!"

# Friendly greeting mode
speak --friendly "Welcome to your dotfiles"

# Alert mode (important messages)
speak --alert "Tests failed!"

# Read from file
speak -f README.md

# Integration with scripts
./setup && speak --celebrate "Dotfiles setup complete!"
./tests/run_tests.zsh && speak "Tests passing!" || speak --alert "Tests failed!"

# Background notifications
(sleep 300; speak "Time to take a break!") &
```

**Cross-Platform Support:**
- **macOS**: Uses built-in `say` command with premium neural voices
  - Serena (Premium) - Best quality British female (default)
  - Eddy (English (US)) - Natural male voice
  - Flo (English (US)) - Natural female voice
  - Full voice and rate control
- **Linux**: Auto-detects and uses best available TTS engine
  - **espeak-ng** (preferred) - Enhanced quality with natural voice variants
  - **espeak** (fallback) - Standard TTS with voice selection
  - **festival** (fallback) - Classic TTS engine
  - Install via: `sudo apt install espeak-ng` (Ubuntu/Debian)
- **Automatic Detection**: Intelligently selects the best available TTS engine for your platform

**Features:**
- Automatically strips ANSI color codes for clean speech
- Cross-platform voice selection (macOS voices, Linux espeak variants)
- Rate control for speech speed (words per minute)
- Three personality modes: celebrate, friendly, alert
- Supports stdin, arguments, or file input
- Comprehensive help system (`speak --help`)
- List available voices (`speak --list-voices`)
- Graceful fallback when no TTS engine available

**Use Cases:**
- Long-running task completion notifications
- Test suite success/failure announcements
- Build status updates
- Timer/reminder notifications
- Making terminal output more engaging and accessible
- Cross-platform audio feedback for scripts and tools

### Claude Code Acoustic Hooks (claude-hook-speak)

The `claude-hook-speak` script provides automatic acoustic feedback for Claude Code events using the speak utility:

**Location**: `user/scripts/utilities/claude-hook-speak.symlink_local_bin.zsh`
**Symlinks to**: `~/.local/bin/claude-hook-speak`
**Configuration**: `~/.claude/settings.json`

```bash
# The script receives JSON event data via stdin from Claude Code hooks
echo '{"eventType":"PostToolUse","tool":"Bash","result":{"success":true}}' | ~/.local/bin/claude-hook-speak
```

**Supported Events:**
- **PostToolUse** - Provides feedback after tool usage:
  - "Done" for successful operations
  - "Error occurred" for failures
- **SessionStart** - Announces session start with friendly greeting
- **SessionEnd** - Announces session completion
- **UserPromptSubmit** - Confirms prompt processing
- **Notification** - Context-aware feedback based on level (error/warning/info)
- **Stop** - Confirms user interruption

**Tool-Specific Feedback:**
- Bash: "Running command"
- Read: "Reading file"
- Edit/Write: "Writing file"
- Grep/Glob: "Searching"
- Other tools: Generic "Tool" sound

**Configuration Example** (`~/.claude/settings.json`):
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": ".*",
      "hooks": [{"type": "command", "command": "~/.local/bin/claude-hook-speak"}]
    }],
    "SessionStart": [{
      "matcher": ".*",
      "hooks": [{"type": "command", "command": "~/.local/bin/speak --friendly 'Claude Code session started'"}]
    }]
  }
}
```

**Features:**
- Non-blocking background execution (uses `&` for parallel audio)
- Cross-platform TTS fallback chain: speak → say → espeak-ng → espeak → silent
- Automatic TTS engine detection and graceful degradation
- JSON parsing with jq for event data extraction
- Always returns success (exit 0) to avoid blocking Claude Code
- Works seamlessly on macOS and Linux with automatic engine selection

### Testing and Validation

```bash
# System health check and comprehensive status
./bin/librarian.zsh

# Manual verification steps:
# 1. Run ./setup in clean environment
# 2. Check symlink creation with `ls -la ~` and `ls -la ~/.config`
# 3. Verify application configs load correctly
# 4. Use librarian.zsh to get comprehensive system status
```

## Configuration Structure

All application configurations are organized under `configs/` by functional category. The linking system automatically discovers and symlinks these configurations to their appropriate destinations.

### Shell Configurations (`configs/shell/`)
- **zsh**: Main shell with zplug plugin management
- **bash**: Backup configuration for compatibility
- **fish**: Fish shell configuration
- **aliases**: Shared command aliases across shells
- **readline**: Input line editing configuration

### Shell Prompts (`configs/prompts/`)
- **starship**: Cross-shell prompt with custom configuration
- **p10k**: Powerlevel10k theme configuration for zsh

### Editor Configurations (`configs/editors/`)
- **nvim**: Neovim configuration with lazy.nvim package manager (git submodule)
- **vim**: Classic Vim configuration
- **emacs**: Emacs configuration for macOS

### Terminal Emulators (`configs/terminals/`)
- **kitty**: Primary terminal emulator
- **alacritty**: Alternative terminal emulator
- **macos-terminal**: macOS Terminal.app configuration

### Terminal Multiplexers (`configs/multiplexers/`)
- **tmux**: Terminal multiplexer configuration

### Version Control (`configs/version-control/`)
- **git**: Git settings and diff-so-fancy integration
- **github**: GitHub CLI utilities and downloaders

### Development Tools (`configs/development/`)
- **maven**: Maven wrapper installation script
- **jdt.ls**: Eclipse JDT Language Server for Java
- **ghci**: GHC interactive environment (Haskell REPL)

### Language Configurations (`configs/languages/`)
- **R**: R profile configuration
- **ipython**: IPython configuration
- **stylua**: Lua code formatter settings
- **black**: Python code formatter settings

### Utilities (`configs/utilities/`)
- **ranger**: File manager configuration
- **neofetch**: System information display
- **bat**: Cat alternative with syntax highlighting

### System Integration (`configs/system/`)
- **karabiner**: Keyboard remapping for macOS
- **xcode**: Xcode configuration
- **xmodmap**: X11 keyboard modifier mapping
- **xprofile**: X11 session initialization

### Package Managers (`configs/package-managers/`)
- **brew**: Homebrew configuration and manifest generation
- **apt**: APT configuration

## Language Support

The dotfiles include comprehensive configurations for:

- **Rust**: Cargo packages, rust-analyzer LSP
- **Python**: IPython, pip packages, Python LSP servers
- **JavaScript/Node**: npm global packages, TypeScript support
- **Java**: JDT.LS language server, Maven wrapper
- **C#**: OmniSharp language server
- **Haskell**: GHC, Stack, HIE setup
- **Ruby**: Gems, Solargraph LSP
- **Go**: Go toolchain and gopls
- **And more...**

## Design Philosophy

### User Experience

This repository prioritizes a delightful user experience:

- **Friendly Messages**: Every output is warm and encouraging
- **Visual Consistency**: OneDark color scheme throughout
- **Progress Feedback**: Clear progress bars and status updates
- **Error Handling**: Helpful, actionable error messages with OS-specific guidance
- **Cross-Platform**: Seamless experience on macOS and Linux

### Code Organization

- **Shared Libraries**: DRY principle with reusable UI and utility functions
- **Modularity**: Each post-install script is independent and focused
- **Fallback Protection**: Graceful degradation when libraries are unavailable
- **Context Awareness**: All scripts receive OS and package manager context

### Backup Strategy

Installation scripts automatically backup existing configurations to `~/.tmp/dotfilesBackup-{timestamp}/` before creating symlinks. The `./backup` command creates comprehensive ZIP archives stored in `~/Downloads/dotfiles_repo_backups/`.

## Platform Support

### Fully Supported Platforms

- **macOS** (Primary) - Homebrew ecosystem, native `say` TTS, Karabiner, Hammerspoon
- **Ubuntu/Debian Linux** (Secondary) - APT package manager, espeak-ng/espeak TTS, X11 configs
- **WSL2 (Windows Subsystem for Linux)** (Fully Supported) - Complete WSL experience with:
  - Automatic WSL detection via `/proc/version` check
  - Dedicated `is_wsl()` helper function in `bin/lib/utils.zsh`
  - Windows interoperability features
  - Performance guidance and best practices
  - See **[docs/WSL.md](WSL.md)** for comprehensive guide

### Cross-Platform Features

- **Automatic OS Detection**: `get_os()` function returns `macos`, `linux`, `wsl`, or `windows`
- **Package Manager Detection**: Automatically detects and uses brew, apt, dnf, pacman, zypper
- **Context Variables**: All scripts receive `DF_OS`, `DF_PKG_MANAGER`, `DF_PKG_INSTALL_CMD`
- **Portable Configurations**: Shell, editor, and terminal configs work across all platforms

### WSL-Specific Implementation

The system includes dedicated WSL support:

**Detection** (`bin/lib/utils.zsh`):
```zsh
# Check if running on WSL
function is_wsl() {
    [[ "$(get_os)" == "wsl" ]]
}
```

**Usage in Scripts**:
```zsh
# Adapt behavior for WSL
if is_wsl; then
    # WSL-specific actions (path translation, Windows interop, etc.)
    export BROWSER="/mnt/c/Program Files/Mozilla Firefox/firefox.exe"
else
    # Standard Linux behavior
    export BROWSER="firefox"
fi
```

**Package Management**: WSL uses the same package manager detection as Linux (apt/dnf/pacman/zypper based on distro)

### Coming Soon

- **Windows Native** - PowerShell and cmd.exe support (partial support available via .ps1 installers)
- **Additional Linux Distros** - Fedora, Arch, openSUSE (partial support via package manager detection)

## Development Workflow

### Making Changes

1. Edit configuration files in their respective directories
2. Test changes locally
3. Use `./bin/librarian.zsh` to verify system health
4. Create meaningful git commits with clear messages
5. Push to GitHub

### Adding New Post-Install Scripts

1. Create script in `post-install/scripts/` with `.zsh` extension
2. Make it executable: `chmod +x post-install/scripts/your-script.zsh`
3. Use shared libraries for consistent UI:
   ```zsh
   source "$SCRIPT_DIR/../bin/lib/colors.zsh"
   source "$SCRIPT_DIR/../bin/lib/ui.zsh"
   source "$SCRIPT_DIR/../bin/lib/utils.zsh"
   source "$SCRIPT_DIR/../bin/lib/arguments.zsh"  # For standardized arg parsing
   ```
4. Use standardized argument parsing (see "Argument Parsing Patterns" below)
5. Access OS context via `$DF_OS`, `$DF_PKG_MANAGER`, `$DF_PKG_INSTALL_CMD`
6. Add to interactive menu automatically (detected by both hierarchical and flat menus)

### Argument Parsing Patterns

The repository uses a standardized argument parsing library (`bin/lib/arguments.zsh`) to eliminate code duplication and ensure consistent CLI behavior across all scripts.

**Standard Pattern for Simple Scripts:**
```zsh
# Load arguments library
source "$DF_LIB_DIR/arguments.zsh"

# Parse arguments using shared library
parse_simple_flags "$@"
is_help_requested && show_help

# Use parsed flags
[[ "$ARG_UPDATE" == "true" ]] && UPDATE_MODE=true
[[ "$ARG_DRY_RUN" == "true" ]] && DRY_RUN=true

# Validate no unknown arguments remain
validate_no_unknown_args "$@" || exit 1
```

**Available Standard Flags:**
- `ARG_HELP` - Help flag (-h, --help)
- `ARG_VERBOSE` - Verbose output (-v, --verbose)
- `ARG_DRY_RUN` - Dry-run mode (-n, --dry-run)
- `ARG_FORCE` - Force operation (-f, --force)
- `ARG_SILENT` - Silent mode (-s, --silent)
- `ARG_UPDATE` - Update mode (--update)
- `ARG_RESUME` - Resume mode (--resume)
- `ARG_RESET` - Reset mode (--reset)

**Helper Functions:**
- `is_help_requested()` - Check if help was requested
- `is_verbose()` - Check if verbose mode enabled
- `is_dry_run()` - Check if dry-run mode enabled
- `validate_no_unknown_args "$@"` - Validate no invalid options
- `standard_help_header "Script Name" "Description"` - Standard help formatting

**For Scripts with Custom Flags:**
```zsh
# Parse common flags first
parse_simple_flags "$@"
is_help_requested && show_help

# Then handle script-specific flags
for arg in "$@"; do
    case "$arg" in
        --custom-flag) CUSTOM=true ;;
        --dry-run|-n|--help|-h) ;; # Skip already handled flags
        *) print_error "Unknown option: $arg"; exit 1 ;;
    esac
done
```

**Migrated Scripts:**
- `post-install/scripts/cargo-packages.zsh` - Simple flags (--update, --help)
- `bin/wizard.zsh` - Custom flags with library validation (--resume, --reset)
- `bin/update_all.zsh` - Hybrid approach with category flags

**Benefits:**
- Reduces 200-600 lines of duplicated argument parsing code
- Consistent error messages and validation across all scripts
- Standardized help message formatting
- Easy to add new scripts with proper CLI behavior
- DRY principle applied to argument handling

### Adding New Configurations

1. Choose the appropriate category in `user/configs/` (shell, editors, terminals, utilities, etc.)
2. Create directory for application (e.g., `user/configs/utilities/myapp/`)
3. Add configuration files with appropriate symlink suffix
4. Run `./bin/link_dotfiles.zsh` to create symlinks
5. Verify with `./bin/librarian.zsh`

**Example - Adding a new utility:**
```bash
# Create directory in appropriate category
mkdir -p user/configs/utilities/mytool

# Add configuration with symlink suffix
echo "my config" > user/configs/utilities/mytool/mytool.symlink_config

# Create symlinks
./bin/link_dotfiles.zsh

# Verify
./bin/librarian.zsh
ls -la ~/.config/mytool
```

## Notes for AI Assistants

When working with this codebase:

- **Maintain Consistency**: Use the shared libraries for all UI output
- **Follow Conventions**: Respect the symlink naming patterns
- **Be Friendly**: Keep the warm, encouraging tone in all messages
- **Test Cross-Platform**: Consider both macOS and Linux when making changes
- **Use Context Variables**: Leverage `DF_OS`, `DF_PKG_MANAGER`, etc. for adaptability
- **Document Changes**: Update this file, README.md, and TESTING.md as appropriate
- **Write Tests**: Add tests for new functionality (see TESTING.md)
- **Update System Integration**: New package scripts should support `--update` flag
- **Version Pinning**: Document version control in `env/versions.env`
- **Preserve the Vision**: This is a "symphony" - every component should harmonize
- **Use Speak Generously**: See the CRITICAL section at the top of this file!
- **Follow Documentation Framework**: See the Project Documentation Management section at the top!

### Coding Standards and Style Guidelines

These standards ensure consistency, readability, and maintainability across the entire codebase.

#### Line Length and Formatting

- **Target**: ~80 column width whenever readability allows
- **Flexibility**: Exceed when it improves readability (e.g., long strings, URLs)
- **Principle**: Prioritize clarity over strict adherence
- **Examples**:
  ```zsh
  # Good: Fits in 80 cols, readable
  draw_section_header "Setup Complete" "Your environment is ready"

  # Also Good: Exceeds 80 cols but more readable than wrapped
  local long_url="https://github.com/buckmeister/dotfiles/releases/download/v1.0.0/package.tar.gz"

  # Avoid: Unnecessary wrapping that reduces readability
  draw_section_header \
      "Setup" \
      "Complete"
  ```

#### Code Consistency

**Look for inspiration in existing code:**
- **Study `bin/` directory**: Review core scripts for patterns
- **Check shared libraries** (`bin/lib/`): Use established functions
- **Follow existing patterns**: Match the style of similar scripts
- **Examples to reference**:
  - `bin/setup.zsh` - Argument parsing, OS detection
  - `bin/menu_hierarchical.zsh` - Hierarchical UI, breadcrumb navigation, user interaction
  - `bin/menu_tui.zsh` - Flat UI patterns, single-level menus
  - `bin/librarian.zsh` - Status reporting, system health
  - `bin/lib/ui.zsh` - Progress bars, headers, formatting
  - `bin/lib/utils.zsh` - Helper functions, path detection

#### DRY Principle (Don't Repeat Yourself)

**Reduce code duplication aggressively:**
- **Extract common patterns** into shared functions
- **Use existing library functions** instead of reimplementing
- **Check `bin/lib/` first** before writing new utilities
- **Examples**:
  ```zsh
  # Bad: Reimplementing path detection
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  DOTFILES_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

  # Good: Use standardized function
  init_dotfiles_paths  # Sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR

  # Bad: Custom error message formatting
  echo "ERROR: Something went wrong" >&2

  # Good: Use shared function
  print_error "Something went wrong"
  ```

#### Default Values and Parameter Handling

**Use defaults to reduce boilerplate:**
- **Parameter expansion** with defaults: `${VAR:-default}`
- **Sensible defaults** in function parameters
- **Optional parameters** with fallback values
- **Examples**:
  ```zsh
  # Good: Default values reduce complexity
  local output_file="${1:-~/.local/share/dotfiles/packages.yaml}"
  local verbosity="${VERBOSE:-0}"
  local dry_run="${DRY_RUN:-false}"

  # Good: Function with defaults
  function show_status() {
      local message="$1"
      local color="${2:-$UI_INFO_COLOR}"
      local prefix="${3:-ℹ}"

      echo "${color}${prefix} ${message}${COLOR_RESET}"
  }
  ```

#### Library Sourcing with Defaults

**Graceful fallback when sourcing libraries:**
- **Always provide error handling** for failed sourcing
- **Use `2>/dev/null` for optional libraries**
- **Clear error messages** for required libraries
- **Examples**:
  ```zsh
  # Required library with clear error
  source "$DF_LIB_DIR/colors.zsh" 2>/dev/null || {
      echo "Error: Could not load colors.zsh" >&2
      exit 1
  }

  # Optional library with fallback
  source "$DF_LIB_DIR/greetings.zsh" 2>/dev/null || {
      # Define minimal fallback
      function get_random_greeting() { echo "Hello"; }
  }
  ```

#### Package Management Integration

**Include universal package system when appropriate:**
- **Reference the package manifest** (`packages/base.yaml`) for installations
- **Use package categories** (editor, shell, dev-tools, etc.)
- **Support `--dry-run`** for package operations
- **Document package dependencies** in scripts
- **Examples**:
  ```zsh
  # Good: Reference package manifest
  print_info "Installing from manifest: ~/.local/share/dotfiles/packages.yaml"
  install_from_manifest --category=editor --priority=recommended

  # Good: Document package availability
  if command_exists cargo; then
      print_success "Rust toolchain available (see packages/base.yaml)"
  fi
  ```

#### Pre-Commit Quality Checklist

**Review before committing changes:**

1. **Test Suites**
   - [ ] Run `./tests/run_tests.zsh` - All tests pass?
   - [ ] New functionality has tests?
   - [ ] Edge cases covered?

2. **Documentation**
   - [ ] CLAUDE.md updated if architecture changed?
   - [ ] README.md updated if user-facing changes?
   - [ ] MEETINGS.md updated for major milestones?
   - [ ] Inline comments for complex logic?

3. **Code Quality**
   - [ ] Follows ~80 column guideline where readable?
   - [ ] Uses shared libraries (no duplication)?
   - [ ] Default values where appropriate?
   - [ ] Consistent with existing code style?
   - [ ] Cross-platform compatible?

4. **Error Handling**
   - [ ] Graceful failures with helpful messages?
   - [ ] Required dependencies checked?
   - [ ] User-actionable error guidance?

5. **Integration**
   - [ ] Compatible with package management system?
   - [ ] Uses OS context variables (`$DF_OS`, etc.)?
   - [ ] Integrates with shared libraries?
   - [ ] Works with existing workflows?

#### Quick Style Reference

```zsh
#!/usr/bin/env zsh

# Use standardized path detection
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

init_dotfiles_paths  # Sets DF_DIR, DF_SCRIPT_DIR, DF_LIB_DIR

# Load shared libraries
source "$DF_LIB_DIR/colors.zsh"
source "$DF_LIB_DIR/ui.zsh"
source "$DF_LIB_DIR/utils.zsh"

# Function with defaults and proper formatting
function install_package() {
    local package_name="$1"
    local package_manager="${2:-brew}"  # Default to brew
    local silent="${3:-false}"

    if [[ "$silent" != "true" ]]; then
        print_info "Installing $package_name via $package_manager"
    fi

    # Use shared functions
    if command_exists "$package_manager"; then
        "$package_manager" install "$package_name"
    else
        print_error "$package_manager not available"
        return 1
    fi
}

# Main function with clear structure
function main() {
    # Parse arguments with defaults
    local dry_run="${DRY_RUN:-false}"
    local verbose="${VERBOSE:-false}"

    # Use shared UI functions
    draw_section_header "Package Installation" \
                       "Installing development tools"

    # Show progress
    local total=10
    local current=0

    for package in "${packages[@]}"; do
        ((current++))
        draw_progress_bar "$current" "$total" "Installing packages"
        install_package "$package"
    done

    print_success "Installation complete!"
}

# Run if executed directly
if [[ "${(%):-%x}" == "${0}" ]]; then
    main "$@"
fi
```

#### Refactoring Workflow

When refactoring existing code:

1. **Read existing code** to understand current patterns
2. **Identify duplication** and extract to functions
3. **Check for library functions** that already exist
4. **Apply consistent formatting** (~80 cols where readable)
5. **Add default values** to reduce boilerplate
6. **Test thoroughly** after refactoring
7. **Update documentation** if behavior changed
8. **Run test suite** to verify no regressions

### Private Files and Local-Only Content

**MEETINGS.md Location and Status:**
- **Location**: `~/.config/dotfiles/MEETINGS.md` (inside the dotfiles repository)
- **Git Status**: Listed in `.gitignore` - NEVER commit to version control
- **Purpose**: Private meeting notes, project planning, and internal documentation
- **Content**: Meeting history, roadmap planning, personal notes, and project context
- **Important**: This file contains personal and private information and must remain local only

Other local-only files in `.gitignore`:
- `env/personal.env` - Personal environment variables
- `.claude/settings.local.json` - Claude Code local settings
- `archive/` - Archived legacy files
- Various cache and temporary files

**When working across multiple sessions:**
- MEETINGS.md provides valuable context about project history and decisions
- Reference it for understanding past work and future plans
- Update it with significant milestones and decisions
- Never suggest committing it or removing it from .gitignore

### Archive Folder for Obsolete Files

**Archive Location**: `archive/` (in repository root)
**Git Status**: Listed in `.gitignore` - archived content is not committed
**Purpose**: Safe storage for obsolete files that are no longer actively used but shouldn't be completely deleted

**When to Archive Files:**
- Documentation that has been superseded (but might be useful for reference)
- Planning documents that are complete/obsolete
- Legacy code that has been replaced
- Temporary files from completed experiments
- Any file that's obsolete but might have historical value

**Archive Best Practices:**
1. **Create subdirectories** in `archive/` by category:
   - `archive/obsolete-documentation/` - Old docs
   - `archive/legacy-install-scripts/` - Old scripts
   - `archive/experiments/` - Test code
2. **Always include a README.md** in each archive subdirectory explaining:
   - What files are archived
   - Why they were archived
   - What replaced them (with links)
   - Recovery instructions if needed
3. **Document in review notes** when archiving files
4. **Never archive ACTION_PLAN.md** - it's a living document, not obsolete

**Archive Folder Contents (as of 2025-10-15):**
- `archive/legacy-install-scripts/` - Old platform-specific install scripts (replaced by unified setup.zsh)
- `archive/obsolete-documentation/` - Superseded planning and status documents

**Important Files That Should NEVER Be Archived:**
- **ACTION_PLAN.md** - Living task registry (update frequently, never archive)
- **MEETINGS.md** - Historical journal (append-only, never archive)
- **CHANGELOG.md** - Project history (always current)
- Active configuration files
- Core infrastructure scripts

### Update System Patterns

When adding new package management scripts:

1. **Add `--update` flag** - Follow pattern from npm-global-packages.zsh
2. **Document in versions.env** - Add version variables with comments
3. **Integrate with update_all.zsh** - Add update function if needed
4. **Support dry-run** - Show what would be updated
5. **Maintain UI consistency** - Use shared libraries

### Testing Patterns

When adding new functionality:

1. **Write unit tests** for shared libraries in `tests/unit/`
2. **Write integration tests** for workflows in `tests/integration/`
3. **Run tests locally** before committing: `./tests/run_tests.zsh`
4. **Keep tests fast** - Unit tests should run in milliseconds
5. **Document test patterns** in TESTING.md if adding new approaches

The goal is to create not just a functional dotfiles system, but a delightful experience that brings joy to daily development work.

### ACTION_PLAN.md Approach (Best Practice)

For **complex improvements** involving multiple related tasks, use the ACTION_PLAN.md methodology:

#### When to Create an ACTION_PLAN.md

Create an action plan for:
- **Complex refactoring** involving multiple files or systems
- **Major feature additions** with interdependent tasks
- **Documentation overhauls** spanning multiple areas
- **Quality improvements** requiring systematic changes
- **Any work with 5+ distinct tasks** that benefit from organization

#### ACTION_PLAN.md as Living Document

**IMPORTANT**: `ACTION_PLAN.md` is an **active, living document** that should:
- **Never be marked as obsolete** during review sessions
- **Be updated frequently** as work progresses and priorities shift
- **Serve as the central task management registry** for current and future work
- **Track both near-term tasks** (what we're working on now) and **future enhancements** (what's coming next)
- **Remain in the repository root** for easy access and visibility

**Workflow Integration with MEETINGS.md**:
- **ACTION_PLAN.md** = Dynamic registry of current/future tasks (frequently updated, forward-looking)
- **MEETINGS.md** = Historical journal of completed milestones (append-only, retrospective)

**When Tasks Complete**:
1. Mark tasks complete in ACTION_PLAN.md (✅ checkmarks)
2. Add a comprehensive paragraph/section to MEETINGS.md documenting:
   - What was accomplished
   - Key decisions made
   - Results and impact
   - Links to created files or documentation
3. Keep the completed section in ACTION_PLAN.md for context (don't delete it)
4. This creates a beautiful journal in MEETINGS.md while maintaining planning context in ACTION_PLAN.md

**Example Workflow**:
```markdown
ACTION_PLAN.md:
- [x] Phase 1: Documentation (✅ Complete - see MEETINGS.md 2025-10-15)
- [x] Phase 2: Quality Infrastructure (✅ Complete - see MEETINGS.md 2025-10-15)
- [ ] Phase 3: Testing (In Progress)
- [ ] Phase 4: Advanced Features (Future)

MEETINGS.md:
## 🎉 Phase 1 & 2 Complete - Documentation & Quality Infrastructure
**Date**: October 15, 2025
**Delivered**: 11 files, 7200+ lines of documentation, full CI/CD, pre-commit hooks
**Impact**: Comprehensive documentation, automated testing, quality gates
**Details**: [Full description of work completed]...
```

#### ACTION_PLAN.md Structure

```markdown
# Action Plan: [Project Name]

## Context
Brief description of the problem or improvement opportunity.

## Goals
Clear objectives for what the plan aims to achieve.

## Phase 1: [Phase Name]
- [x] Task 1.1: Description (✅ Complete)
- [x] Task 1.2: Description (✅ Complete)
- [ ] Task 1.3: Description (In Progress)

## Phase 2: [Phase Name]
- [ ] Task 2.1: Description (Pending)
- [ ] Task 2.2: Description (Pending)

## Phase 3: [Phase Name]
(Continue as needed...)

## Success Criteria
How we know the plan is complete.

## Timeline
Estimated completion for each phase.
```

#### Execution Workflow

1. **Plan First**: Create comprehensive ACTION_PLAN.md with all phases
2. **Review Together**: Discuss priorities and scope with Thomas
3. **Tackle in Phases**: Complete 1-2 phases at a time
4. **Assess Progress**: After each phase, review before continuing
5. **Update ACTION_PLAN.md**: Mark completed tasks, adjust remaining work
6. **Document in MEETINGS.md**: Add completed milestone to the journal
7. **Update Supporting Docs**: Update README, CLAUDE.md, and other docs as you go

#### Benefits

- **Clear Organization**: All related work in one place
- **Manageable Chunks**: Break large projects into digestible pieces
- **Progress Tracking**: Easy to see what's done and what remains
- **Flexible Prioritization**: Can pause between phases to assess
- **Context Preservation**: Document rationale and decisions
- **Collaboration**: Thomas can review and adjust priorities
- **Historical Record**: MEETINGS.md captures completed work for future reference
- **Beautiful Journal**: Track the project's evolution over time

#### Example: Phases 1 & 2 Completion (2025-10-15)

**Context**: Repository needed better documentation and quality infrastructure.

**Phase 1: Documentation Enhancement** ✅ COMPLETE
- Task 1.1: Create bin/lib/README.md (1000+ lines API reference)
- Task 1.2: Create post-install/README.md (1280+ lines system guide)
- Task 1.3: Add workflow examples to README.md and MANUAL.md (20 examples)

**Phase 2: Consistency & Quality** ✅ COMPLETE
- Task 2.1: Standardize argument parsing patterns (analysis + documentation)
- Task 2.2: Add GitHub Actions CI/CD workflow (9 comprehensive test jobs)
- Task 2.3: Add pre-commit hooks (standalone + framework support)

**Result**:
- 6500+ lines of new documentation
- Comprehensive CI/CD pipeline
- Automated local validation
- Zero regressions, all tests passing
- **Documented in MEETINGS.md** for historical record

#### Best Practices

1. **Start with Analysis**: Understand the problem before planning
2. **Be Comprehensive**: Include all related tasks, even small ones
3. **Group Logically**: Related tasks in the same phase
4. **Prioritize Ruthlessly**: Most important phases first
5. **Stay Flexible**: Adjust plan as new information emerges
6. **Document Decisions**: Note why choices were made
7. **Celebrate Progress**: Mark tasks complete as you finish them
8. **Journal Milestones**: Move completed work to MEETINGS.md
9. **Never Archive ACTION_PLAN.md**: It's a living document, not obsolete documentation

### Manual Maintenance (MANUAL.md)

The repository includes **MANUAL.md** - a comprehensive user guide documenting all configurations, keybindings, and utility scripts. This is separate from the management system documentation (README.md, INSTALL.md, CLAUDE.md) and focuses on **what the configurations provide** rather than **how to install them**.

#### When to Update MANUAL.md

Update the manual when:
1. **Adding new configuration files** (new .symlink or .symlink_config directories)
2. **Adding new utility scripts** (.symlink_local_bin.* files)
3. **Changing keybindings** in tmux, zsh, vim, or terminal emulators
4. **Modifying behavior** of existing configurations
5. **Adding new features** to utility scripts
6. **Changing color schemes** or themes
7. **Updating the Neovim submodule** significantly

#### MANUAL.md Structure

The manual is organized by **user-facing functionality**:

**Main Sections:**
- **Shell Configurations** - zsh, bash, aliases, starship prompt
  - Keybindings and shortcuts
  - Plugin configurations
  - Custom functions
- **Terminal Multiplexer** - tmux configuration
  - All keybindings documented
  - Status bar format
  - Special features
- **Editor Configurations** - Neovim, Vim, Emacs
  - Links to Neovim submodule README
  - Configuration highlights
  - Keybinding reference
- **Terminal Emulators** - Kitty, Alacritty
  - Theme settings
  - Keybindings
  - Integration details
- **Development Tools** - Git, IPython, language configs
- **Utility Scripts** - All ~/.local/bin scripts
  - Usage examples
  - Options and flags
  - Integration notes
- **System Integration** - Karabiner, etc.
- **Appendix** - Color schemes, fonts, file locations

#### How to Update the Manual

When making changes to configurations:

1. **Read the affected config file** to understand the changes
2. **Update the relevant section** in MANUAL.md:
   - For keybindings: Update the key mapping tables
   - For features: Update the features list
   - For scripts: Update usage examples and options
3. **Keep examples current** - Show real, working examples
4. **Update the TOC** if adding new sections
5. **Test the examples** - Ensure documented commands actually work
6. **Cross-reference** - Link between related sections
7. **Preserve the tone** - Keep it user-friendly and helpful

#### Neovim Documentation

The Neovim configuration (git submodule at `nvim/nvim.symlink_config/`) maintains its own comprehensive README.md. The main MANUAL.md links to this rather than duplicating it. This keeps documentation close to the code and allows the Neovim config to evolve independently.

**When updating Neovim:**
- Update the submodule's README.md directly
- Update the main MANUAL.md only if:
  - The integration with dotfiles changes
  - The symlink location changes
  - The installation method changes

#### Manual vs. README vs. INSTALL

**README.md** - Quick start, project overview, installation commands
**INSTALL.md** - Detailed installation, troubleshooting, publishing forks
**MANUAL.md** - Configuration reference, keybindings, usage guide
**CLAUDE.md** - Development guidance, architecture, AI assistant notes

Think of it as:
- README = "How do I get started?"
- INSTALL = "How does the installation work?"
- MANUAL = "How do I use what I installed?"
- CLAUDE = "How does the system work internally?"

#### Quick Reference for Manual Updates

```bash
# After adding a new configuration file:
# 1. Read the config to understand features
Read path/to/new/config.symlink

# 2. Update MANUAL.md with new section
Edit MANUAL.md

# 3. Add to appropriate section:
#    - Features list
#    - Keybindings (if applicable)
#    - Usage examples
#    - Integration notes

# After adding a utility script:
# 1. Read the script to understand usage
Read path/to/script.symlink_local_bin.zsh

# 2. Update "Utility Scripts" section in MANUAL.md
#    - Script name and purpose
#    - Usage syntax
#    - Options and flags
#    - Examples (at least 2-3)
#    - Dependencies (if any)

# After modifying keybindings:
# 1. Find the relevant section (Shell/Tmux/Editor/Terminal)
# 2. Update the keybinding table
# 3. Note any changed behavior
```

#### Finding What Needs Documentation

Use these commands to discover configurations:

```bash
# Find all symlink files
find . -name "*.symlink" -o -name "*.symlink_config"

# Find all utility scripts
find . -name "*.symlink_local_bin.*"

# Check what's actually linked
ls -la ~/.config/
ls -la ~/.local/bin/
ls -la ~ | grep "^\."
```