# Matter Bridge Demo

A demonstration of the Matter bridge application that allows you to connect and control Matter devices through a bridge interface.

## Features

- **Matter Bridge**: Connect and control Matter devices
- **Multiple Start Modes**: Basic, custom, and background modes
- **Easy Management**: Simple commands to start, stop, and monitor
- **QR Code Support**: Easy device pairing with QR codes
- **Logging**: Comprehensive logging for debugging

## Prerequisites

- macOS (tested on macOS 13+)
- Matter SDK and tools installed
- Network access for device discovery

## Quick Start

### 1. Start the Bridge

```bash
# Start in basic mode
make start

# Or use the script directly
./start-bridge.sh basic
```

### 2. Check Status

```bash
# Check if bridge is running
make status

# View logs
make logs
```

### 3. Stop the Bridge

```bash
make stop
```

## Available Commands

### Make Commands

```bash
make start          # Start bridge in basic mode
make stop           # Stop the bridge
make restart        # Restart the bridge
make status         # Check bridge status
make logs           # Show bridge logs
make clean          # Clean up temporary files
make reset          # Reset bridge state (delete KVS data)
```

### Advanced Modes

```bash
make start-custom      # Start with custom configuration
make start-background  # Start in background mode
```

### Direct Script Usage

```bash
./start-bridge.sh basic      # Basic mode
./start-bridge.sh custom     # Custom mode
./start-bridge.sh background # Background mode
./start-bridge.sh stop       # Stop bridge
./start-bridge.sh status     # Show status
./start-bridge.sh logs       # Show logs
```

## Configuration

### Bridge Configuration

The bridge configuration is stored in `bridge-config.json`:

```json
{
  "vendor_id": "0xFFF1",
  "product_id": "0x8001",
  "product_name": "Matter Bridge Demo"
}
```

### Environment Variables

You can customize the bridge behavior by setting environment variables:

```bash
export CHIP_KVS_PATH="/path/to/kvs"
export CHIP_BRIDGE_DIR="/path/to/bridge"
```

## Device Pairing

### QR Code Pairing

1. Start the bridge: `make start`
2. Look for QR codes in the logs
3. Use your Matter app to scan the QR code
4. Follow the pairing instructions

### Manual Pairing

1. Start the bridge: `make start`
2. Look for manual pairing codes in the logs
3. Enter the code in your Matter app

## Troubleshooting

### Reset Bridge State

If you encounter pairing issues, reset the bridge:

```bash
make reset
```

This will:
- Stop the bridge
- Delete all KVS data
- Allow fresh commissioning

### Check Logs

Always check the logs for detailed information:

```bash
make logs
```

### Common Issues

- **Port already in use**: Make sure no other bridge is running
- **Permission denied**: Check file permissions
- **Network issues**: Verify network connectivity

## File Structure

```
matter-bridge-demo/
├── chip/                    # Matter bridge binaries
├── start-bridge.sh         # Main bridge management script
├── run-bridge.sh           # Alternative bridge runner
├── bridge-config.json      # Bridge configuration
├── Makefile                # Build and management commands
└── README.md               # This file
```

## Development

### Adding New Features

1. Modify the appropriate script (`start-bridge.sh` or `run-bridge.sh`)
2. Update the Makefile if needed
3. Test your changes
4. Update this README

### Testing

```bash
# Test basic functionality
make start
make status
make logs
make stop

# Test reset functionality
make reset
```

## Support

For issues and questions:
1. Check the logs: `make logs`
2. Review this README
3. Check Matter SDK documentation
4. Verify network configuration

## License

This project is for demonstration purposes. Please refer to the Matter SDK license for actual usage.
