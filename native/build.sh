#!/bin/bash

# Exit on error
set -e

# Create build directory
mkdir -p ../build/libs

# Detect OS
OS=$(uname -s)

if [ "$OS" = "Darwin" ]; then
    echo "Building for macOS..."
    
    # Build macOS dynamic library
    clang -shared -fPIC \
        -o ../build/libs/libcpu_monitor.dylib \
        -framework IOKit \
        -framework CoreFoundation \
        macos/cpu_monitor.c
    
    echo "macOS library built successfully: $(pwd)/../build/libs/libcpu_monitor.dylib"
    
elif [ "$OS" = "Linux" ]; then
    echo "Building for Linux..."
    
    # Build Linux shared library
    gcc -shared -fPIC \
        -o ../build/libs/libcpu_monitor.so \
        linux/cpu_monitor.c
    
    echo "Linux library built successfully: $(pwd)/../build/libs/libcpu_monitor.so"
else
    echo "Unsupported operating system: $OS"
    exit 1
fi

echo "Build complete!" 