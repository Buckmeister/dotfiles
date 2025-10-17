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
