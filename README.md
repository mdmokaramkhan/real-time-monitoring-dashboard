# 📊 Real-Time System Monitoring Dashboard
[![Flutter](https://img.shields.io/badge/Flutter-3.29.0+-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://flutter.dev)

A cross-platform desktop application for real-time system monitoring and management, built with Flutter and native code via FFI for accurate system metrics.

## ✨ Features

- **Real-time CPU Monitoring**: Track CPU usage with responsive charts
- **Memory Usage Tracking**: Monitor RAM consumption in real-time
- **Disk Space Analysis**: View disk usage across your system
- **Temperature Monitoring**: Keep an eye on your system temperature
- **Cross-Platform Support**: Works on Windows, macOS, and Linux
- **Beautiful UI**: Clean, modern interface with dark mode support

## 🛠️ Technology Stack

| Component | Technology |
|-----------|------------|
| **Frontend UI** | Flutter with Material Design |
| **Backend Logic** | Native C code with platform-specific APIs |
| **Integration** | Dart FFI (Foreign Function Interface) |
| **State Management** | Provider pattern |
| **Charts & Visualizations** | fl_chart |

## 📦 Dependencies & Packages
| Package | Purpose |
|---------|---------|
| **provider** | State management |
| **ffi** | Foreign Function Interface for native code |
| **fl_chart** | Beautiful and responsive charts |
| **path** | Path manipulation utilities |
| **shared_preferences** | Local storage for app settings |

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.29.0+)
- [Git](https://git-scm.com/downloads)
- Platform-specific development tools:

  | Platform | Requirements |
  |----------|--------------|
  | **Windows** | Visual Studio with C++ Build Tools |
  | **Linux** | g++, make, and required development libraries |
  | **macOS** | Xcode with Command Line Tools |

### Building the Native Libraries

The system monitoring features rely on native code implementations for accurate metrics. Before running the app, you need to build the native libraries:

1. Navigate to the `native` directory:
   ```bash
   cd native
   ```

2. Build the libraries according to your platform:

   **macOS/Linux**:
   ```bash
   chmod +x build.sh
   ./build.sh
   ./post_build.sh
   ```

   **Windows** (run from Visual Studio Developer Command Prompt):
   ```cmd
   build.bat
   post_build.bat
   ```

### Running the Application

After building the native libraries, you can run the application:

```bash
flutter run -d windows  # For Windows
flutter run -d macos    # For macOS
flutter run -d linux    # For Linux
```

## 📸 Screenshots

[Screenshots of the dashboard will be added here]

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests.
