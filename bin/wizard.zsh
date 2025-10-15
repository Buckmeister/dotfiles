#!/usr/bin/env zsh

# ============================================================================
# Dotfiles Interactive Configuration Wizard
# ============================================================================
#
# A warm, welcoming first-time setup experience that guides users through
# configuring their dotfiles with care and intelligence.
#
# Features:
# - Beautiful OneDark-themed interface
# - International greetings and multilingual support
# - Smart environment detection
# - Intelligent package recommendations
# - Personal configuration generation
# - Save and resume capability
# - Graceful navigation (back/forward)
#
# Usage:
#   ./bin/wizard.zsh [OPTIONS]
#
# Options:
#   --resume        Resume from saved state
#   --reset         Start fresh (delete saved state)
#   --help, -h      Show this help message
#
# Created with love by Aria for the dotfiles community 🌸
# ============================================================================

emulate -LR zsh

# ============================================================================
# Path Detection and Library Loading
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/utils.zsh" 2>/dev/null || {
    echo "Error: Could not load utils.zsh" >&2
    exit 1
}

init_dotfiles_paths

# Load shared libraries
source "$DF_LIB_DIR/colors.zsh" 2>/dev/null || {
    echo "Error: Could not load colors.zsh" >&2
    exit 1
}

source "$DF_LIB_DIR/ui.zsh" 2>/dev/null || {
    echo "Error: Could not load ui.zsh" >&2
    exit 1
}

source "$DF_LIB_DIR/greetings.zsh" 2>/dev/null || {
    echo "Error: Could not load greetings.zsh" >&2
    exit 1
}

source "$DF_LIB_DIR/arguments.zsh" 2>/dev/null || {
    echo "Error: Could not load arguments.zsh" >&2
    exit 1
}

# ============================================================================
# Configuration & State Management
# ============================================================================

# Wizard state file
readonly WIZARD_STATE_FILE="$HOME/.dotfiles_wizard_state"
readonly WIZARD_CONFIG_FILE="$HOME/.config/dotfiles/personal.env"

# Wizard configuration
typeset -g WIZARD_CURRENT_STEP=0
typeset -g WIZARD_TOTAL_STEPS=11

# User responses
typeset -g USER_NAME=""
typeset -g USER_EMAIL=""
typeset -g USER_LANGUAGE="en"
typeset -g USER_PROFILE="none"
typeset -g USER_EDITOR="nvim"
typeset -g USER_SHELL="zsh"
typeset -g USER_DEV_LANGUAGES=()
typeset -g USER_THEME="onedark"
typeset -g USER_PACKAGE_LEVEL="recommended"

# ============================================================================
# International Greetings
# ============================================================================

typeset -A GREETINGS
GREETINGS=(
    "en" "Welcome, friend"
    "de" "Willkommen, Freund"
    "fr" "Bienvenue, ami"
    "es" "Bienvenido, amigo"
    "it" "Benvenuto, amico"
    "pt" "Bem-vindo, amigo"
    "ja" "ようこそ、友よ"
    "zh" "欢迎，朋友"
    "ru" "Добро пожаловать, друг"
    "ar" "مرحبا يا صديقي"
    "hi" "स्वागत है, मित्र"
)

typeset -A LANGUAGE_FLAGS
LANGUAGE_FLAGS=(
    "en" "🇬🇧"
    "de" "🇩🇪"
    "fr" "🇫🇷"
    "es" "🇪🇸"
    "it" "🇮🇹"
    "pt" "🇵🇹"
    "ja" "🇯🇵"
    "zh" "🇨🇳"
    "ru" "🇷🇺"
    "ar" "🇸🇦"
    "hi" "🇮🇳"
)

# ============================================================================
# Helper Functions
# ============================================================================

function show_help() {
    cat << EOF
${UI_HEADER_COLOR}╔════════════════════════════════════════════════════════════════════════════╗
║           Dotfiles Interactive Configuration Wizard - Help                 ║
╚════════════════════════════════════════════════════════════════════════════╝${COLOR_RESET}

${UI_ACCENT_COLOR}DESCRIPTION:${COLOR_RESET}
    A warm, welcoming wizard that guides you through your first dotfiles setup.
    This interactive experience will help you configure your development
    environment with care and intelligence.

${UI_ACCENT_COLOR}USAGE:${COLOR_RESET}
    ./bin/wizard.zsh [OPTIONS]

${UI_ACCENT_COLOR}OPTIONS:${COLOR_RESET}
    --resume        Resume from previously saved state
    --reset         Start fresh (delete any saved state)
    --help, -h      Show this help message

${UI_ACCENT_COLOR}FEATURES:${COLOR_RESET}
    • Beautiful OneDark-themed interface
    • International greetings in 11 languages
    • Smart environment detection
    • Intelligent package recommendations
    • Personal configuration generation
    • Save and resume capability
    • Back/forward navigation

${UI_ACCENT_COLOR}WHAT IT DOES:${COLOR_RESET}
    The wizard will guide you through:
    1. Choosing your preferred language and greeting
    2. Setting up your identity (name, email for git)
    3. Detecting your existing development environment
    4. Selecting your preferred editor and shell
    5. Choosing your development languages and tools
    6. Recommending packages based on your choices
    7. Generating your personal configuration
    8. Reviewing and confirming your setup

${UI_ACCENT_COLOR}OUTPUT:${COLOR_RESET}
    The wizard creates:
    • ~/.config/dotfiles/personal.env - Your personal configuration
    • ~/.gitconfig.local - Git-specific settings (if needed)
    • ~/.dotfiles_wizard_state - Progress state (auto-cleaned on completion)

${UI_ACCENT_COLOR}NAVIGATION:${COLOR_RESET}
    • Press Enter to continue to next step
    • Type 'back' to return to previous step
    • Type 'quit' or 'exit' to save state and exit
    • Ctrl+C to exit without saving

${UI_SUCCESS_COLOR}Created with love for the dotfiles community 🌸${COLOR_RESET}

EOF
    exit 0
}

function save_wizard_state() {
    cat > "$WIZARD_STATE_FILE" << EOF
WIZARD_CURRENT_STEP=$WIZARD_CURRENT_STEP
USER_NAME="$USER_NAME"
USER_EMAIL="$USER_EMAIL"
USER_LANGUAGE="$USER_LANGUAGE"
USER_PROFILE="$USER_PROFILE"
USER_EDITOR="$USER_EDITOR"
USER_SHELL="$USER_SHELL"
USER_DEV_LANGUAGES=(${USER_DEV_LANGUAGES[@]})
USER_THEME="$USER_THEME"
USER_PACKAGE_LEVEL="$USER_PACKAGE_LEVEL"
EOF
}

function load_wizard_state() {
    if [[ -f "$WIZARD_STATE_FILE" ]]; then
        source "$WIZARD_STATE_FILE"
        return 0
    fi
    return 1
}

function clear_wizard_state() {
    [[ -f "$WIZARD_STATE_FILE" ]] && rm "$WIZARD_STATE_FILE"
}

function get_user_input() {
    local prompt="$1"
    local default="$2"
    local response

    if [[ -n "$default" ]]; then
        printf "${UI_INFO_COLOR}${prompt}${COLOR_RESET} ${UI_ACCENT_COLOR}[${default}]${COLOR_RESET}: "
    else
        printf "${UI_INFO_COLOR}${prompt}${COLOR_RESET}: "
    fi

    read -r response

    # Handle special commands
    case "$response" in
        quit|exit)
            print_info "Saving your progress..."
            save_wizard_state
            print_success "Your progress has been saved. Run with --resume to continue later."
            exit 0
            ;;
        back)
            if [[ $WIZARD_CURRENT_STEP -gt 0 ]]; then
                ((WIZARD_CURRENT_STEP -= 2))  # Will be incremented by 1 in main loop
                return 2
            else
                print_warning "Already at the first step!"
                return 1
            fi
            ;;
    esac

    # Return default if empty
    if [[ -z "$response" && -n "$default" ]]; then
        echo "$default"
    else
        echo "$response"
    fi
}

function draw_wizard_progress() {
    local current=$1
    local total=$2
    local percentage=$((current * 100 / total))
    local bar_width=50
    local filled=$((bar_width * current / total))
    local empty=$((bar_width - filled))

    printf "\n${UI_ACCENT_COLOR}Progress: ${COLOR_RESET}["
    printf "${UI_SUCCESS_COLOR}%${filled}s${COLOR_RESET}" | tr ' ' '█'
    printf "${UI_INFO_COLOR}%${empty}s${COLOR_RESET}" | tr ' ' '░'
    printf "] ${UI_ACCENT_COLOR}%d%%${COLOR_RESET} (Step %d/%d)\n\n" $percentage $current $total
}

# ============================================================================
# Wizard Steps
# ============================================================================

function step_welcome() {
    clear

    # Beautiful welcome screen
    cat << EOF
${UI_HEADER_COLOR}
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║                   Welcome to Your Dotfiles Journey! 🌟                     ║
║                                                                            ║
║            A warm, personalized configuration experience                   ║
║                     crafted with care and love                             ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
${COLOR_RESET}

${UI_SUCCESS_COLOR}Hello, friend! 🌸${COLOR_RESET}

I'm here to help you create a development environment that feels like home.
Together, we'll configure your dotfiles to match your preferences, workflow,
and the languages you love to work with.

${UI_INFO_COLOR}This wizard will guide you through:${COLOR_RESET}
  • Choosing your preferred language and greeting
  • Setting up your identity (for git and more)
  • Detecting your existing tools and configurations
  • Selecting your favorite editor and shell
  • Choosing development languages and tools
  • Recommending packages tailored to you
  • Generating your personal configuration

${UI_ACCENT_COLOR}Navigation tips:${COLOR_RESET}
  • Press ${COLOR_BOLD}Enter${COLOR_RESET} to continue
  • Type ${COLOR_BOLD}'back'${COLOR_RESET} to return to the previous step
  • Type ${COLOR_BOLD}'quit'${COLOR_RESET} or ${COLOR_BOLD}'exit'${COLOR_RESET} to save and exit (resume later with --resume)

${UI_WARNING_COLOR}Take your time. There's no rush. Every choice matters, and you can always
change things later by editing your personal.env file.${COLOR_RESET}

EOF

    draw_wizard_progress 1 $WIZARD_TOTAL_STEPS

    printf "${UI_INFO_COLOR}Ready to begin?${COLOR_RESET} "
    read -r
}

function step_language_selection() {
    clear

    draw_section_header "Language & Greeting Selection" "Choose how you'd like to be greeted"

    cat << EOF

${UI_INFO_COLOR}I can greet you in many languages! Choose your preferred language:${COLOR_RESET}

EOF

    # Display language options
    local i=1
    local -a lang_codes
    for lang_code in "${(@k)GREETINGS}"; do
        lang_codes+=("$lang_code")
    done

    # Sort for consistent display
    lang_codes=(${(o)lang_codes})

    for lang_code in "${lang_codes[@]}"; do
        local flag="${LANGUAGE_FLAGS[$lang_code]}"
        local greeting="${GREETINGS[$lang_code]}"
        printf "  ${UI_ACCENT_COLOR}%2d.${COLOR_RESET} %s  ${UI_SUCCESS_COLOR}%s${COLOR_RESET} - %s\n" $i "$flag" "$lang_code" "$greeting"
        ((i++))
    done

    echo
    local response=$(get_user_input "Select your language (code or number)" "en")
    [[ $? -eq 2 ]] && return  # User typed 'back'

    # Handle numeric input
    if [[ "$response" =~ ^[0-9]+$ ]]; then
        USER_LANGUAGE="${lang_codes[$response]}"
    else
        USER_LANGUAGE="$response"
    fi

    # Validate
    if [[ -z "${GREETINGS[$USER_LANGUAGE]}" ]]; then
        print_warning "Unknown language, defaulting to English"
        USER_LANGUAGE="en"
    fi

    local flag="${LANGUAGE_FLAGS[$USER_LANGUAGE]}"
    local greeting="${GREETINGS[$USER_LANGUAGE]}"
    echo
    print_success "$flag $greeting! 🌸"
    sleep 1
}

function step_profile_selection() {
    clear

    draw_section_header "Configuration Profile" "Choose a preset or customize manually"

    cat << EOF

${UI_INFO_COLOR}Would you like to start with a preset configuration profile?${COLOR_RESET}

${UI_SUCCESS_COLOR}Profiles provide pre-configured settings for different use cases:${COLOR_RESET}

  ${UI_ACCENT_COLOR}1.${COLOR_RESET} 🎯  ${UI_SUCCESS_COLOR}Minimal${COLOR_RESET} - Lightweight with essentials only
  ${UI_ACCENT_COLOR}2.${COLOR_RESET} ⭐  ${UI_SUCCESS_COLOR}Standard${COLOR_RESET} - Recommended default (balanced)
  ${UI_ACCENT_COLOR}3.${COLOR_RESET} 🚀  ${UI_SUCCESS_COLOR}Full${COLOR_RESET} - Complete setup with all features
  ${UI_ACCENT_COLOR}4.${COLOR_RESET} 💼  ${UI_SUCCESS_COLOR}Work${COLOR_RESET} - Professional development environment
  ${UI_ACCENT_COLOR}5.${COLOR_RESET} 🎨  ${UI_SUCCESS_COLOR}Personal${COLOR_RESET} - For personal projects and experimentation
  ${UI_ACCENT_COLOR}6.${COLOR_RESET} ✋  ${UI_SUCCESS_COLOR}None${COLOR_RESET} - I'll configure everything manually

${UI_WARNING_COLOR}Note: You can still adjust any settings even after choosing a profile!${COLOR_RESET}

EOF

    local response=$(get_user_input "Select profile (1-6 or name)" "2")
    [[ $? -eq 2 ]] && return

    case "$response" in
        1|minimal)
            USER_PROFILE="minimal"
            USER_EDITOR="nvim"
            USER_SHELL="zsh"
            USER_THEME="onedark"
            USER_PACKAGE_LEVEL="required"
            USER_DEV_LANGUAGES=(python lua)
            ;;
        2|standard)
            USER_PROFILE="standard"
            USER_EDITOR="nvim"
            USER_SHELL="zsh"
            USER_THEME="onedark"
            USER_PACKAGE_LEVEL="recommended"
            USER_DEV_LANGUAGES=(python javascript lua rust go)
            ;;
        3|full)
            USER_PROFILE="full"
            USER_EDITOR="nvim"
            USER_SHELL="zsh"
            USER_THEME="onedark"
            USER_PACKAGE_LEVEL="optional"
            USER_DEV_LANGUAGES=(python javascript typescript lua rust go java ruby haskell c cpp)
            ;;
        4|work)
            USER_PROFILE="work"
            USER_EDITOR="nvim"
            USER_SHELL="zsh"
            USER_THEME="onedark"
            USER_PACKAGE_LEVEL="recommended"
            USER_DEV_LANGUAGES=(java javascript typescript python go lua)
            ;;
        5|personal)
            USER_PROFILE="personal"
            USER_EDITOR="nvim"
            USER_SHELL="zsh"
            USER_THEME="onedark"
            USER_PACKAGE_LEVEL="recommended"
            USER_DEV_LANGUAGES=(rust python javascript typescript lua go haskell)
            ;;
        6|none|custom)
            USER_PROFILE="none"
            ;;
        *)
            USER_PROFILE="$response"
            if [[ ! -f "$DF_DIR/profiles/${USER_PROFILE}.yaml" ]]; then
                print_warning "Profile '$USER_PROFILE' not found. Using manual configuration."
                USER_PROFILE="none"
            fi
            ;;
    esac

    if [[ "$USER_PROFILE" != "none" ]]; then
        echo
        print_success "Profile '$USER_PROFILE' selected! Settings will be pre-filled (you can still change them)."
    else
        echo
        print_info "No profile selected. You'll configure everything manually."
    fi
    sleep 1
}

function step_user_identity() {
    clear

    draw_section_header "User Identity" "Let's set up your identity for git and more"

    cat << EOF

${UI_INFO_COLOR}Your identity will be used for git commits and other configurations.${COLOR_RESET}

EOF

    # Get current git config if exists
    local current_name=$(git config --global user.name 2>/dev/null || echo "")
    local current_email=$(git config --global user.email 2>/dev/null || echo "")

    USER_NAME=$(get_user_input "Your name" "${current_name:-Your Name}")
    [[ $? -eq 2 ]] && return

    USER_EMAIL=$(get_user_input "Your email" "${current_email:-you@example.com}")
    [[ $? -eq 2 ]] && return

    echo
    print_success "Great! I'll remember you as $USER_NAME <$USER_EMAIL>"
    sleep 1
}

function step_environment_detection() {
    clear

    draw_section_header "Environment Detection" "Let me see what you already have..."

    echo
    print_info "Detecting your current environment..."
    echo

    # Detect OS
    local os_name=$(get_os)
    print_success "Operating System: $os_name"

    # Detect existing editors
    local editors_found=()
    command_exists nvim && editors_found+=("nvim")
    command_exists vim && editors_found+=("vim")
    command_exists emacs && editors_found+=("emacs")
    command_exists code && editors_found+=("vscode")

    if [[ ${#editors_found[@]} -gt 0 ]]; then
        print_success "Editors found: ${editors_found[*]}"
    else
        print_info "No editors detected yet"
    fi

    # Detect shells
    local shells_found=()
    command_exists zsh && shells_found+=("zsh")
    command_exists bash && shells_found+=("bash")
    command_exists fish && shells_found+=("fish")

    print_success "Shells available: ${shells_found[*]}"

    # Detect languages
    local langs_found=()
    command_exists python3 && langs_found+=("python")
    command_exists node && langs_found+=("node")
    command_exists cargo && langs_found+=("rust")
    command_exists go && langs_found+=("go")
    command_exists java && langs_found+=("java")
    command_exists ruby && langs_found+=("ruby")

    if [[ ${#langs_found[@]} -gt 0 ]]; then
        print_success "Languages detected: ${langs_found[*]}"
    else
        print_info "No language runtimes detected yet"
    fi

    echo
    print_info "Press Enter to continue..."
    read -r
}

function step_editor_selection() {
    clear

    draw_section_header "Editor Preference" "What's your weapon of choice?"

    cat << EOF

${UI_INFO_COLOR}Choose your primary text editor:${COLOR_RESET}

  ${UI_ACCENT_COLOR}1.${COLOR_RESET} ${UI_SUCCESS_COLOR}Neovim${COLOR_RESET} (nvim) - Modern, powerful, extensible
  ${UI_ACCENT_COLOR}2.${COLOR_RESET} ${UI_SUCCESS_COLOR}Vim${COLOR_RESET} - Classic, ubiquitous, reliable
  ${UI_ACCENT_COLOR}3.${COLOR_RESET} ${UI_SUCCESS_COLOR}Emacs${COLOR_RESET} - Powerful, customizable, extensible
  ${UI_ACCENT_COLOR}4.${COLOR_RESET} ${UI_SUCCESS_COLOR}VS Code${COLOR_RESET} - Modern, feature-rich, popular
  ${UI_ACCENT_COLOR}5.${COLOR_RESET} ${UI_SUCCESS_COLOR}Other${COLOR_RESET} - Specify your own

EOF

    local response=$(get_user_input "Select your editor (1-5 or name)" "1")
    [[ $? -eq 2 ]] && return

    case "$response" in
        1|nvim|neovim) USER_EDITOR="nvim" ;;
        2|vim) USER_EDITOR="vim" ;;
        3|emacs) USER_EDITOR="emacs" ;;
        4|code|vscode) USER_EDITOR="code" ;;
        5|other)
            USER_EDITOR=$(get_user_input "Enter your editor command" "nvim")
            [[ $? -eq 2 ]] && return
            ;;
        *) USER_EDITOR="$response" ;;
    esac

    echo
    print_success "Excellent choice! Your editor: $USER_EDITOR"
    sleep 1
}

function step_shell_selection() {
    clear

    draw_section_header "Shell Preference" "Your command-line home"

    cat << EOF

${UI_INFO_COLOR}Choose your preferred shell:${COLOR_RESET}

  ${UI_ACCENT_COLOR}1.${COLOR_RESET} ${UI_SUCCESS_COLOR}Zsh${COLOR_RESET} - Powerful, customizable, feature-rich (default)
  ${UI_ACCENT_COLOR}2.${COLOR_RESET} ${UI_SUCCESS_COLOR}Bash${COLOR_RESET} - Universal, compatible, reliable
  ${UI_ACCENT_COLOR}3.${COLOR_RESET} ${UI_SUCCESS_COLOR}Fish${COLOR_RESET} - Friendly, modern, auto-suggestions
  ${UI_ACCENT_COLOR}4.${COLOR_RESET} ${UI_SUCCESS_COLOR}Other${COLOR_RESET} - Specify your own

EOF

    local response=$(get_user_input "Select your shell (1-4 or name)" "1")
    [[ $? -eq 2 ]] && return

    case "$response" in
        1|zsh) USER_SHELL="zsh" ;;
        2|bash) USER_SHELL="bash" ;;
        3|fish) USER_SHELL="fish" ;;
        4|other)
            USER_SHELL=$(get_user_input "Enter your shell name" "zsh")
            [[ $? -eq 2 ]] && return
            ;;
        *) USER_SHELL="$response" ;;
    esac

    echo
    print_success "Perfect! Your shell: $USER_SHELL"
    sleep 1
}

function step_development_languages() {
    clear

    draw_section_header "Development Languages" "What do you love to code in?"

    cat << EOF

${UI_INFO_COLOR}Select the languages and tools you work with (comma-separated):${COLOR_RESET}

  ${UI_ACCENT_COLOR}Available:${COLOR_RESET}
    python, javascript, typescript, rust, go, java, ruby, c, cpp,
    haskell, lua, php, swift, kotlin, scala, r, elixir

  ${UI_ACCENT_COLOR}Example:${COLOR_RESET} python,javascript,rust

EOF

    local response=$(get_user_input "Your languages" "python,javascript")
    [[ $? -eq 2 ]] && return

    # Split by comma and clean up
    USER_DEV_LANGUAGES=(${(s:,:)response})
    USER_DEV_LANGUAGES=(${USER_DEV_LANGUAGES[@]// /})  # Remove spaces

    echo
    print_success "Great selection! Languages: ${USER_DEV_LANGUAGES[*]}"
    sleep 1
}

function step_package_level() {
    clear

    draw_section_header "Package Installation Level" "How much do you want installed?"

    cat << EOF

${UI_INFO_COLOR}Choose your package installation level:${COLOR_RESET}

  ${UI_ACCENT_COLOR}1.${COLOR_RESET} ${UI_SUCCESS_COLOR}Minimal${COLOR_RESET} - Only essential packages
  ${UI_ACCENT_COLOR}2.${COLOR_RESET} ${UI_SUCCESS_COLOR}Recommended${COLOR_RESET} - Essential + commonly used tools (default)
  ${UI_ACCENT_COLOR}3.${COLOR_RESET} ${UI_SUCCESS_COLOR}Full${COLOR_RESET} - Everything including optional tools

${UI_INFO_COLOR}You can always install more packages later!${COLOR_RESET}

EOF

    local response=$(get_user_input "Select level (1-3)" "2")
    [[ $? -eq 2 ]] && return

    case "$response" in
        1|minimal) USER_PACKAGE_LEVEL="required" ;;
        2|recommended) USER_PACKAGE_LEVEL="recommended" ;;
        3|full) USER_PACKAGE_LEVEL="optional" ;;
        *) USER_PACKAGE_LEVEL="recommended" ;;
    esac

    echo
    print_success "Package level set to: $USER_PACKAGE_LEVEL"
    sleep 1
}

function step_theme_selection() {
    clear

    draw_section_header "Color Theme" "Make it yours"

    cat << EOF

${UI_INFO_COLOR}Choose your color theme preference:${COLOR_RESET}

  ${UI_ACCENT_COLOR}1.${COLOR_RESET} ${UI_SUCCESS_COLOR}OneDark${COLOR_RESET} - Beautiful dark theme (default)
  ${UI_ACCENT_COLOR}2.${COLOR_RESET} ${UI_SUCCESS_COLOR}Gruvbox${COLOR_RESET} - Warm, retro-inspired
  ${UI_ACCENT_COLOR}3.${COLOR_RESET} ${UI_SUCCESS_COLOR}Nord${COLOR_RESET} - Arctic, elegant, minimal
  ${UI_ACCENT_COLOR}4.${COLOR_RESET} ${UI_SUCCESS_COLOR}Solarized${COLOR_RESET} - Classic, balanced
  ${UI_ACCENT_COLOR}5.${COLOR_RESET} ${UI_SUCCESS_COLOR}Other${COLOR_RESET} - Specify your own

EOF

    local response=$(get_user_input "Select theme (1-5)" "1")
    [[ $? -eq 2 ]] && return

    case "$response" in
        1|onedark) USER_THEME="onedark" ;;
        2|gruvbox) USER_THEME="gruvbox" ;;
        3|nord) USER_THEME="nord" ;;
        4|solarized) USER_THEME="solarized" ;;
        5|other)
            USER_THEME=$(get_user_input "Enter theme name" "onedark")
            [[ $? -eq 2 ]] && return
            ;;
        *) USER_THEME="$response" ;;
    esac

    echo
    print_success "Theme selected: $USER_THEME"
    sleep 1
}

function generate_custom_manifest() {
    local manifest_path="$HOME/.config/dotfiles/my-packages.yaml"

    # Map languages to packages
    typeset -A lang_packages
    lang_packages=(
        "python" "python@3.12,ipython,pipx"
        "javascript" "node,npm"
        "typescript" "node,npm,typescript"
        "rust" "rust,rust-analyzer"
        "go" "go,gopls"
        "java" "openjdk,maven,gradle"
        "ruby" "ruby,rubocop"
        "c" "gcc,clang,ccls"
        "cpp" "gcc,clang,ccls"
        "haskell" "ghc,stack,haskell-language-server"
        "lua" "lua,luarocks"
        "php" "php,composer"
        "swift" "swift"
        "kotlin" "kotlin"
        "scala" "scala,sbt"
        "r" "r"
        "elixir" "elixir"
    )

    # Start building manifest
    cat > "$manifest_path" << EOF
# Custom Package Manifest
# Generated by Interactive Configuration Wizard on $(date)
# Profile: $USER_PROFILE
# Package Level: $USER_PACKAGE_LEVEL

version: "1.0"

metadata:
  name: "Custom Configuration - $USER_NAME"
  description: "Personalized package selection from wizard"
  profile: custom
  last_updated: "$(date +%Y-%m-%d)"
  compatible_systems:
    - macos
    - ubuntu
    - debian

settings:
  skip_installed: true
  auto_confirm: false

packages:
  # Core essentials (always included)
  - id: git
    name: "Git"
    description: "Distributed version control system"
    category: vcs
    priority: required
    install:
      brew: git
      apt: git
      choco: git

  - id: curl
    name: "curl"
    description: "Command-line tool for transferring data with URLs"
    category: network
    priority: required
    install:
      brew: curl
      apt: curl
      choco: curl

  - id: zsh
    name: "Zsh"
    description: "Powerful shell with advanced features"
    category: shell
    priority: $([ "$USER_SHELL" = "zsh" ] && echo "required" || echo "optional")
    install:
      brew: zsh
      apt: zsh
      choco: zsh
EOF

    # Add editor
    if [[ "$USER_EDITOR" == "nvim" ]]; then
        cat >> "$manifest_path" << EOF

  - id: neovim
    name: "Neovim"
    description: "Modern Vim-based editor"
    category: editor
    priority: required
    install:
      brew: neovim
      apt: neovim
      choco: neovim
EOF
    elif [[ "$USER_EDITOR" == "vim" ]]; then
        cat >> "$manifest_path" << EOF

  - id: vim
    name: "Vim"
    description: "Classic text editor"
    category: editor
    priority: required
    install:
      brew: vim
      apt: vim
      choco: vim
EOF
    elif [[ "$USER_EDITOR" == "emacs" ]]; then
        cat >> "$manifest_path" << EOF

  - id: emacs
    name: "Emacs"
    description: "Extensible text editor"
    category: editor
    priority: required
    install:
      brew: emacs
      apt: emacs
      choco: emacs
EOF
    fi

    # Add modern CLI tools if recommended or full
    if [[ "$USER_PACKAGE_LEVEL" =~ ^(recommended|optional)$ ]]; then
        cat >> "$manifest_path" << EOF

  # Modern CLI replacements
  - id: ripgrep
    name: "ripgrep"
    description: "Fast grep alternative written in Rust"
    category: search
    priority: recommended
    install:
      brew: ripgrep
      apt: ripgrep
      choco: ripgrep

  - id: fd
    name: "fd"
    description: "Fast find alternative written in Rust"
    category: search
    priority: recommended
    install:
      brew: fd
      apt: fd-find
      choco: fd

  - id: bat
    name: "bat"
    description: "Cat clone with syntax highlighting"
    category: viewer
    priority: recommended
    install:
      brew: bat
      apt: bat
      choco: bat

  - id: exa
    name: "exa"
    description: "Modern ls replacement"
    category: fileutils
    priority: recommended
    install:
      brew: exa
      apt: exa
      choco: exa

  - id: fzf
    name: "fzf"
    description: "Fuzzy finder for command-line"
    category: search
    priority: recommended
    install:
      brew: fzf
      apt: fzf
      choco: fzf

  - id: starship
    name: "Starship"
    description: "Cross-shell prompt"
    category: shell
    priority: recommended
    install:
      brew: starship
      apt: starship
      choco: starship

  - id: zoxide
    name: "zoxide"
    description: "Smarter cd command"
    category: navigation
    priority: recommended
    install:
      brew: zoxide
      apt: zoxide
      choco: zoxide
EOF
    fi

    # Add language-specific packages
    for lang in "${USER_DEV_LANGUAGES[@]}"; do
        local packages="${lang_packages[$lang]}"
        if [[ -n "$packages" ]]; then
            IFS=',' read -rA pkg_array <<< "$packages"
            for pkg in "${pkg_array[@]}"; do
                # Determine priority based on package level
                local priority="recommended"
                [[ "$USER_PACKAGE_LEVEL" == "required" ]] && priority="optional"

                cat >> "$manifest_path" << EOF

  - id: ${lang}_${pkg}
    name: "$pkg"
    description: "Package for $lang development"
    category: language_runtime
    priority: $priority
    install:
      brew: $pkg
      apt: $pkg
      choco: $pkg
EOF
            done
        fi
    done

    # Add optional tools if full install
    if [[ "$USER_PACKAGE_LEVEL" == "optional" ]]; then
        cat >> "$manifest_path" << EOF

  # Optional development tools
  - id: tmux
    name: "tmux"
    description: "Terminal multiplexer"
    category: terminal
    priority: optional
    install:
      brew: tmux
      apt: tmux
      choco: tmux

  - id: htop
    name: "htop"
    description: "Interactive process viewer"
    category: sysadmin
    priority: optional
    install:
      brew: htop
      apt: htop
      choco: htop

  - id: tree
    name: "tree"
    description: "Recursive directory listing"
    category: fileutils
    priority: optional
    install:
      brew: tree
      apt: tree
      choco: tree

  - id: jq
    name: "jq"
    description: "JSON processor"
    category: textprocessing
    priority: optional
    install:
      brew: jq
      apt: jq
      choco: jq
EOF
    fi

    echo "$manifest_path"
}

function step_review_and_confirm() {
    clear

    draw_section_header "Configuration Review" "Let's review your choices"

    cat << EOF

${UI_SUCCESS_COLOR}Here's what we'll configure:${COLOR_RESET}

${UI_ACCENT_COLOR}Personal Information:${COLOR_RESET}
  Name:              $USER_NAME
  Email:             $USER_EMAIL
  Language:          ${LANGUAGE_FLAGS[$USER_LANGUAGE]} $USER_LANGUAGE
  Profile:           $USER_PROFILE

${UI_ACCENT_COLOR}Environment:${COLOR_RESET}
  Editor:            $USER_EDITOR
  Shell:             $USER_SHELL
  Theme:             $USER_THEME

${UI_ACCENT_COLOR}Development:${COLOR_RESET}
  Languages:         ${USER_DEV_LANGUAGES[*]}
  Package Level:     $USER_PACKAGE_LEVEL

${UI_INFO_COLOR}This will create/update:${COLOR_RESET}
  • ~/.config/dotfiles/personal.env
  • ~/.gitconfig.local (for git identity)

EOF

    draw_wizard_progress $WIZARD_TOTAL_STEPS $WIZARD_TOTAL_STEPS

    printf "${UI_WARNING_COLOR}Does everything look correct?${COLOR_RESET} (yes/no/back) [yes]: "
    read -r response

    case "$response" in
        no|n)
            print_info "Let's start over from the beginning..."
            WIZARD_CURRENT_STEP=0
            sleep 1
            return
            ;;
        back|b)
            ((WIZARD_CURRENT_STEP -= 2))
            return
            ;;
        *)
            # Continue to completion
            ;;
    esac
}

function step_completion() {
    clear

    # Generate personal.env
    mkdir -p "$(dirname "$WIZARD_CONFIG_FILE")"

    cat > "$WIZARD_CONFIG_FILE" << EOF
# Personal Dotfiles Configuration
# Generated by Interactive Configuration Wizard on $(date)
#
# This file contains your personal preferences and will be sourced by
# various dotfiles scripts. Feel free to edit it directly at any time.

# User Identity
export DOTFILES_USER_NAME="$USER_NAME"
export DOTFILES_USER_EMAIL="$USER_EMAIL"
export DOTFILES_USER_LANGUAGE="$USER_LANGUAGE"
export DOTFILES_PROFILE="$USER_PROFILE"

# Environment Preferences
export DOTFILES_EDITOR="$USER_EDITOR"
export DOTFILES_SHELL="$USER_SHELL"
export DOTFILES_THEME="$USER_THEME"

# Development Configuration
export DOTFILES_DEV_LANGUAGES=(${USER_DEV_LANGUAGES[*]})
export DOTFILES_PACKAGE_LEVEL="$USER_PACKAGE_LEVEL"

# Auto-generated settings
export DOTFILES_WIZARD_COMPLETED="$(date +%Y-%m-%d)"
export DOTFILES_WIZARD_VERSION="1.0"
EOF

    # Create .gitconfig.local
    cat > "$HOME/.gitconfig.local" << EOF
# Local Git Configuration
# Generated by dotfiles wizard

[user]
    name = $USER_NAME
    email = $USER_EMAIL
EOF

    # Offer to generate custom package manifest
    echo
    echo "${UI_INFO_COLOR}📦 Package Manifest Generation${COLOR_RESET}"
    echo
    printf "${UI_ACCENT_COLOR}Would you like to generate a custom package manifest based on your choices?${COLOR_RESET} (yes/no) [yes]: "
    read -r response

    local manifest_created=false
    local manifest_path=""

    if [[ ! "$response" =~ ^[Nn] ]]; then
        print_info "Generating custom package manifest..."
        manifest_path=$(generate_custom_manifest)

        if [[ -f "$manifest_path" ]]; then
            local pkg_count=$(grep -c '^\s*-\s*id:' "$manifest_path" 2>/dev/null || echo "0")
            print_success "Created custom manifest: $manifest_path"
            print_info "Packages defined: $pkg_count"
            manifest_created=true
        else
            print_warning "Failed to create manifest"
        fi
        echo
    fi

    # Show completion
    draw_section_header "Completion! 🎉" "Your dotfiles are now configured"

    cat << EOF

${UI_SUCCESS_COLOR}✨ Congratulations! Your configuration is complete! ✨${COLOR_RESET}

${UI_INFO_COLOR}What was created:${COLOR_RESET}
  ✓ $WIZARD_CONFIG_FILE
  ✓ ~/.gitconfig.local
EOF

    if [[ "$manifest_created" == "true" ]]; then
        echo "  ✓ $manifest_path (custom package manifest)"
    fi

    cat << EOF

${UI_ACCENT_COLOR}Next Steps:${COLOR_RESET}

  1. ${COLOR_BOLD}Link your dotfiles:${COLOR_RESET}
     cd ~/.config/dotfiles && ./bin/link_dotfiles.zsh

EOF

    if [[ "$manifest_created" == "true" ]]; then
        cat << EOF
  2. ${COLOR_BOLD}Install packages from your custom manifest:${COLOR_RESET}
     install_from_manifest -i $manifest_path

  3. ${COLOR_BOLD}Or use the interactive menu:${COLOR_RESET}
     ./bin/menu_tui.zsh

EOF
        if [[ "$USER_PROFILE" != "none" ]]; then
            cat << EOF
  4. ${COLOR_BOLD}Or apply your profile:${COLOR_RESET}
     cd ~/.config/dotfiles && ./bin/profile_manager.zsh apply $USER_PROFILE

  5. ${COLOR_BOLD}Customize further:${COLOR_RESET}
     Edit ~/.config/dotfiles/personal.env or $manifest_path anytime

EOF
        else
            cat << EOF
  4. ${COLOR_BOLD}Customize further:${COLOR_RESET}
     Edit ~/.config/dotfiles/personal.env or $manifest_path anytime

EOF
        fi
    else
        cat << EOF
  2. ${COLOR_BOLD}Install packages:${COLOR_RESET}
     Run the interactive menu to choose which packages to install:
     ./bin/menu_tui.zsh

EOF
        if [[ "$USER_PROFILE" != "none" ]]; then
            cat << EOF
  3. ${COLOR_BOLD}Apply your profile (optional):${COLOR_RESET}
     If you selected a profile, you can apply it now:
     cd ~/.config/dotfiles && ./bin/profile_manager.zsh apply $USER_PROFILE

  4. ${COLOR_BOLD}Customize further:${COLOR_RESET}
     Edit ~/.config/dotfiles/personal.env anytime to adjust settings

EOF
        else
            cat << EOF
  3. ${COLOR_BOLD}Customize further:${COLOR_RESET}
     Edit ~/.config/dotfiles/personal.env anytime to adjust settings

EOF
        fi
    fi

    cat << EOF
${UI_SUCCESS_COLOR}${GREETINGS[$USER_LANGUAGE]}, and happy coding! ${LANGUAGE_FLAGS[$USER_LANGUAGE]} 🌸${COLOR_RESET}

${UI_INFO_COLOR}May your development environment bring you joy and productivity!${COLOR_RESET}

EOF

    # Clean up state file
    clear_wizard_state

    printf "${UI_ACCENT_COLOR}Press Enter to exit...${COLOR_RESET} "
    read -r
}

# ============================================================================
# Main Wizard Flow
# ============================================================================

function main() {
    # Parse arguments using shared library
    parse_simple_flags "$@"
    is_help_requested && show_help

    # Validate no unknown arguments remain
    validate_no_unknown_args "$@" || show_help

    # Handle reset
    if [[ "$ARG_RESET" == "true" ]]; then
        clear_wizard_state
        print_success "Wizard state cleared. Starting fresh!"
        sleep 1
    fi

    # Try to resume if requested
    if [[ "$ARG_RESUME" == "true" ]]; then
        if load_wizard_state; then
            print_success "Resuming from step $WIZARD_CURRENT_STEP..."
            sleep 1
        else
            print_warning "No saved state found. Starting from beginning."
            sleep 1
        fi
    fi

    # Hide cursor for cleaner output
    hide_cursor

    # Main wizard loop
    local steps=(
        step_welcome
        step_language_selection
        step_profile_selection
        step_user_identity
        step_environment_detection
        step_editor_selection
        step_shell_selection
        step_development_languages
        step_package_level
        step_theme_selection
        step_review_and_confirm
        step_completion
    )

    while [[ $WIZARD_CURRENT_STEP -lt ${#steps[@]} ]]; do
        ${steps[$WIZARD_CURRENT_STEP]}
        ((WIZARD_CURRENT_STEP++))
    done

    # Show cursor again
    show_cursor
}

# Run the wizard
main "$@"
