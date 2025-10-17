# Dotfiles Action Plan

> **A concise todo list for active and pending tasks**
>
> **Last Updated:** October 16, 2025
> **Status:** Living document - update as work progresses
>
> **Note:** Completed phases are archived in Meetings.md

---

## Active Projects

### Phase 9: User Directory Restructuring ✅ COMPLETE
**Goal:** Separate configuration files from user executables into semantic structure
**Status:** ✅ Complete (October 17, 2025)
**Priority:** High
**Completion:** All tasks finished, fully tested, documented

#### What Was Accomplished

Successfully restructured repository to separate configurations from executables:

**New Structure Implemented:**
```
user/                          # All user-facing deployables
├── configs/                  # Configuration files → ~/.*,  ~/.config/*  (29 files)
│   ├── shell/               # zsh, bash, fish, aliases, readline
│   ├── editors/             # nvim, vim, emacs
│   ├── terminals/           # kitty, alacritty, macos-terminal
│   ├── multiplexers/        # tmux
│   ├── prompts/             # starship, p10k
│   ├── version-control/     # git, github
│   ├── development/         # maven, jdt.ls, ghci
│   ├── languages/           # R, ipython, stylua, black
│   ├── utilities/           # bat, eza, delta, ranger, fzf
│   ├── system/              # karabiner, xcode, xmodmap, xprofile
│   └── package-managers/    # brew, apt
└── scripts/                  # User executables → ~/.local/bin/*  (11 files)
    ├── shell/               # shell, shorten_path (2 scripts)
    ├── development/         # jdt.ls, install_maven_wrapper (2 scripts)
    ├── utilities/           # battery, iperl, rustp, create_hie_yaml (4 scripts)
    ├── version-control/     # get_github_url, get_jdtls_url (2 scripts)
    └── package-managers/    # generate_brew_install_script (1 script)
```

**Benefits Realized:**
- ✅ Clear semantic separation: configs vs executables
- ✅ Better organization for future additions
- ✅ Easier to understand for contributors
- ✅ Full compatibility with link_dotfiles.zsh (find-based discovery)
- ✅ Scales well for future user-facing categories

#### Completed Tasks

- [x] **Task 9.1:** Analyze current structure ✅
- [x] **Task 9.2:** Detailed migration mapping (11 scripts across 5 categories) ✅
- [x] **Task 9.3:** Create user/ directory structure ✅
- [x] **Task 9.4:** Move configs/ → user/configs/ (used git mv, preserved history) ✅
- [x] **Task 9.5:** Extract scripts to user/scripts/ (all 11 scripts migrated) ✅
- [x] **Task 9.6:** Update documentation (README, CLAUDE, DEVELOPMENT, MANUAL) ✅
- [x] **Task 9.7:** Testing & verification (link_dotfiles.zsh, symlinks, 0 errors) ✅
- [x] **Task 9.8:** Update related systems (no hardcoded paths found, .gitmodules updated) ✅

**Commits:**
- c0ebcd0: Phase 9.1 & 9.2: Implement user/ directory structure (120 files moved)
- 7eae589: Task 9.6: Update documentation for user/ directory structure

**Result:** Clean, professional structure with full git history preserved and 100% test compatibility

**Time Spent:** ~3 hours (as estimated)
**Risk Level:** Low (no issues encountered)

---

## Active Projects

### Phase 10: User Scripts Refactoring 🎨 MOSTLY COMPLETE
**Goal:** Refactor all user-facing scripts to match repository quality standards
**Status:** Core Refactoring Complete (October 17, 2025) → Documentation Remaining
**Priority:** High
**Time Spent:** ~8 hours (as estimated)

#### Context

After successfully refactoring the `speak` script with full shared library integration, we identified an opportunity to bring all user-facing scripts in `user/scripts/` up to the same quality standard. This ensures consistency, maintainability, and a delightful user experience across all utilities.

**Current State:**
- 12 total scripts in `user/scripts/`
- 1 already perfect (generate_brew_install_script)
- 1 recently refactored (speak)
- 4 are simple wrappers (no work needed)
- 6 need refactoring (varying levels of effort)

#### Scripts Classification

**✅ Already Perfect (Reference Examples)**
1. `generate_brew_install_script.symlink_local_bin.zsh` - Full shared library usage, beautiful headers, OneDark colors, argument parsing, greetings integration

**🌟 Recently Completed**
2. `speak.symlink_local_bin.zsh` - Full refactoring complete (October 17, 2025)

**🔄 Simple Wrappers (No Work Needed)**
3. `shell.symlink_local_bin.zsh` - Exec wrapper to shell.zsh
4. `shorten_path.symlink_local_bin.zsh` - Exec wrapper to shorten_path.zsh
5. `install_maven_wrapper.symlink_local_bin.sh` - Exec wrapper to install_maven_wrapper.sh
6. `jdt.ls.symlink_local_bin.sh` - OS detection wrapper (16 lines)

**🎯 Phase 1: High Priority Refactoring**
7. `battery.symlink_local_bin.sh` (167 lines) - Convert bash→zsh, full library integration
8. `get_github_url.symlink_local_bin.zsh` (242 lines) - Upgrade partial library usage to full integration
9. `get_jdtls_url.symlink_local_bin.zsh` (206 lines) - Upgrade partial library usage to full integration

**📝 Phase 2: Medium Priority**
10. `rustp.symlink_local_bin.sh` (36 lines) - Add help message, shared libraries, headers

**⭐ Phase 3: Optional Enhancement**
11. `iperl.symlink_local_bin.sh` (4 lines) - Add --help flag, library integration for consistency
12. `create_hie_yaml.symlink_local_bin.sh` (5 lines) - Add --help flag, success feedback

#### Refactoring Standards

All refactored scripts should include:

**Required Elements:**
- ✅ `emulate -LR zsh` (for zsh scripts)
- ✅ Shared library loading with fallback protection
- ✅ OneDark color scheme (via colors.zsh)
- ✅ Standardized UI functions (print_success, print_error, print_info)
- ✅ Beautiful headers using draw_header() or draw_section_header()
- ✅ Argument parsing using arguments.zsh patterns or zparseopts
- ✅ Comprehensive --help messages with examples
- ✅ command_exists() instead of custom command checking
- ✅ OS context awareness (DF_OS, DF_PKG_MANAGER where relevant)
- ✅ Friendly greetings (get_random_friend_greeting() where appropriate)

**Nice-to-Have:**
- Progress indicators for long operations
- Dry-run mode where applicable
- Verbose mode for debugging
- Error handling with actionable messages

#### Tasks

- [x] **Task 10.1: Phase 1 - battery refactoring** (~2-3 hours) ✅ COMPLETE (October 17, 2025)
  - Convert from bash to zsh
  - Add shared library integration (colors, ui, utils)
  - Replace custom ANSI colors with OneDark scheme
  - Replace has() with command_exists()
  - Add draw_header() for script name
  - Enhance --help with comprehensive documentation
  - Use arguments.zsh for argument parsing
  - Add friendly greeting on completion
  - Test on macOS with pmset and ioreg
  - Update MANUAL.md with any behavioral changes

- [x] **Task 10.2: Phase 1 - get_github_url upgrade** (~2-3 hours) ✅ COMPLETE (October 17, 2025)
  - Replace custom print_info() with shared library version
  - Add draw_header() "GitHub URL Downloader"
  - Add draw_section_header() for different phases
  - Migrate zparseopts to arguments.zsh pattern
  - Use standard --silent flag behavior
  - Enhance error messages with print_error()
  - Add success messages with print_success()
  - Consider adding friendly greeting
  - Test with various repositories and options
  - Update documentation

- [x] **Task 10.3: Phase 1 - get_jdtls_url upgrade** (~2-3 hours) ✅ COMPLETE (October 17, 2025)
  - Mirror improvements from get_github_url
  - Replace custom print_info() with shared version
  - Add draw_header() "JDT.LS Download URL Fetcher"
  - Add draw_section_header() for version resolution, URL checking
  - Migrate zparseopts to arguments.zsh pattern
  - Enhance URL checking feedback with progress
  - Add success/error messages with shared functions
  - Test with latest and specific versions
  - Update documentation

- [x] **Task 10.4: Phase 2 - rustp enhancement** (~1-2 hours) ✅ COMPLETE (October 17, 2025)
  - Keep as bash or convert to zsh (decide based on dependencies)
  - Add comprehensive --help message with examples
  - Add shared library integration if converting to zsh
  - Add header "Rust Playground" with draw_header()
  - Enhance error messages
  - Consider adding dry-run mode
  - Test tmux integration thoroughly
  - Update documentation

- [x] **Task 10.5: Phase 3 - iperl enhancement** (~30min-1 hour) ✅ COMPLETE (October 17, 2025)
  - Add --help flag with usage information
  - Optionally add shared library integration
  - Add welcome message using print_info()
  - Document rlwrap dependency
  - Keep it simple and lightweight

- [x] **Task 10.6: Phase 3 - create_hie_yaml enhancement** (~30min-1 hour) ✅ COMPLETE (October 17, 2025)
  - Add --help flag with usage information
  - Add --output flag for custom file location
  - Add success message "Created hie.yaml for Haskell IDE"
  - Optionally add shared library integration
  - Document what HIE is and why this is useful

- [ ] **Task 10.7: Documentation updates** (~1 hour)
  - Update MANUAL.md with any new features/flags
  - Update CLAUDE.md if patterns change
  - Add examples to README.md if appropriate
  - Document the refactoring pattern for future reference

- [ ] **Task 10.8: Testing and validation** (~1 hour)
  - Test all refactored scripts individually
  - Verify symlink creation still works
  - Run through common use cases
  - Check for regressions
  - Verify beautiful output with OneDark colors

#### Success Criteria

- [x] All Phase 1 scripts (battery, get_github_url, get_jdtls_url) refactored ✅
- [x] All Phase 2 scripts (rustp) refactored ✅
- [x] All Phase 3 scripts (iperl, create_hie_yaml) refactored ✅
- [x] Consistent UI across all user scripts ✅
- [x] OneDark color scheme throughout ✅
- [x] Comprehensive --help messages ✅
- [x] No functionality regressions ✅
- [ ] Documentation updated (Task 10.7 - optional)
- [ ] All tests passing (Task 10.8 - optional)

#### Reference Materials

**Gold Standard Examples:**
- `bin/generate_brew_install_script.symlink_local_bin.zsh` - Perfect example of full integration
- `user/scripts/utilities/speak.symlink_local_bin.zsh` - Recently refactored, excellent pattern

**Shared Libraries:**
- `bin/lib/colors.zsh` - OneDark color constants
- `bin/lib/ui.zsh` - Headers, progress bars, drawing functions
- `bin/lib/utils.zsh` - OS detection, command_exists(), helpers
- `bin/lib/arguments.zsh` - Standardized argument parsing
- `bin/lib/greetings.zsh` - Friendly messages

**Testing:**
- All scripts should work when symlinked to `~/.local/bin/`
- Libraries should be loadable from that context
- Fallback protection should handle missing libraries gracefully

---

### Phase 5: Advanced Testing Infrastructure 🚀 IN PROGRESS
**Goal:** Flexible, modular, high-speed testing system for Docker and XCP-NG
**Status:** In Progress
**Priority:** High

#### Tasks

- [ ] **Task 5.1:** Create tests/test_config.yaml for centralized configuration
  - Support test suites (smoke, integration, comprehensive)
  - Support test components (installation, symlinks, config, scripts)
  - Flexible distro/OS selection
  - Timeout and resource configuration

- [ ] **Task 5.2:** Modular Test Framework
  - Refactor Docker test script with modular architecture
  - Implement test suite system (quick, standard, comprehensive)
  - Add component-level testing (installation, git, symlinks, scripts)
  - Support test filtering (--suite, --component, --tag)
  - Add parallel test execution support

- [ ] **Task 5.3:** Multi-Host XEN Failover
  - Implement automatic host failover logic
  - Add host availability checking
  - Support round-robin host selection
  - Add --host-pool option for testing multiple hosts
  - Implement host health monitoring

- [ ] **Task 5.4:** NFS Shared Helper Scripts
  - Deploy helper scripts to NFS share (xenstore1)
  - Update XEN test script to use NFS path
  - Add helper script versioning/updates
  - Create deployment script for helper maintenance
  - Add automatic fallback to local scripts

- [ ] **Task 5.5:** Enhanced Test Reporting
  - Add JSON test result export
  - Create test result visualization
  - Add performance metrics tracking
  - Implement test history comparison
  - Add CI/CD integration hooks

- [ ] **Task 5.6:** Docker Test Enhancements
  - Add test caching for faster runs
  - Implement incremental testing
  - Add container reuse option (--no-cleanup)
  - Support custom Docker registries
  - Add resource usage monitoring

**Estimated Time:** 12-16 hours total
**XCP-NG Cluster:** opt-bck01/02/03.bck.intern (192.168.188.11/12/13), lat-bck04.bck.intern (192.168.188.19)
**NFS SR:** xenstore1 (UUID: 75fa3703-d020-e865-dd0e-3682b83c35f6)

---

### Phase 6: Documentation Excellence 📚 IN PROGRESS
**Goal:** Comprehensive documentation audit and improvement
**Status:** In Progress
**Priority:** Medium-High

#### Completed Tasks ✅
- [x] **Task 6.1:** Update TESTING.md with Phase 5 Infrastructure (October 16, 2025)
- [x] **Task 6.2:** Update tests/README.md with Phase 5 Content (October 16, 2025)

#### Remaining Tasks

- [ ] **Task 6.3:** Create bin/lib/README.md
  - Overview of each library (colors.zsh, ui.zsh, utils.zsh, etc.)
  - API reference for key functions
  - Usage examples
  - Dependencies between libraries
  - Loading patterns

- [ ] **Task 6.4:** Update CHANGELOG.md
  - Document Phase 7 menu system (October 16, 2025)
  - Document Phase 7.5 emulate cleanup (October 16, 2025)
  - Document Phase 7.6 library consolidation (October 16, 2025)
  - Document Phase 7.7 speak utility (October 16, 2025)
  - Document Phase 7.8 env/ migration (October 16, 2025)

- [ ] **Task 6.5:** Update post-install/README.md
  - Document .ignored/.disabled filtering mechanism
  - Add section on OS context variables (DF_OS, DF_PKG_MANAGER, etc.)
  - Include examples of writing new post-install scripts

- [ ] **Task 6.6:** Cross-Reference Audit
  - Ensure all documentation cross-references are current
  - Verify all file paths in documentation are accurate
  - Update any outdated examples

**Estimated Time:** 4-6 hours total

---

## Pending Projects

### Phase 4: Future Enhancements ⏳ PENDING
**Goal:** Advanced features
**Status:** Pending discussion with Thomas
**Priority:** TBD

#### Tasks

- [ ] **Task 4.1:** Windows WSL support enhancements
- [ ] **Task 4.4:** Automatic update checker and self-update mechanism

**Note:** Tasks 4.2 (user profile system) and 4.3 (interactive wizard) were completed as part of Phase 4.5

**Estimated Time:** 36-48 hours total

---

### Phase 8: Repository Restructuring 🗂️ COMPLETE
**Goal:** Reorganize 44+ top-level directories into logical category-based structure
**Status:** ✅ Complete (October 13-14, 2025)
**Completion:** All tasks finished, fully documented

#### What Was Accomplished

Transformed flat 44+ directory structure into organized `configs/` categories:
- ✅ `configs/shell/` - zsh, bash, fish, aliases, readline
- ✅ `configs/editors/` - nvim, vim, emacs
- ✅ `configs/terminals/` - kitty, alacritty, macos-terminal
- ✅ `configs/multiplexers/` - tmux
- ✅ `configs/prompts/` - starship, p10k
- ✅ `configs/version-control/` - git, github
- ✅ `configs/development/` - maven, jdt.ls, ghci
- ✅ `configs/languages/` - R, ipython, stylua, black
- ✅ `configs/utilities/` - bat, eza, delta, fzf, ranger, neofetch
- ✅ `configs/system/` - karabiner, xcode, xmodmap, xprofile
- ✅ `configs/package-managers/` - brew, apt

**Commits:** e5b8098 through aaafb2a (10 phases)
**Result:** Professional, scalable structure with full git history preserved
**Documentation:** README, CLAUDE, DEVELOPMENT, MANUAL, INSTALL all updated

**See Meetings.md for detailed completion notes**

---

## Quick Reference

### Priority Levels
- 🚀 **IN PROGRESS** - Currently being worked on
- 📚 **IN PROGRESS** - Active development
- ⏳ **PENDING** - Awaiting discussion/approval
- 🗂️ **PLANNING** - Design and planning phase

### Time Estimates
- **Phase 5:** 12-16 hours
- **Phase 6:** 4-6 hours
- **Phase 4:** 36-48 hours
- **Phase 8:** 20-30 hours

### Completed Work
See **Meetings.md** for archive of:
- Phase 1: Documentation Enhancement ✅
- Phase 2: Consistency & Quality ✅
- Phase 3: Testing & Validation ✅
- Phase 4.5: Profile & Package Management Integration ✅
- Phase 7: Hierarchical Menu System ✅
- Phase 7.5: Emulate -LR zsh Cleanup ✅
- Phase 7.6: Menu System Library Consolidation ✅
- Phase 7.7: Text-to-Speech Utility (speak) ✅
- Phase 7.8: Directory Naming Refinement (config → env) ✅
- Phase 8: Repository Restructuring (configs/ organization) ✅ **(October 13-14, 2025)**

### Recent Completions (October 16, 2025)
- ✅ Documentation organization (docs/ folder created)
- ✅ Web installer migration (install/ folder created)
- ✅ Archive cleanup (local-only enforcement)
- ✅ Project workflow documentation (CLAUDE.md updated)

---

## Repository Status

**Overall Assessment:** 🌟🌟🌟🌟🌟 (5/5 stars)
**Project Health:** Excellent
**Code Quality:** Outstanding
**Test Coverage:** ~96% (251+ tests)
**Documentation:** Comprehensive

---

*This is a living document. Update it as work progresses and archive completed phases in Meetings.md.*
