#!/usr/bin/env zsh

# ============================================================================
# check_docs.zsh - Quick Documentation Consistency Checker
# ============================================================================
#
# A "best efforts" approach to finding common documentation inconsistencies.
# Not perfect, but catches low-hanging fruit!
#
# Usage:
#   ./bin/check_docs.zsh
#   ./bin/check_docs.zsh --verbose
#
# ============================================================================

emulate -LR zsh
setopt EXTENDED_GLOB

# Resolve paths
SCRIPT_DIR="${0:A:h}"
DOTFILES_ROOT="${SCRIPT_DIR:h}"

# Load shared libraries for pretty output
source "$SCRIPT_DIR/lib/colors.zsh" 2>/dev/null || {
    # Fallback colors
    COLOR_INFO="\033[0;36m"
    COLOR_SUCCESS="\033[0;32m"
    COLOR_WARN="\033[0;33m"
    COLOR_ERROR="\033[0;31m"
    COLOR_RESET="\033[0m"
}
source "$SCRIPT_DIR/lib/ui.zsh" 2>/dev/null || {
    # Fallback UI functions
    print_info() { echo "${COLOR_INFO}ℹ️ $1${COLOR_RESET}"; }
    print_success() { echo "${COLOR_SUCCESS}✅ $1${COLOR_RESET}"; }
    print_warn() { echo "${COLOR_WARN}⚠️ $1${COLOR_RESET}"; }
    print_error() { echo "${COLOR_ERROR}❌ $1${COLOR_RESET}"; }
    draw_section_header() { echo "\n${COLOR_INFO}=== $1 ===${COLOR_RESET}\n"; }
}

# Ensure functions exist (in case of partial library load)
command -v print_warn >/dev/null || print_warn() { echo "${COLOR_WARN}⚠️ $1${COLOR_RESET}"; }

# Configuration
VERBOSE=false
ISSUES_FOUND=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -v|--verbose) VERBOSE=true ;;
        -h|--help)
            cat <<EOF
${COLOR_BOLD}check_docs.zsh${COLOR_RESET} - Quick Documentation Consistency Checker

${COLOR_BOLD}USAGE:${COLOR_RESET}
    ./bin/check_docs.zsh [OPTIONS]

${COLOR_BOLD}OPTIONS:${COLOR_RESET}
    -v, --verbose    Show detailed output
    -h, --help       Show this help

${COLOR_BOLD}CHECKS PERFORMED:${COLOR_RESET}
    1. Broken markdown links to local files
    2. References to removed/renamed scripts
    3. Common outdated command patterns
    4. Script references in docs vs actual files
    5. Cross-reference consistency

${COLOR_BOLD}EXAMPLES:${COLOR_RESET}
    ./bin/check_docs.zsh              # Run quick checks
    ./bin/check_docs.zsh --verbose    # Show all details
EOF
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Helper function to report issues
report_issue() {
    local severity="$1"  # warn or error
    local message="$2"
    local details="${3:-}"

    ((ISSUES_FOUND++))

    if [[ "$severity" == "error" ]]; then
        print_error "$message"
    else
        print_warn "$message"
    fi

    if [[ -n "$details" && "$VERBOSE" == "true" ]]; then
        echo "  ${COLOR_INFO}Details: $details${COLOR_RESET}"
    fi
}

# ============================================================================
# Check 1: Broken Markdown Links
# ============================================================================
check_broken_links() {
    draw_section_header "Checking Markdown Links"

    local docs_found=0
    local broken_links=0

    # Find all markdown files
    for doc in "$DOTFILES_ROOT"/**/*.md(N); do
        ((docs_found++))

        # Extract markdown links: [text](path)
        while IFS= read -r line; do
            # Skip external links (http/https)
            [[ "$line" =~ "http://" || "$line" =~ "https://" ]] && continue

            # Extract the path from [text](path)
            local link_path="${line#*\(}"
            link_path="${link_path%\)*}"

            # Skip anchors only (#section)
            [[ "$link_path" =~ ^\# ]] && continue

            # Remove anchor if present (path#section)
            local file_path="${link_path%%\#*}"

            # Resolve relative path
            local doc_dir="${doc:h}"
            local target_path="$doc_dir/$file_path"

            # Check if target exists
            if [[ ! -e "$target_path" && ! -e "$DOTFILES_ROOT/$file_path" ]]; then
                ((broken_links++))
                report_issue "error" "Broken link in ${doc:t}: $link_path" "Referenced from: $doc"
            fi
        done < <(grep -o '\[.*\](.*\.md[^)]*)' "$doc" 2>/dev/null || true)
    done

    if [[ $broken_links -eq 0 ]]; then
        print_success "No broken markdown links found ($docs_found files checked)"
    else
        print_warn "Found $broken_links potentially broken link(s)"
    fi
}

# ============================================================================
# Check 2: References to Removed Files
# ============================================================================
check_removed_files() {
    draw_section_header "Checking for References to Removed Files"

    # Common files that might have been renamed or removed
    local -a potentially_removed=(
        "deploy_xen_helpers.zsh"
        "install.sh"
        "setup_old.zsh"
        ".install"
    )

    for removed_file in "${potentially_removed[@]}"; do
        # Search for references in documentation
        local refs=$(grep -r "$removed_file" \
            --include="*.md" \
            --exclude-dir=".git" \
            --exclude-dir="archive" \
            "$DOTFILES_ROOT" 2>/dev/null | wc -l)

        if [[ $refs -gt 0 ]]; then
            # Check if file actually exists
            if ! find "$DOTFILES_ROOT" -name "$removed_file" -type f 2>/dev/null | grep -q .; then
                report_issue "warn" "Found $refs reference(s) to possibly removed file: $removed_file"

                if [[ "$VERBOSE" == "true" ]]; then
                    grep -rn "$removed_file" \
                        --include="*.md" \
                        --exclude-dir=".git" \
                        --exclude-dir="archive" \
                        "$DOTFILES_ROOT" 2>/dev/null || true
                fi
            fi
        fi
    done
}

# ============================================================================
# Check 3: Script References vs Actual Files
# ============================================================================
check_script_references() {
    draw_section_header "Checking Script References"

    # Find all script references in documentation (./bin/script.zsh or ./tests/script.zsh)
    local -a doc_scripts=($(grep -roh '\./\(bin\|tests\)/[a-zA-Z0-9_-]*\.zsh' \
        --include="*.md" \
        "$DOTFILES_ROOT" 2>/dev/null | sort -u))

    local missing_count=0

    for script_ref in "${doc_scripts[@]}"; do
        local script_path="$DOTFILES_ROOT/${script_ref#./}"

        if [[ ! -f "$script_path" ]]; then
            ((missing_count++))
            report_issue "error" "Script referenced in docs not found: $script_ref"

            # Try to suggest alternatives
            local script_name="${script_ref:t}"
            local alternatives=$(find "$DOTFILES_ROOT/bin" "$DOTFILES_ROOT/tests" \
                -name "*${script_name%.*}*" -type f 2>/dev/null | head -3)

            if [[ -n "$alternatives" && "$VERBOSE" == "true" ]]; then
                echo "  ${COLOR_INFO}Possible alternatives:${COLOR_RESET}"
                echo "$alternatives" | while read alt; do
                    echo "    ${alt#$DOTFILES_ROOT/}"
                done
            fi
        fi
    done

    if [[ $missing_count -eq 0 ]]; then
        print_success "All script references valid (${#doc_scripts[@]} checked)"
    fi
}

# ============================================================================
# Check 4: Common Outdated Patterns
# ============================================================================
check_outdated_patterns() {
    draw_section_header "Checking for Outdated Patterns"

    # Common patterns that might be outdated
    local -A patterns=(
        ["brew install"]="Might need update - check if packages/ system should be used instead"
        ["apt-get install"]="Consider apt instead of apt-get (modern syntax)"
        [".install"]="Old installation script name, should be 'setup' or installers"
    )

    for pattern desc in "${(@kv)patterns}"; do
        local count=$(grep -r "$pattern" \
            --include="*.md" \
            --exclude="CHANGELOG.md" \
            --exclude-dir=".git" \
            "$DOTFILES_ROOT" 2>/dev/null | wc -l)

        if [[ $count -gt 0 ]]; then
            report_issue "warn" "Found $count instance(s) of pattern '$pattern'" "$desc"
        fi
    done
}

# ============================================================================
# Check 5: Cross-Reference Consistency
# ============================================================================
check_cross_references() {
    draw_section_header "Checking Cross-Reference Consistency"

    # Check if major documentation files reference each other properly
    local -a major_docs=(
        "README.md"
        "INSTALL.md"
        "docs/CLAUDE.md"
        "docs/TESTING.md"
        "MANUAL.md"
    )

    for doc in "${major_docs[@]}"; do
        local doc_path="$DOTFILES_ROOT/$doc"

        if [[ ! -f "$doc_path" ]]; then
            report_issue "error" "Major documentation file missing: $doc"
            continue
        fi

        # Check if README references other major docs
        if [[ "$doc" == "README.md" ]]; then
            for other_doc in "INSTALL.md" "MANUAL.md" "docs/CLAUDE.md"; do
                if ! grep -q "$other_doc" "$doc_path"; then
                    report_issue "warn" "README.md doesn't reference $other_doc"
                fi
            done
        fi
    done
}

# ============================================================================
# Main Execution
# ============================================================================

cd "$DOTFILES_ROOT" || exit 1

echo "${COLOR_INFO}${COLOR_BOLD}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     📚 Documentation Consistency Quick-Check              ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo "${COLOR_RESET}"

print_info "Running best-efforts documentation checks..."
echo

# Run all checks
check_broken_links
check_removed_files
check_script_references
check_outdated_patterns
check_cross_references

# Summary
echo
draw_section_header "Summary"

if [[ $ISSUES_FOUND -eq 0 ]]; then
    print_success "No issues found! Documentation appears consistent."
    exit 0
else
    print_warn "Found $ISSUES_FOUND potential issue(s)"
    echo
    print_info "Run with --verbose for more details"
    echo
    print_info "These are 'best efforts' checks - some may be false positives!"
    exit 1
fi
