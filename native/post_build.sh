#!/bin/bash

# Exit on error
set -e

# Detect OS
OS=$(uname -s)

# Source and target paths
SRC_DIR="../build/libs"
TARGET_DIR=""

if [ "$OS" = "Darwin" ]; then
    echo "Setting up for macOS..."
    # For macOS, we need to copy to the app bundle's Frameworks directory
    # This is for flutter build macos
    TARGET_DIR="../build/macos/Build/Products/Release/real_time_monitoring_dashboard.app/Contents/Frameworks"
    
    # Create the directory if it doesn't exist
    mkdir -p "$TARGET_DIR"
    
    # Copy the library
    echo "Copying library to $TARGET_DIR"
    cp "$SRC_DIR/libcpu_monitor.dylib" "$TARGET_DIR/"
    
elif [ "$OS" = "Linux" ]; then
    echo "Setting up for Linux..."
    # For Linux, copy to the lib directory
    TARGET_DIR="../build/linux/x64/release/bundle/lib"
    
    # Create the directory if it doesn't exist
    mkdir -p "$TARGET_DIR"
    
    # Copy the library
    echo "Copying library to $TARGET_DIR"
    cp "$SRC_DIR/libcpu_monitor.so" "$TARGET_DIR/"
else
    echo "Post-build setup not configured for OS: $OS"
    exit 0
fi

# Create a libs directory in the project root as an alternative location
mkdir -p "../libs"
cp "$SRC_DIR"/* "../libs/"

echo "Post-build setup completed!" 