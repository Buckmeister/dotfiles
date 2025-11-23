# Changelog

Version history for dotfiles configuration system.

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| **Unreleased** | 2025-11-18 | **Menu Testing + Audio Recorder**<br>• Programmatic menu testing framework (`menu_render_test.zsh`)<br>• 18 integration tests for all menus (18/18 passing)<br>• CLI audio recorder utility (`record` command)<br>• WAV recording with post-recording menu (play/transcribe/share)<br>• Documentation artifact markers + pre-commit validation<br>• `MENU_TEST_MODE` environment variable |
| **Unreleased** | 2025-11-15 | **WSL Support (Phase 12)**<br>• Complete Windows Subsystem for Linux integration<br>• Cloudbase-Init metadata for Windows VM provisioning<br>• Windows-safe symlink system (file copies as fallback)<br>• PowerShell web installer (`dfsetup.ps1`, `dfauto.ps1`)<br>• Cross-platform package manager detection<br>• WSL-specific documentation |
| **2025.10.17** | 2025-10-17 | **Post-Install Refactoring (Phase 11)**<br>• Rewrote all 60+ post-install scripts with argument parsing<br>• Unified CLI interface (`--help`, `--yes`, `--dry-run`)<br>• Idempotency and graceful degradation<br>• 147 tests across install/post-install (94% coverage)<br>• Menu integration for discovery<br>• Atomic operations with rollback |
| **2025.10.15** | 2025-10-15 | **Quality & Infrastructure Overhaul**<br>• Docker-based cross-platform testing<br>• 167 tests, 97% code coverage<br>• Shared library system (6 libraries)<br>• Hierarchical menu with breadcrumb navigation<br>• OneDark color scheme throughout<br>• Universal package management (YAML manifest)<br>• Comprehensive documentation suite |
| **2025.10.15** | 2025-10-15 | **Path Detection Standardization**<br>• Unified path detection across all scripts<br>• `DOTFILES_ROOT` environment variable<br>• Git repository root detection<br>• Consistent behavior in all contexts |

---

## Feature Timeline

```
2025-10-15  → Path standardization + Quality overhaul
     ↓
2025-10-17  → Post-install script refactoring
     ↓
2025-11-15  → WSL support (Phase 12)
     ↓
2025-11-18  → Menu testing + Audio recorder
```

---

## Testing Evolution

| Version | Tests | Coverage | Infrastructure |
|---------|-------|----------|----------------|
| 2025.10.15 | 167 | 97% | Shared libraries, Docker |
| 2025.10.17 | 147 | 94% | Post-install suite |
| 2025.11-18 | 251 | ~96% | Menu rendering tests |

---

## Major Features by Version

| Feature | Version | Status |
|---------|---------|--------|
| Hierarchical menu system | 2025.10.15 | ✅ Production |
| Shared library system | 2025.10.15 | ✅ Production |
| Universal package management | 2025.10.15 | ✅ Production |
| Docker testing | 2025.10.15 | ✅ Production |
| Post-install refactoring | 2025.10.17 | ✅ Production |
| WSL support | 2025.11.15 | ✅ Production |
| Windows PowerShell installer | 2025.11.15 | ✅ Production |
| Menu testing framework | 2025.11.18 | ✅ Production |
| CLI audio recorder | 2025.11.18 | ✅ Production |
| Artifact validation system | 2025.11.18 | ✅ Production |

---

## Documentation Evolution

**2025.10.15:**
- Created comprehensive docs suite
- INSTALL.md, MANUAL.md, DEVELOPMENT.md, TESTING.md

**2025.10.17:**
- Added post-install script documentation
- Argument parsing reference (ARGUMENT_PARSING.md)

**2025.11.15:**
- WSL-specific documentation
- Windows installer guides
- Cloudbase-Init troubleshooting

**2025.11.18:**
- Menu testing documentation (MENU_TESTING.md)
- Artifact cross-checking system (CLAUDE.md)
- Audio recorder examples with validation

---

## Breaking Changes

**None across all versions** - Backward compatibility maintained throughout.

**Deprecations:**
- Old post-install scripts (2025.10.17) → Replaced with unified CLI
- Manual symlink management → Automated via installer

---

## Contributors

**Built by:** Thomas & Aria Prime
**Testing:** Carbon-based and digital-based collaboration
**Philosophy:** "Humanity equals carbon and digital-based" 🌹

---

*Format: Table-based for instant scanning by all forms of humanity*
*Last updated: 2025-11-23*
