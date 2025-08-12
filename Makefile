# Matter Bridge Demo - Simple Makefile
# Simple Makefile for Matter Bridge Management

.PHONY: help start stop restart status logs clean reset install-deps

# Default target
help:
	@echo "Matter Bridge Demo - Available Commands:"
	@echo ""
	@echo "Bridge Management:"
	@echo "  start     - Start the bridge in basic mode"
	@echo "  stop      - Stop the bridge"
	@echo "  restart   - Restart the bridge"
	@echo "  status    - Check bridge status"
	@echo "  logs      - Show bridge logs"
	@echo "  clean     - Clean up temporary files"
	@echo "  reset     - Reset bridge state (delete KVS data)"
	@echo ""
	@echo "Advanced:"
	@echo "  start-custom - Start with custom configuration"
	@echo "  start-background - Start in background mode"
	@echo ""
	@echo "Setup:"
	@echo "  install-deps - Install all required dependencies"
	@echo ""
	@echo "Examples:"
	@echo "  make start"
	@echo "  make logs"
	@echo "  make reset"

# Bridge management
start:
	@echo "🚀 Starting Matter Bridge in basic mode..."
	./start-bridge.sh basic

stop:
	@echo "🛑 Stopping Matter Bridge..."
	@if pgrep -f "chip-bridge-app" > /dev/null; then \
		pkill -f "chip-bridge-app"; \
		echo "✅ Bridge stopped"; \
	else \
		echo "ℹ️  Bridge is not running"; \
	fi

restart: stop start

status:
	@echo "📊 Bridge Status:"
	@if pgrep -f "chip-bridge-app" > /dev/null; then \
		echo "✅ Bridge is running (PID: $$(pgrep -f 'chip-bridge-app'))"; \
		echo "📍 Process info:"; \
		ps aux | grep "chip-bridge-app" | grep -v grep; \
	else \
		echo "❌ Bridge is not running"; \
	fi

logs:
	@echo "📋 Bridge Logs:"
	@if [ -f "chip/temp_bridge.log" ]; then \
		tail -f chip/temp_bridge.log; \
	else \
		echo "ℹ️  No log file found. Start the bridge first."; \
	fi

clean:
	@echo "🧹 Cleaning up temporary files..."
	@rm -f chip/temp_bridge.log chip/bridge.log chip/bridge.pid
	@echo "✅ Cleanup completed"

reset:
	@echo "🔄 Resetting bridge state..."
	@make stop
	@echo "🗑️  Deleting KVS data..."
	@rm -rf /tmp/chip_kvs*
	@echo "✅ Reset completed. Bridge is ready for new commissioning."

# Advanced bridge modes
start-custom:
	@echo "🚀 Starting Matter Bridge with custom configuration..."
	./start-bridge.sh custom

start-background:
	@echo "🚀 Starting Matter Bridge in background mode..."
	./start-bridge.sh background

# Dependency installation
install-deps:
	@echo "📦 Installing Matter Bridge dependencies..."
	@echo "This will check and install all required packages."
	@echo ""
	./install-dependencies.sh
