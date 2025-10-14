# ============================================================================
# Dotfiles Bootstrap Installer for Windows
# ============================================================================
#
# One-line installation for a fresh Windows machine:
#   irm https://raw.githubusercontent.com/USER/REPO/main/install.ps1 | iex
#
# This script:
# - Detects Windows environment (PowerShell, WSL availability)
# - Checks for required tools (git, pwsh)
# - Offers to install missing dependencies via Chocolatey
# - Clones the dotfiles repository
# - Runs the setup script
#
# PowerShell 5.1+ compatible
# ============================================================================

#Requires -Version 5.1

# Stop on errors
$ErrorActionPreference = "Stop"

# ============================================================================
# Configuration
# ============================================================================

$DotfilesRepo = "https://github.com/thomascrha/dotfiles.git"  # TODO: Update with actual repo URL
$DotfilesDir = "$HOME\.config\dotfiles"
$SetupScript = "$DotfilesDir\bin\setup.zsh"

# ============================================================================
# Colors (OneDark theme, PowerShell-compatible)
# ============================================================================

# ANSI color codes for PowerShell
$Script:ColorReset = "`e[0m"
$Script:ColorBold = "`e[1m"

# OneDark colors
$Script:ColorRed = "`e[38;5;204m"
$Script:ColorGreen = "`e[38;5;114m"
$Script:ColorYellow = "`e[38;5;180m"
$Script:ColorBlue = "`e[38;5;39m"
$Script:ColorPurple = "`e[38;5;170m"
$Script:ColorCyan = "`e[38;5;38m"

# ============================================================================
# UI Functions
# ============================================================================

function Write-Header {
    Write-Host ""
    Write-Host "$($ColorPurple)$($ColorBold)╔════════════════════════════════════════════════════════════════════════════╗$($ColorReset)"
    Write-Host "$($ColorPurple)$($ColorBold)║                                                                            ║$($ColorReset)"
    Write-Host "$($ColorPurple)$($ColorBold)║                         DOTFILES INSTALLATION                              ║$($ColorReset)"
    Write-Host "$($ColorPurple)$($ColorBold)║                                                                            ║$($ColorReset)"
    Write-Host "$($ColorPurple)$($ColorBold)║                    Setting up your development environment                 ║$($ColorReset)"
    Write-Host "$($ColorPurple)$($ColorBold)║                                                                            ║$($ColorReset)"
    Write-Host "$($ColorPurple)$($ColorBold)╚════════════════════════════════════════════════════════════════════════════╝$($ColorReset)"
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "$($ColorGreen)✅ $Message$($ColorReset)"
}

function Write-Info {
    param([string]$Message)
    Write-Host "$($ColorBlue)ℹ️  $Message$($ColorReset)"
}

function Write-Warning {
    param([string]$Message)
    Write-Host "$($ColorYellow)⚠️  $Message$($ColorReset)"
}

function Write-Error {
    param([string]$Message)
    Write-Host "$($ColorRed)❌ $Message$($ColorReset)"
}

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "$($ColorCyan)$($ColorBold)═══ $Message ═══$($ColorReset)"
    Write-Host ""
}

# ============================================================================
# Helper Functions
# ============================================================================

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Install-Chocolatey {
    Write-Info "Chocolatey package manager is not installed"
    Write-Host "Chocolatey is required to install dependencies on Windows"

    $response = Read-Host "Would you like to install Chocolatey? [Y/n]"
    if ([string]::IsNullOrEmpty($response)) { $response = "Y" }

    if ($response -match "^[Yy]") {
        Write-Info "Installing Chocolatey..."

        # Check if running as administrator
        if (-not (Test-Administrator)) {
            Write-Error "Administrator privileges required to install Chocolatey"
            Write-Info "Please restart PowerShell as Administrator and run this script again"
            Write-Info "Right-click PowerShell and select 'Run as Administrator'"
            exit 1
        }

        # Install Chocolatey
        try {
            Set-ExecutionPolicy Bypass -Scope Process -Force
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

            # Refresh environment
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            Write-Success "Chocolatey installed successfully"
        }
        catch {
            Write-Error "Failed to install Chocolatey: $_"
            exit 1
        }
    }
    else {
        Write-Error "Chocolatey is required to continue"
        Write-Info "Please install Chocolatey manually from https://chocolatey.org/install"
        exit 1
    }
}

function Install-Git {
    Write-Info "Git is required but not installed"

    $response = Read-Host "Would you like to install Git? [Y/n]"
    if ([string]::IsNullOrEmpty($response)) { $response = "Y" }

    if ($response -match "^[Yy]") {
        # Ensure Chocolatey is available
        if (-not (Test-CommandExists "choco")) {
            Install-Chocolatey
        }

        Write-Info "Installing Git via Chocolatey..."

        try {
            choco install git -y

            # Refresh environment
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

            Write-Success "Git installed successfully"
        }
        catch {
            Write-Error "Failed to install Git: $_"
            exit 1
        }
    }
    else {
        Write-Error "Git is required to continue"
        Write-Info "Please install Git manually and re-run this script"
        Write-Info "Download from: https://git-scm.com/download/win"
        exit 1
    }
}

# ============================================================================
# WSL Detection and Setup
# ============================================================================

function Test-WSLAvailable {
    return (Test-CommandExists "wsl")
}

function Get-PreferredShell {
    Write-Info "This dotfiles setup is optimized for Unix-like environments"
    Write-Host ""
    Write-Info "Available options:"
    Write-Host "  1. WSL (Windows Subsystem for Linux) - Recommended for best experience"
    Write-Host "  2. Native Windows (PowerShell/Git Bash)"
    Write-Host ""

    if (Test-WSLAvailable) {
        Write-Success "WSL is available on this system"
        $response = Read-Host "Would you like to setup in WSL? [Y/n]"
        if ([string]::IsNullOrEmpty($response)) { $response = "Y" }

        if ($response -match "^[Yy]") {
            return "WSL"
        }
    }
    else {
        Write-Warning "WSL is not installed on this system"
        Write-Info "You can install WSL with: wsl --install"
        Write-Info "After installing WSL, you can run the Linux version of this installer"
    }

    return "Windows"
}

# ============================================================================
# Main Installation
# ============================================================================

function Invoke-DotfilesInstallation {
    Write-Header

    # Detect environment
    Write-Step "Detecting System"

    $osVersion = [System.Environment]::OSVersion.Version
    Write-Success "Windows version: $($osVersion.Major).$($osVersion.Minor)"
    Write-Info "PowerShell version: $($PSVersionTable.PSVersion)"

    # Check for administrator (informational only)
    if (Test-Administrator) {
        Write-Info "Running as Administrator"
    }
    else {
        Write-Warning "Not running as Administrator (required for some installations)"
    }

    # Determine preferred environment
    $environment = Get-PreferredShell

    if ($environment -eq "WSL") {
        Write-Step "Setting up in WSL"

        Write-Info "Launching WSL to run the Linux installation script..."
        Write-Host ""

        # Run the bash installer in WSL
        $installCmd = "curl -fsSL https://raw.githubusercontent.com/USER/REPO/main/install.sh | sh"

        try {
            wsl bash -c $installCmd

            Write-Host ""
            Write-Step "Installation Complete"

            Write-Host "$($ColorGreen)$($ColorBold)"
            Write-Host ""
            Write-Host "🎉 Congratulations! Your dotfiles are now installed in WSL!"
            Write-Host ""
            Write-Host "$($ColorReset)"

            Write-Info "💡 Access your WSL environment:"
            Write-Host "   1. Type 'wsl' to enter your WSL shell"
            Write-Host "   2. Your dotfiles are at: ~/.config/dotfiles"
            Write-Host ""

            Write-Host "$($ColorPurple)$($ColorBold)"
            Write-Host "✨ Enjoy your beautifully configured development environment! ✨"
            Write-Host "$($ColorReset)"

            return
        }
        catch {
            Write-Error "Failed to run installer in WSL: $_"
            Write-Info "Falling back to native Windows installation..."
            $environment = "Windows"
        }
    }

    # Native Windows installation
    Write-Step "Setting up for Windows"

    # Check dependencies
    Write-Step "Checking Dependencies"

    if (-not (Test-CommandExists "git")) {
        Install-Git
    }
    else {
        $gitVersion = (git --version) -replace 'git version ', ''
        Write-Success "Git is available (version: $gitVersion)"
    }

    # Clone repository
    Write-Step "Cloning Dotfiles Repository"

    if (Test-Path $DotfilesDir) {
        Write-Warning "Dotfiles directory already exists: $DotfilesDir"

        $response = Read-Host "Would you like to update it? [Y/n]"
        if ([string]::IsNullOrEmpty($response)) { $response = "Y" }

        if ($response -match "^[Yy]") {
            Write-Info "Updating existing repository..."
            Push-Location $DotfilesDir
            git pull
            Pop-Location
            Write-Success "Repository updated"
        }
        else {
            Write-Info "Using existing repository"
        }
    }
    else {
        Write-Info "Cloning repository to $DotfilesDir..."

        try {
            # Ensure parent directory exists
            $parentDir = Split-Path $DotfilesDir -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }

            git clone --recurse-submodules $DotfilesRepo $DotfilesDir
            Write-Success "Repository cloned successfully"
        }
        catch {
            Write-Error "Failed to clone repository: $_"
            exit 1
        }
    }

    # Setup instructions
    Write-Step "Next Steps"

    Write-Info "📦 Repository cloned successfully!"
    Write-Host ""
    Write-Info "🎯 To complete the setup:"
    Write-Host ""

    if (Test-WSLAvailable) {
        Write-Host "   ${ColorGreen}Recommended:${ColorReset} Use WSL for the best experience:"
        Write-Host "   1. Type: ${ColorCyan}wsl${ColorReset}"
        Write-Host "   2. Run: ${ColorCyan}cd ~/.config/dotfiles${ColorReset}"
        Write-Host "   3. Run: ${ColorCyan}./setup${ColorReset}"
        Write-Host ""
        Write-Host "   Or install WSL if not already set up:"
        Write-Host "   - Run: ${ColorCyan}wsl --install${ColorReset}"
        Write-Host "   - Restart your computer"
        Write-Host "   - Run this installer again"
    }
    else {
        Write-Host "   For Windows with Git Bash:"
        Write-Host "   1. Open Git Bash"
        Write-Host "   2. Run: ${ColorCyan}cd ~/.config/dotfiles${ColorReset}"
        Write-Host "   3. Run: ${ColorCyan}./setup${ColorReset}"
        Write-Host ""
        Write-Host "   ${ColorYellow}Or install WSL for a better experience:${ColorReset}"
        Write-Host "   - Run: ${ColorCyan}wsl --install${ColorReset}"
        Write-Host "   - Restart and run: ${ColorCyan}wsl${ColorReset}"
    }

    Write-Host ""
    Write-Info "📍 Repository location: $DotfilesDir"
    Write-Host ""

    Write-Host "$($ColorPurple)$($ColorBold)"
    Write-Host "✨ Ready to configure your development environment! ✨"
    Write-Host "$($ColorReset)"
}

# ============================================================================
# Entry Point
# ============================================================================

try {
    Invoke-DotfilesInstallation
}
catch {
    Write-Host ""
    Write-Error "Installation failed: $_"
    Write-Host ""
    Write-Info "For help, please visit: https://github.com/USER/dotfiles/issues"
    exit 1
}

# Exit successfully
exit 0
