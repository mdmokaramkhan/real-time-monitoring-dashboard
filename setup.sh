#!/bin/bash

# Exit on error
set -e

echo "========================================"
echo "Real-Time System Monitoring Dashboard Setup"
echo "========================================"

# Detect OS
OS=$(uname -s)
echo "Detected OS: $OS"

# Build native libraries
echo -e "\n[1/3] Building native libraries..."
cd native

if [ "$OS" = "Darwin" ]; then
    # macOS
    echo "Building for macOS..."
    chmod +x build.sh
    ./build.sh
    chmod +x post_build.sh
    ./post_build.sh
elif [ "$OS" = "Linux" ]; then
    # Linux
    echo "Building for Linux..."
    chmod +x build.sh
    ./build.sh
    chmod +x post_build.sh
    ./post_build.sh
else
    # Windows (this part won't actually run in Windows, but for documentation)
    echo "For Windows, please run the following commands in a Visual Studio Developer Command Prompt:"
    echo "   cd native"
    echo "   build.bat"
    echo "   post_build.bat"
    exit 1
fi

cd ..

# Create libs directory and copy libraries
echo -e "\n[2/3] Setting up library paths..."
mkdir -p libs
cp build/libs/* libs/

# Make the libraries accessible for Flutter
echo -e "\n[3/3] Getting Flutter dependencies..."
flutter pub get

echo -e "\n========================================"
echo "Setup complete! You can now run the app with:"
echo "   flutter run -d $OS"
echo "========================================" 