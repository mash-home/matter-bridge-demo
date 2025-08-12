# Matter Bridge Demo - Installation Guide

## 🚀 Quick Installation

### Option 1: Automatic Installation (Recommended)
```bash
# Make the script executable (first time only)
chmod +x install-dependencies.sh

# Run the installation script
./install-dependencies.sh

# Or use make command
make install-deps
```

### Option 2: Manual Installation
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required packages
brew install make jq

# Note: Matter SDK tools are included in the project binaries
```

## 📋 System Requirements

### Minimum Requirements:
- **Operating System**: macOS 13+ (Ventura or later)
- **Processor**: Apple Silicon (M1/M2/M3) or Intel (x86_64)
- **Memory**: 2GB RAM minimum (4GB recommended)
- **Disk Space**: 1GB available space
- **Network**: Internet connection for installation

### Recommended:
- **macOS**: 14+ (Sonoma or later)
- **Memory**: 8GB RAM or more
- **Disk Space**: 5GB available space

## 🔧 What Gets Installed

### System Tools:
- ✅ **Homebrew** - Package manager for macOS
- ✅ **Make** - Build automation tool
- ✅ **jq** - JSON processor for scripts

### Matter SDK:
- ✅ **chip-bridge-app** - Matter bridge application
- ✅ **chip-tool** - Matter commissioning tool
- ⚠️ **Matter SDK** - May require manual installation

## 📁 Project Structure

```
matter-bridge-demo/
├── install-dependencies.sh    # Dependency installer script
├── start-bridge.sh           # Bridge management script
├── bridge-config.json        # Bridge configuration
├── Makefile                  # Build and management commands
├── README.md                 # Main documentation
├── INSTALL.md                # This installation guide
└── chip/                     # Matter bridge binaries
    └── macos-arm64-bridge-app/
        └── standalone/
            ├── chip-bridge-app
            └── chip-tool
```

## 🚨 Troubleshooting

### Common Issues:

#### 1. **Permission Denied**
```bash
# Fix script permissions
chmod +x install-dependencies.sh
chmod +x start-bridge.sh
```

#### 2. **Homebrew Not Found**
```bash
# Install Homebrew manually
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add to PATH (if needed)
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### 3. **Matter SDK Not Available**
```bash
# The project includes pre-built binaries
# If you need to build from source, see:
# https://github.com/project-chip/connectedhomeip
```

#### 4. **Port Already in Use**
```bash
# Check what's using port 5540
lsof -i :5540

# Kill the process if needed
kill -9 <PID>
```

## ✅ Verification

After installation, verify everything works:

```bash
# Check bridge status
make status

# Check dependencies
./install-dependencies.sh

# Test bridge startup
make start
# Press Ctrl+C to stop
```

## 🔄 Updating

To update dependencies:

```bash
# Update Homebrew packages
brew update && brew upgrade

# Re-run dependency check
make install-deps
```

## 📞 Support

If you encounter issues:

1. **Check the logs**: `make logs`
2. **Reset bridge state**: `make reset`
3. **Re-run installation**: `make install-deps`
4. **Check system requirements**: `./install-dependencies.sh`

## 📚 Next Steps

After successful installation:

1. **Configure the bridge**: Edit `bridge-config.json`
2. **Start the bridge**: `make start`
3. **Pair devices**: Follow the QR code instructions
4. **Manage the bridge**: Use `make help` for available commands

---

**Happy bridging! 🎉**
