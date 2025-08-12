#!/bin/bash

# Matter Bridge Demo - Simple Startup
# Simple and minimal Matter bridge startup script

echo "🚀 Starting Matter Bridge..."
echo "🚀 Starting Matter Bridge..."

# Function to stop all existing bridge processes
stop_all_bridges() {
    echo "🔍 Checking for existing bridge processes..."
    echo "🔍 Checking for existing bridge processes..."
    
    # Check if there are any running bridge processes
    RUNNING=$(ps aux | grep chip-bridge-app | grep -v grep | wc -l)
    
    if [ $RUNNING -gt 0 ]; then
        echo "⚠️  Found $RUNNING running bridge process(es), stopping them..."
        echo "⚠️  Found $RUNNING running bridge process(es), stopping them..."
        
        # Stop by PID file if exists
        if [ -f "bridge.pid" ]; then
            BRIDGE_PID=$(cat bridge.pid)
            if ps -p $BRIDGE_PID > /dev/null; then
                echo "🛑 Stopping bridge with PID: $BRIDGE_PID"
                echo "🛑 Stopping bridge with PID: $BRIDGE_PID"
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
            echo "⚠️  Force killing remaining processes..."
            echo "⚠️  Force killing remaining processes..."
            pkill -9 -f chip-bridge-app 2>/dev/null
            sleep 1
        fi
        
        # Verify all stopped
        RUNNING_FINAL=$(ps aux | grep chip-bridge-app | grep -v grep | wc -l)
        if [ $RUNNING_FINAL -eq 0 ]; then
            echo "✅ All bridge processes stopped successfully"
            echo "✅ All bridge processes stopped successfully"
        else
            echo "❌ Failed to stop all bridge processes"
            echo "❌ Failed to stop all bridge processes"
            return 1
        fi
    else
        echo "✅ No existing bridge processes found"
        echo "✅ No existing bridge processes found"
    fi
    
    # Clean up old files
    rm -f temp_bridge.log
    rm -f bridge.pid 2>/dev/null
    
    return 0
}

# Stop any existing bridges first
if ! stop_all_bridges; then
    echo "❌ Error: Failed to stop existing bridges"
    echo "❌ Error: Failed to stop existing bridges"
    exit 1
fi

# Navigate to the bridge application directory
cd "$(dirname "$0")/chip/macos-arm64-bridge-app/standalone"

# Check if the bridge application exists
if [ ! -f "./chip-bridge-app" ]; then
    echo "❌ Error: chip-bridge-app not found"
    echo "❌ Error: chip-bridge-app not found"
    exit 1
fi

# Make sure the application is executable
chmod +x ./chip-bridge-app

echo "📍 Location: $(pwd)"
echo "📍 Location: $(pwd)"
echo "🔧 Running Bridge Application..."
echo "🔧 Running Bridge Application..."

# Create temporary log file for QR code extraction
TEMP_LOG="../../temp_bridge.log"

# Run the bridge application and capture output
./chip-bridge-app --vendor-id 0xFFF1 --product-id 0x8001 --product-name "Matter Bridge Demo" 2>&1 | tee "$TEMP_LOG" &
BRIDGE_PID=$!

# Save PID to file
echo $BRIDGE_PID > "../../bridge.pid"
echo "📝 Bridge PID: $BRIDGE_PID"

# Wait for startup and QR code generation
sleep 5

echo ""
echo "🔍 Looking for pairing codes..."
echo "🔍 Looking for pairing codes..."

# Extract and display QR code information
if [ -f "$TEMP_LOG" ]; then
    QR_CODE=$(grep "SetupQRCode:" "$TEMP_LOG" | head -1 | sed 's/.*SetupQRCode: \[\(.*\)\].*/\1/')
    PAIRING_CODE=$(grep "Manual pairing code:" "$TEMP_LOG" | head -1 | sed 's/.*Manual pairing code: \[\(.*\)\].*/\1/')
    
    if [ ! -z "$QR_CODE" ]; then
        echo ""
        echo "🔗 Google Home Pairing Codes:"
        echo "🔗 Google Home Pairing Codes:"
        echo ""
        echo "📱 QR Code: $QR_CODE"
        echo "🔢 Manual Pairing Code: $PAIRING_CODE"
        echo "🔢 Manual Pairing Code: $PAIRING_CODE"
        echo ""
        echo "🌐 QR Code Link:"
        echo "🌐 QR Code Link:"
        echo "   https://project-chip.github.io/connectedhomeip/qrcode.html?data=${QR_CODE//:/%3A}"
        echo ""
        echo "💡 Pairing Instructions:"
        echo "💡 Pairing Instructions:"
        echo "   1. Open Google Home App"
        echo "   2. Click '+' (Add Device)"
        echo "   3. Select 'Set up device'"
        echo "   4. Select 'Matter' or 'Smart Device'"
        echo "   5. Scan QR Code or enter manual code"
        echo ""
        echo "✅ Pairing codes displayed above - Bridge is ready to use!"
        echo "✅ Pairing codes displayed above - Bridge is ready to use!"
        echo ""
    else
        echo "⚠️  No pairing codes found yet, waiting..."
        echo "⚠️  No pairing codes found yet, waiting..."
        
        # Wait a bit more and try again
        sleep 3
        if [ -f "$TEMP_LOG" ]; then
            QR_CODE=$(grep "SetupQRCode:" "$TEMP_LOG" | head -1 | sed 's/.*SetupQRCode: \[\(.*\)\].*/\1/')
            PAIRING_CODE=$(grep "Manual pairing code:" "$TEMP_LOG" | head -1 | sed 's/.*Manual pairing code: \[\(.*\)\].*/\1/')
            
            if [ ! -z "$QR_CODE" ]; then
                echo ""
                echo "🔗 Google Home Pairing Codes:"
                echo "🔗 Google Home Pairing Codes:"
                echo ""
                echo "📱 QR Code: $QR_CODE"
                echo "🔢 Manual Pairing Code: $PAIRING_CODE"
                echo "🔢 Manual Pairing Code: $PAIRING_CODE"
                echo ""
                echo "🌐 QR Code Link:"
                echo "🌐 QR Code Link:"
                echo "   https://project-chip.github.io/connectedhomeip/qrcode.html?data=${QR_CODE//:/%3A}"
                echo ""
                echo "✅ Pairing codes displayed above - Bridge is ready to use!"
                echo "✅ Pairing codes displayed above - Bridge is ready to use!"
                echo ""
            fi
        fi
    fi
fi

echo "✅ Bridge Application running. Press Ctrl+C to stop."
echo "✅ Bridge Application running. Press Ctrl+C to stop."

# Wait for the bridge process
wait $BRIDGE_PID

# Clean up
rm -f "$TEMP_LOG"
rm -f "../../bridge.pid"

echo "✅ Bridge Application finished"
echo "✅ Bridge Application finished"
