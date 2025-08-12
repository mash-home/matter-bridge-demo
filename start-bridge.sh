#!/bin/bash

# Matter Bridge Demo - Advanced Startup
# Advanced Matter Bridge Startup Script

BRIDGE_DIR="chip/macos-arm64-bridge-app/standalone"
CONFIG_FILE="bridge-config.json"
LOG_FILE="bridge.log"
TEMP_LOG="temp_bridge.log"

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
    echo -e "${BLUE}  Matter Bridge Demo${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to stop all existing bridge processes
stop_all_bridges() {
    print_status "Checking for existing bridge processes..."
    
    # Check if there are any running bridge processes
    RUNNING=$(ps aux | grep chip-bridge-app | grep -v grep | wc -l)
    
    if [ $RUNNING -gt 0 ]; then
        print_warning "Found $RUNNING running bridge process(es), stopping them..."
        
        # Stop by PID file if exists
        if [ -f "bridge.pid" ]; then
            BRIDGE_PID=$(cat bridge.pid)
            if ps -p $BRIDGE_PID > /dev/null; then
                print_status "Stopping bridge with PID: $BRIDGE_PID"
                kill $BRIDGE_PID 2>/dev/null
                sleep 2
            fi
            rm -f bridge.pid
        fi
        
        # Kill all remaining bridge processes
        pkill -f chip-bridge-app 2>/dev/null
        sleep 2
        
        # Force kill if still running
        RUNNING_AFTER=$(ps aux | grep chip-bridge-app | grep -v grep | wc -l)
        if [ $RUNNING_AFTER -gt 0 ]; then
            print_warning "Force killing remaining processes..."
            pkill -9 -f chip-bridge-app 2>/dev/null
            sleep 1
        fi
        
        # Verify all stopped
        RUNNING_FINAL=$(ps aux | grep chip-bridge-app | grep -v grep | wc -l)
        if [ $RUNNING_FINAL -eq 0 ]; then
            print_status "All bridge processes stopped successfully"
        else
            print_error "Failed to stop all bridge processes"
            return 1
        fi
    else
        print_status "No existing bridge processes found"
    fi
    
    # Clean up old files
    rm -f "$TEMP_LOG"
    rm -f bridge.pid 2>/dev/null
    
    return 0
}

print_qr_info() {
    echo -e "${CYAN}🔗 Google Home Pairing Codes:${NC}"
    echo ""
    
    # Extract QR code and pairing code from logs
    if [ -f "$TEMP_LOG" ]; then
        QR_CODE=$(grep "SetupQRCode:" "$TEMP_LOG" | head -1 | sed 's/.*SetupQRCode: \[\(.*\)\].*/\1/')
        PAIRING_CODE=$(grep "Manual pairing code:" "$TEMP_LOG" | head -1 | sed 's/.*Manual pairing code: \[\(.*\)\].*/\1/')
        VENDOR_ID=$(grep "Vendor Id:" "$TEMP_LOG" | head -1 | sed 's/.*Vendor Id: \([0-9]*\).*/\1/')
        PRODUCT_ID=$(grep "Product Id:" "$TEMP_LOG" | head -1 | sed 's/.*Product Id: \([0-9]*\).*/\1/')
        DISCIMINATOR=$(grep "Setup Discriminator" "$TEMP_LOG" | head -1 | sed 's/.*Setup Discriminator.*: \([0-9]*\).*/\1/')
        PIN_CODE=$(grep "Setup Pin Code" "$TEMP_LOG" | head -1 | sed 's/.*Setup Pin Code.*: \([0-9]*\).*/\1/')
        
        if [ ! -z "$QR_CODE" ]; then
            echo -e "${GREEN}📱 QR Code:${NC} $QR_CODE"
            echo ""
            echo -e "${GREEN}🔢 Manual Pairing Code:${NC} $PAIRING_CODE"
            echo ""
            echo -e "${GREEN}📋 Device Details:${NC}"
            echo -e "   Vendor ID: $VENDOR_ID (0x$(printf '%X' $VENDOR_ID))"
            echo -e "   Product ID: $PRODUCT_ID (0x$(printf '%X' $PRODUCT_ID))"
            echo -e "   Discriminator: $DISCIMINATOR (0x$(printf '%X' $DISCIMINATOR))"
            echo -e "   Pin Code: $PIN_CODE"
            echo ""
            echo -e "${GREEN}🌐 QR Code Link:${NC}"
            echo -e "   https://project-chip.github.io/connectedhomeip/qrcode.html?data=${QR_CODE//:/%3A}"
            echo ""
            echo -e "${CYAN}💡 Pairing Instructions:${NC}"
            echo -e "   1. Open Google Home App"
            echo -e "   2. Click '+' (Add Device)"
            echo -e "   3. Select 'Set up device'"
            echo -e "   4. Select 'Matter' or 'Smart Device'"
            echo -e "   5. Scan QR Code or enter manual code"
            echo ""
        else
            echo -e "${YELLOW}⚠️  No pairing codes found in logs${NC}"
        fi
    fi
}

# Check if bridge application exists
check_bridge_app() {
    if [ ! -f "$BRIDGE_DIR/chip-bridge-app" ]; then
        print_error "Bridge application not found at $BRIDGE_DIR/chip-bridge-app"
        exit 1
    fi
    
    if [ ! -x "$BRIDGE_DIR/chip-bridge-app" ]; then
        print_warning "Making bridge application executable..."
        chmod +x "$BRIDGE_DIR/chip-bridge-app"
    fi
}



# Start bridge with basic configuration
start_basic() {
    # Stop any existing bridges first
    if ! stop_all_bridges; then
        print_error "Failed to stop existing bridges"
        exit 1
    fi
    
    print_status "Starting bridge with basic configuration..."
    cd "$BRIDGE_DIR"
    
    # Start bridge and capture output to temp file
    ./chip-bridge-app --vendor-id 0xFFF1 --product-id 0x8001 --product-name "Matter Bridge Demo" 2>&1 | tee "../../$TEMP_LOG" &
    
    BRIDGE_PID=$!
    echo $BRIDGE_PID > "../../bridge.pid"
    print_status "Bridge started with PID: $BRIDGE_PID"
    
    sleep 3  # Wait for startup
    
    # Display QR code information
    print_qr_info
    
    # Wait for user to stop
    echo -e "${YELLOW}Press Ctrl+C to stop the bridge...${NC}"
    wait $BRIDGE_PID
}

# Start bridge with custom configuration
start_custom() {
    # Stop any existing bridges first
    if ! stop_all_bridges; then
        print_error "Failed to stop existing bridges"
        exit 1
    fi
    
    print_status "Starting bridge with custom configuration..."
    cd "$BRIDGE_DIR"
    
    if [ -f "../../$CONFIG_FILE" ]; then
        print_status "Using configuration file: $CONFIG_FILE"
        ./chip-bridge-app --vendor-id 0xFFF1 --product-id 0x8001 --product-name "Matter Bridge Demo" --config "../../$CONFIG_FILE" 2>&1 | tee "../../$TEMP_LOG" &
    else
        print_warning "Configuration file not found, using defaults"
        start_basic
        return
    fi
    
    BRIDGE_PID=$!
    echo $BRIDGE_PID > "../../bridge.pid"
    print_status "Bridge started with PID: $BRIDGE_PID"
    
    sleep 3  # Wait for startup
    
    # Display QR code information
    print_qr_info
    
    # Wait for user to stop
    echo -e "${YELLOW}Press Ctrl+C to stop the bridge...${NC}"
    wait $BRIDGE_PID
}

# Start bridge in background with logging and QR display
start_background() {
    # Stop any existing bridges first
    if ! stop_all_bridges; then
        print_error "Failed to stop existing bridges"
        exit 1
    fi
    
    print_status "Starting bridge in background with logging..."
    cd "$BRIDGE_DIR"
    
    if [ -f "../../$CONFIG_FILE" ]; then
        ./chip-bridge-app --vendor-id 0xFFF1 --product-id 0x8001 --product-name "Matter Bridge Demo" --config "../../$CONFIG_FILE" > "../../$LOG_FILE" 2>&1 &
    else
        ./chip-bridge-app --vendor-id 0xFFF1 --product-id 0x8001 --product-name "Matter Bridge Demo" > "../../$LOG_FILE" 2>&1 &
    fi
    
    BRIDGE_PID=$!
    echo $BRIDGE_PID > "../../bridge.pid"
    print_status "Bridge started with PID: $BRIDGE_PID"
    print_status "Log file: $LOG_FILE"
    print_status "PID file: bridge.pid"
    
    # Wait a bit for startup and then show QR info automatically
    sleep 5
    print_status "Checking for pairing information..."
    
    if [ -f "../../$LOG_FILE" ]; then
        cp "../../$LOG_FILE" "../../$TEMP_LOG"
        print_qr_info
    fi
    
    print_status "Bridge is running in background. Use 'make status' to check status."
    print_status "QR codes displayed above for easy access."
}

# Stop bridge
stop_bridge() {
    if [ -f "bridge.pid" ]; then
        BRIDGE_PID=$(cat bridge.pid)
        print_status "Stopping bridge with PID: $BRIDGE_PID"
        kill $BRIDGE_PID 2>/dev/null
        rm -f bridge.pid
        print_status "Bridge stopped"
    else
        print_warning "No PID file found, trying to kill by process name..."
        pkill -f chip-bridge-app
        print_status "Bridge processes killed"
    fi
    
    # Clean up temp log
    rm -f "$TEMP_LOG"
}

# Show bridge status
show_status() {
    if [ -f "bridge.pid" ]; then
        BRIDGE_PID=$(cat bridge.pid)
        if ps -p $BRIDGE_PID > /dev/null; then
            print_status "Bridge is running with PID: $BRIDGE_PID"
        else
            print_warning "Bridge PID file exists but process is not running"
            rm -f bridge.pid
        fi
    else
        print_status "Bridge is not running"
    fi
    
    # Check for any running bridge processes
    RUNNING=$(ps aux | grep chip-bridge-app | grep -v grep | wc -l)
    if [ $RUNNING -gt 0 ]; then
        print_status "Found $RUNNING running bridge processes"
        ps aux | grep chip-bridge-app | grep -v grep
    fi
}

# Show logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        print_status "Showing recent logs (last 50 lines):"
        tail -50 "$LOG_FILE"
    else
        print_warning "No log file found"
    fi
}

# Show QR code information
show_qr() {
    if [ -f "$LOG_FILE" ]; then
        cp "$LOG_FILE" "$TEMP_LOG"
        print_qr_info
    elif [ -f "$TEMP_LOG" ]; then
        print_qr_info
    else
        print_warning "No log files found. Start the bridge first to see QR codes."
    fi
}

# Main script
main() {
    print_header
    
    case "${1:-help}" in
        "start"|"basic")
            check_bridge_app
            start_basic
            ;;
        "custom")
            check_bridge_app
            start_custom
            ;;
        "background"|"bg")
            check_bridge_app
            start_background
            ;;
        "stop")
            stop_bridge
            ;;
        "status")
            show_status
            ;;
        "logs")
            show_logs
            ;;
        "qr")
            show_qr
            ;;
        "restart")
            stop_bridge
            sleep 2
            check_bridge_app
            start_background
            ;;
        "help"|*)
            echo "Usage: $0 [command]"
            echo ""
            echo "Commands:"
            echo "  start/basic    - Start bridge with basic configuration (stops existing)"
            echo "  custom         - Start bridge with custom configuration (stops existing)"
            echo "  background/bg  - Start bridge in background + QR display (stops existing)"
            echo "  stop           - Stop running bridge"
            echo "  status         - Show bridge status"
            echo "  logs           - Show recent logs"
            echo "  qr             - Show QR code and pairing information"
            echo "  restart        - Restart bridge (stops existing first)"
            echo "  help           - Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0 start       - Start bridge interactively with QR display"
            echo "  $0 background  - Start bridge in background with automatic QR display"
            echo "  $0 qr          - Show QR codes from logs"
            echo "  $0 status      - Check if bridge is running"
            echo "  $0 logs        - View bridge logs"
            ;;
    esac
}

# Run main function
main "$@"
