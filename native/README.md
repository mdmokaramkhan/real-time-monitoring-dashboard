# System Monitoring Native Libraries

This directory contains native code implementations for system monitoring on different platforms (macOS, Linux, Windows). These libraries provide real-time information about:

- CPU usage
- Memory usage
- Disk usage
- System temperature

## Directory Structure

- `macos/` - Native implementation for macOS
- `linux/` - Native implementation for Linux
- `windows/` - Native implementation for Windows
- `build.sh` - Build script for macOS and Linux
- `build.bat` - Build script for Windows
- `post_build.sh` - Post-build script for macOS and Linux
- `post_build.bat` - Post-build script for Windows

## Building the Native Libraries

### macOS

```bash
# Make the script executable
chmod +x build.sh

# Build the library
./build.sh

# Copy to required locations
./post_build.sh
```

### Linux

```bash
# Make the script executable
chmod +x build.sh

# Build the library
./build.sh

# Copy to required locations
./post_build.sh
```

### Windows

```cmd
# Build the library (run from Visual Studio Developer Command Prompt)
build.bat

# Copy to required locations
post_build.bat
```

## Integration with Flutter

The native libraries are integrated with Flutter using the Dart FFI (Foreign Function Interface). The integration is handled by:

- `lib/services/cpu_services.dart` - Handles loading and calling the native libraries
- `lib/services/cpu_provider.dart` - Provides the data to the Flutter UI

## API Functions

The following functions are exposed by the native libraries:

### CPU Monitoring

- `double getCpuUsage()` - Returns the current CPU usage percentage (0-100%)

### Memory Monitoring

- `int getMemoryUsed()` - Returns the used memory in MB
- `int getMemoryTotal()` - Returns the total memory in MB

### Disk Monitoring

- `double getDiskUsage()` - Returns the disk usage percentage (0-100%)
- `double getDiskUsed()` - Returns the used disk space in MB
- `double getDiskTotal()` - Returns the total disk space in MB

### Temperature Monitoring

- `double getTemperature()` - Returns the CPU temperature in Celsius

## Platform-Specific Implementation Notes

### macOS

The macOS implementation uses Mach kernel APIs for CPU and memory statistics, and IOKit for temperature information.

### Linux

The Linux implementation uses `/proc/stat` for CPU usage, `sysinfo` for memory statistics, and `/sys/class/thermal` for temperature data.

### Windows

The Windows implementation uses the Performance Data Helper (PDH) for CPU usage, and Windows API functions for memory and disk information.

## Troubleshooting

If the native libraries are not loading, check:

1. The build process completed successfully
2. The libraries are in one of the expected locations:
   - `build/libs/` directory
   - `libs/` directory in the project root
   - App bundle's Frameworks directory (macOS)
3. The Flutter app has the necessary permissions to access system information
