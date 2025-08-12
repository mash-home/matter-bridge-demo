#!/bin/bash

# Matter Bridge Demo - Dependencies Installer
# This script checks and installs all required dependencies

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Matter Bridge Dependencies${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_section() {
    echo -e "${CYAN}📦 $1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check macOS version
check_macos_version() {
    print_section "Checking macOS version..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only!"
        exit 1
    fi
    
    MACOS_VERSION=$(sw_vers -productVersion)
    print_status "macOS version: $MACOS_VERSION"
    
    # Check if version is supported (macOS 13+)
    MAJOR_VERSION=$(echo $MACOS_VERSION | cut -d. -f1)
    if [ "$MAJOR_VERSION" -lt 13 ]; then
        print_warning "macOS 13+ is recommended for optimal performance"
    fi
    
    # Check processor architecture
    ARCH=$(uname -m)
    print_status "Processor architecture: $ARCH"
    
    if [ "$ARCH" = "arm64" ]; then
        print_status "✅ Apple Silicon (M1/M2/M3) detected"
    elif [ "$ARCH" = "x86_64" ]; then
        print_status "✅ Intel processor detected"
    else
        print_warning "Unknown processor architecture"
    fi
}

# Function to check and install Homebrew
check_homebrew() {
    print_section "Checking Homebrew installation..."
    
    if command_exists brew; then
        print_status "✅ Homebrew is already installed"
        BREW_VERSION=$(brew --version | head -n1)
        print_status "Version: $BREW_VERSION"
        
        # Update Homebrew
        print_status "Updating Homebrew..."
        brew update >/dev/null 2>&1
        print_status "✅ Homebrew updated"
    else
        print_warning "Homebrew not found. Installing..."
        
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if command_exists brew; then
            print_status "✅ Homebrew installed successfully"
        else
            print_error "Failed to install Homebrew"
            exit 1
        fi
    fi
}

# Function to check and install Make
check_make() {
    print_section "Checking Make installation..."
    
    if command_exists make; then
        print_status "✅ Make is already installed"
        MAKE_VERSION=$(make --version | head -n1)
        print_status "Version: $MAKE_VERSION"
    else
        print_warning "Make not found. Installing..."
        brew install make
        
        if command_exists make; then
            print_status "✅ Make installed successfully"
        else
            print_error "Failed to install Make"
            exit 1
        fi
    fi
}

# Function to check and install jq
check_jq() {
    print_section "Checking jq installation..."
    
    if command_exists jq; then
        print_status "✅ jq is already installed"
        JQ_VERSION=$(jq --version)
        print_status "Version: $JQ_VERSION"
    else
        print_warning "jq not found. Installing..."
        brew install jq
        
        if command_exists jq; then
            print_status "✅ jq installed successfully"
        else
            print_error "Failed to install jq"
            exit 1
        fi
    fi
}

# Function to check and install Matter SDK
check_matter_sdk() {
    print_section "Checking Matter SDK installation..."
    
    if command_exists chip-tool; then
        print_status "✅ Matter SDK tools are already installed"
    else
        print_warning "Matter SDK tools not found. Installing..."
        
        # Try to install via Homebrew
        if brew list matter >/dev/null 2>&1; then
            print_status "Matter package found in Homebrew, updating..."
            brew upgrade matter
        else
            print_status "Installing Matter SDK via Homebrew..."
            brew install matter
        fi
        
        if command_exists chip-tool; then
            print_status "✅ Matter SDK tools installed successfully"
        else
            print_warning "Matter SDK not available via Homebrew. Manual installation may be required."
            print_status "Please refer to: https://github.com/project-chip/connectedhomeip"
        fi
    fi
}

# Function to check network connectivity
check_network() {
    print_section "Checking network connectivity..."
    
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        print_status "✅ Internet connectivity: OK"
    else
        print_error "❌ No internet connectivity detected"
        print_warning "Some installations may fail without internet access"
    fi
    
    # Check if ports are available
    if lsof -i :5540 >/dev/null 2>&1; then
        print_warning "⚠️  Port 5540 is already in use"
    else
        print_status "✅ Port 5540 is available"
    fi
}

# Function to check project files
check_project_files() {
    print_section "Checking project files..."
    
    REQUIRED_FILES=(
        "bridge-config.json"
        "start-bridge.sh"
        "Makefile"
        "README.md"
    )
    
    REQUIRED_DIRS=(
        "chip/macos-arm64-bridge-app/standalone"
    )
    
    # Check required files
    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            print_status "✅ $file found"
        else
            print_error "❌ $file missing"
        fi
    done
    
    # Check required directories
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            print_status "✅ $dir found"
            
            # Check if binaries exist
            if [ -f "$dir/chip-bridge-app" ]; then
                print_status "✅ chip-bridge-app binary found"
            else
                print_error "❌ chip-bridge-app binary missing"
            fi
            
            if [ -f "$dir/chip-tool" ]; then
                print_status "✅ chip-tool binary found"
            else
                print_error "❌ chip-tool binary missing"
            fi
        else
            print_error "❌ $dir missing"
        fi
    done
}

# Function to set file permissions
set_permissions() {
    print_section "Setting file permissions..."
    
    if [ -f "start-bridge.sh" ]; then
        chmod +x start-bridge.sh
        print_status "✅ start-bridge.sh is now executable"
    fi
    
    if [ -d "chip/macos-arm64-bridge-app/standalone" ]; then
        chmod +x chip/macos-arm64-bridge-app/standalone/chip-bridge-app
        chmod +x chip/macos-arm64-bridge-app/standalone/chip-tool
        print_status "✅ Bridge binaries are now executable"
    fi
}

# Function to run system check
run_system_check() {
    print_section "Running system compatibility check..."
    
    # Check available disk space
    DISK_SPACE=$(df . | awk 'NR==2 {print $4}')
    DISK_SPACE_MB=$((DISK_SPACE / 1024))
    print_status "Available disk space: ${DISK_SPACE_MB}MB"
    
    if [ "$DISK_SPACE_MB" -lt 1000 ]; then
        print_warning "⚠️  Low disk space. At least 1GB recommended."
    fi
    
    # Check available memory
    MEMORY=$(vm_stat | grep "Pages free:" | awk '{print $3}' | sed 's/\.//')
    MEMORY_MB=$((MEMORY * 4096 / 1024 / 1024))
    print_status "Available memory: ${MEMORY_MB}MB"
    
    if [ "$MEMORY_MB" -lt 2048 ]; then
        print_warning "⚠️  Low memory. At least 2GB recommended."
    fi
}

# Function to show next steps
show_next_steps() {
    print_section "Installation completed! Next steps:"
    echo ""
    echo -e "${GREEN}1.${NC} Start the bridge:"
    echo -e "   ${CYAN}make start${NC}"
    echo ""
    echo -e "${GREEN}2.${NC} Check bridge status:"
    echo -e "   ${CYAN}make status${NC}"
    echo ""
    echo -e "${GREEN}3.${NC} View logs:"
    echo -e "   ${CYAN}make logs${NC}"
    echo ""
    echo -e "${GREEN}4.${NC} Stop the bridge:"
    echo -e "   ${CYAN}make stop${NC}"
    echo ""
    echo -e "${GREEN}5.${NC} Reset bridge state:"
    echo -e "   ${CYAN}make reset${NC}"
    echo ""
    echo -e "${BLUE}For more information, see README.md${NC}"
}

# Main installation function
main() {
    print_header
    
    print_status "Starting dependency installation..."
    echo ""
    
    # Run all checks
    check_macos_version
    echo ""
    
    check_homebrew
    echo ""
    
    check_make
    echo ""
    
    check_jq
    echo ""
    
    check_matter_sdk
    echo ""
    
    check_network
    echo ""
    
    check_project_files
    echo ""
    
    set_permissions
    echo ""
    
    run_system_check
    echo ""
    
    print_status "✅ All dependencies checked and installed!"
    echo ""
    
    show_next_steps
}

# Check if script is run with sudo
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root (sudo)"
    print_warning "Please run without sudo: ./install-dependencies.sh"
    exit 1
fi

# Run main function
main "$@"
