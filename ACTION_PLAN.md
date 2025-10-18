# Dotfiles Action Plan

> **A concise todo list for active and pending tasks**
>
> **Last Updated:** October 16, 2025
> **Status:** Living document - update as work progresses
>
> **Note:** Completed phases are archived in Meetings.md

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


## Pending Projects

### Phase 14: Windows/WSL Testing Infrastructure 🪟 IN PROGRESS
**Goal:** Fix cloudbase-init issues and improve Windows/WSL testing automation
**Status:** In Progress (October 18, 2025)
**Priority:** Medium-High
**Methodology:** Using The Sandwich Approach

#### Context

The dotfiles repository has comprehensive Windows testing infrastructure in `tests/test_xen.zsh` with support for Windows VM provisioning via XCP-NG hypervisor and cloudbase-init. However, **cloudbase-init is not working yet** during Windows VM setup.

**Current Infrastructure:**
- ✅ `tests/test_xen.zsh` (1214 lines) - Main testing script with Windows support
- ✅ `tests/lib/xen_cluster.zsh` (499 lines) - Multi-host cluster management
- ✅ `tests/test_config.yaml` (591 lines) - Windows template configuration (w11)
- ✅ `docs/XEN_TESTING.md` (817 lines) - Comprehensive testing documentation
- ✅ `docs/WSL.md` (619 lines) - WSL user guide and troubleshooting

**Helper Scripts (on XCP-NG host):**
- `/root/aria-scripts/create-vm-with-cloudinit-iso.sh` (Linux VMs)
- `/root/aria-scripts/create-windows-vm-with-cloudinit-iso.sh` (Windows VMs)

#### Goals

1. **Diagnose cloudbase-init issues** - Identify why cloudbase-init is not working in Windows VMs
2. **Fix Windows VM provisioning** - Ensure automated setup works correctly
3. **Verify XEN guest tools** - Check if guest tools are installed in Windows template
4. **Test OpenSSH Server** - Ensure SSH access works via cloudbase-init
5. **Document troubleshooting** - Create comprehensive debugging guide
6. **Improve WSL testing** - Enhance WSL-specific test coverage

#### Implementation Tasks

**Phase 14.1: Investigation & Diagnosis** (~1.5 hours)
- [x] Test actual Windows VM creation to identify cloudbase-init failure points ✅
- [x] Examine cloudbase-init logs on failed VM ✅
- [x] Inspect helper script on XCP-NG host ✅
- [x] Check XEN guest tools in Windows template ✅

**Phase 14.2: Fixing Cloudbase-init Issues** (~2 hours)
- [x] Fix Issue #1: ISO Volume Label (changed to `config-2`) ✅
- [x] Fix Issue #2: Template State (created pristine w11cb template) ✅
- [x] Fix Issue #3: Network Profile (force Private profile via PowerShell) ✅
- [x] Fix Issue #4: ISO Storage Repository (use isostore1 for ISOs) ✅
- [x] Fix Issue #5: ISO Upload Method (direct copy + sr-scan for ISO SRs) ✅
- [ ] Fix Issue #6: Multiple CD-ROM drives conflict (in progress)

**Phase 14.3: WSL-Specific Testing** (~1 hour) *OPTIONAL*
- [ ] Add WSL detection tests to test_utils.zsh
- [ ] Create test_wsl_install.zsh for WSL validation
- [ ] Document WSL testing in XEN_TESTING.md

**Phase 14.4: Testing & Validation** (~1 hour)
- [ ] Smoke test Windows VM provisioning after fixes
- [ ] Test comprehensive Windows validation
- [ ] Test Windows-only test mode
- [ ] Manual cloudbase-init verification

**Phase 14.5: Documentation Updates** (~1 hour)
- [ ] Update XEN_TESTING.md with troubleshooting section
- [ ] Update WSL.md with testing information
- [ ] Create TROUBLESHOOTING_WINDOWS.md guide

**Phase 14.6: Final Verification & Commit** (~30 mins)
- [ ] Complete Windows VM test cycle
- [ ] Run full test suite
- [ ] Update MEETINGS.md with Phase 14 completion
- [ ] Commit and push changes

#### Success Criteria

- [x] 5/6 cloudbase-init issues fixed (Issues 1-5) ✅
- [ ] Issue #6 resolved (multiple CD-ROM drives)
- [ ] Windows VM (w11) provisions successfully with cloudbase-init
- [ ] OpenSSH Server installs and starts automatically
- [ ] SSH access works to Windows VM
- [ ] XEN guest tools report VM IP correctly
- [ ] `./tests/test_xen.zsh --basic --distro w11` passes completely
- [ ] WSL detection works correctly in dotfiles setup
- [ ] Documentation updated with troubleshooting steps

#### Estimated Time

- **Core Issues (14.1-14.2):** 3-4 hours (mostly complete)
- **WSL Testing (14.3):** 1 hour (optional)
- **Testing & Docs (14.4-14.5):** 2 hours
- **Total Required:** 5-6 hours
- **Total with Optional:** 6-7 hours

#### Current Status

**Progress:** 5/6 issues fixed, Issue #6 (multiple CD-ROM drives) in progress

**Working Documentation:**
- See `tests/WINDOWS_AUTOMATION_COMPLETE_GUIDE.md` for detailed issue tracking and solutions
- Active work log with VM details, commands, and verification procedures

**Next Steps:**
1. Resolve CD-ROM drive conflict (detach template's empty drive or use its position)
2. Test complete automation with Issue #6 fix
3. Document working solution and create handover documentation

---

### Phase 4: Future Enhancements ⏳ PENDING
**Goal:** Advanced features
**Status:** Pending discussion with Thomas
**Priority:** TBD

#### Tasks

- [ ] **Task 4.4:** Automatic update checker and self-update mechanism

**Note:** Tasks 4.2 (user profile system) and 4.3 (interactive wizard) were completed as part of Phase 4.5
**Note:** Task 4.1 (WSL support) moved to Phase 12 with detailed planning

**Estimated Time:** 8-12 hours

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
See **Meetings.md** for detailed archive of completed phases:

**2025 Completions:**
- Phase 1: Documentation Enhancement ✅
- Phase 2: Consistency & Quality ✅
- Phase 3: Testing & Validation ✅
- Phase 4.5: Profile & Package Management Integration ✅
- Phase 6: Documentation Excellence ✅ **(October 16, 2025)**
- Phase 7: Hierarchical Menu System ✅
- Phase 7.5: Emulate -LR zsh Cleanup ✅
- Phase 7.6: Menu System Library Consolidation ✅
- Phase 7.7: Text-to-Speech Utility (speak) ✅
- Phase 7.8: Directory Naming Refinement (config → env) ✅
- Phase 8: Repository Restructuring (configs/ organization) ✅ **(October 13-14, 2025)**
- Phase 9: User Directory Restructuring ✅ **(October 17, 2025)**
- Phase 10: User Scripts Refactoring ✅ **(October 17, 2025)**
- Phase 11: Post-Install Script Refactoring ✅ **(October 17, 2025)**
- Phase 12: Windows WSL Support ✅ **(October 17, 2025)**
- Phase 13: Hierarchical Menu Integration ✅ **(October 17, 2025)**

**Recent Completions (October 15-18, 2025):**
- ✅ Documentation organization (docs/ folder created)
- ✅ Web installer migration (install/ folder created)
- ✅ Archive cleanup (local-only enforcement)
- ✅ Project workflow documentation (CLAUDE.md updated)
- ✅ Documentation Excellence - comprehensive cross-references and polish (Phase 6)
- ✅ User directory semantic restructuring (user/configs + user/scripts)
- ✅ All user scripts refactored with shared libraries and OneDark theme
- ✅ Post-install toolchains split into focused modules
- ✅ Complete Windows Subsystem for Linux (WSL) support (Phase 12)
  - WSL detection in get_os() function
  - Cross-platform utilities (open, clip)
  - Comprehensive WSL.md documentation (619 lines)
  - WSL-compatible post-install scripts
- ✅ Hierarchical menu integration (Phase 13)

---

## Repository Status

**Overall Assessment:** 🌟🌟🌟🌟🌟 (5/5 stars)
**Project Health:** Excellent
**Code Quality:** Outstanding
**Test Coverage:** ~96% (251+ tests)
**Documentation:** Comprehensive

---

*This is a living document. Update it as work progresses and archive completed phases in Meetings.md.*
