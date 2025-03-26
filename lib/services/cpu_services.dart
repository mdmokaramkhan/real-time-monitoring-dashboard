import 'dart:ffi';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart'; // For Utf8 and other FFI utilities

/// A service to interact with native code for CPU and system monitoring
class CpuService {
  static DynamicLibrary? _dylib;
  
  /// Function pointers for the native functions
  static Pointer<NativeFunction<Double Function()>>? _getCpuUsagePtr;
  static Pointer<NativeFunction<Int Function()>>? _getMemoryUsedPtr;
  static Pointer<NativeFunction<Int Function()>>? _getMemoryTotalPtr;
  static Pointer<NativeFunction<Double Function()>>? _getDiskUsagePtr;
  static Pointer<NativeFunction<Double Function()>>? _getDiskUsedPtr;
  static Pointer<NativeFunction<Double Function()>>? _getDiskTotalPtr;
  static Pointer<NativeFunction<Double Function()>>? _getTemperaturePtr;
  
  // System information function pointers
  static Pointer<NativeFunction<Pointer<Char> Function()>>? _getCpuModelPtr;
  static Pointer<NativeFunction<Pointer<Char> Function()>>? _getOsVersionPtr;
  static Pointer<NativeFunction<Pointer<Char> Function()>>? _getHostnamePtr;
  static Pointer<NativeFunction<Pointer<Char> Function()>>? _getKernelVersionPtr;
  static Pointer<NativeFunction<Int Function()>>? _getCpuCoreCountPtr;
  
  /// Initialize the native library
  static void initialize() {
    if (_dylib != null) return;
    
    try {
      final String libraryPath = _getLibraryPath();
      debugPrint('Loading library from: $libraryPath');
      
      if (!File(libraryPath).existsSync()) {
        debugPrint('Library not found at: $libraryPath');
        // Try to find the library in the current directory
        final String currentDir = Directory.current.path;
        debugPrint('Current directory: $currentDir');
        
        // List all files in the current directory for debugging
        try {
          final List<FileSystemEntity> files = Directory(currentDir).listSync(recursive: false);
          debugPrint('Files in current directory:');
          for (final FileSystemEntity file in files) {
            debugPrint('  ${file.path}');
          }
        } catch (e) {
          debugPrint('Error listing directory: $e');
        }
        
        return; // Early return if library doesn't exist
      }
      
      _dylib = DynamicLibrary.open(libraryPath);
      _initFunctionPointers();
      debugPrint('Native library loaded successfully');
    } catch (e) {
      debugPrint('Error loading native library: $e');
      _dylib = null; // Reset in case of error
    }
  }
  
  /// Get the path to the native library based on platform
  static String _getLibraryPath() {
    // Determine library filename based on platform
    String filename;
    if (Platform.isWindows) {
      filename = 'cpu_monitor.dll';
    } else if (Platform.isMacOS) {
      filename = 'libcpu_monitor.dylib';
    } else if (Platform.isLinux) {
      filename = 'libcpu_monitor.so';
    } else {
      throw UnsupportedError('Platform not supported: ${Platform.operatingSystem}');
    }
    
    // Get current executable path for logging
    final String executablePath = Platform.resolvedExecutable;
    debugPrint('Executable path: $executablePath');
    
    // Try different possible locations for the library
    final List<String> possiblePaths = <String>[
      // Check in the project root's libs directory
      path.join(Directory.current.path, 'libs', filename),
      
      // Check in the build/libs directory
      path.join(Directory.current.path, 'build', 'libs', filename),
      
      // Check relative to the executable
      path.join(File(Platform.resolvedExecutable).parent.path, 'libs', filename),
      path.join(File(Platform.resolvedExecutable).parent.path, 'build', 'libs', filename),
    ];
    
    // Add macOS specific paths
    if (Platform.isMacOS) {
      possiblePaths.add(path.join(File(Platform.resolvedExecutable).parent.parent.path, 'Frameworks', filename));
      possiblePaths.add(path.join(Directory.current.path, 'Contents', 'Frameworks', filename));
    }
    
    // Add development path
    possiblePaths.add(path.join(Directory.current.path, filename));
    
    // Print all possible paths for debugging
    debugPrint('Possible library paths:');
    for (final String p in possiblePaths) {
      debugPrint('  $p (exists: ${File(p).existsSync()})');
    }
    
    // Find the first path that exists
    for (final String candidatePath in possiblePaths) {
      if (File(candidatePath).existsSync()) {
        debugPrint('Found library at: $candidatePath');
        return candidatePath;
      }
    }
    
    // Default to the first path and let DynamicLibrary.open handle the error
    debugPrint('Library not found in any of the expected locations, using default path');
    return possiblePaths.first;
  }
  
  /// Initialize the function pointers to the native functions
  static void _initFunctionPointers() {
    if (_dylib == null) return;
    
    try {
      // Performance metrics
      _getCpuUsagePtr = _dylib!.lookup<NativeFunction<Double Function()>>('getCpuUsage');
      _getMemoryUsedPtr = _dylib!.lookup<NativeFunction<Int Function()>>('getMemoryUsed');
      _getMemoryTotalPtr = _dylib!.lookup<NativeFunction<Int Function()>>('getMemoryTotal');
      _getDiskUsagePtr = _dylib!.lookup<NativeFunction<Double Function()>>('getDiskUsage');
      _getDiskUsedPtr = _dylib!.lookup<NativeFunction<Double Function()>>('getDiskUsed');
      _getDiskTotalPtr = _dylib!.lookup<NativeFunction<Double Function()>>('getDiskTotal');
      _getTemperaturePtr = _dylib!.lookup<NativeFunction<Double Function()>>('getTemperature');
      
      // System information
      _getCpuModelPtr = _dylib!.lookup<NativeFunction<Pointer<Char> Function()>>('getCpuModel');
      _getOsVersionPtr = _dylib!.lookup<NativeFunction<Pointer<Char> Function()>>('getOsVersion');
      _getHostnamePtr = _dylib!.lookup<NativeFunction<Pointer<Char> Function()>>('getHostname');
      _getKernelVersionPtr = _dylib!.lookup<NativeFunction<Pointer<Char> Function()>>('getKernelVersion');
      _getCpuCoreCountPtr = _dylib!.lookup<NativeFunction<Int Function()>>('getCpuCoreCount');
      
      debugPrint('All function pointers initialized successfully');
    } catch (e) {
      debugPrint('Error initializing function pointers: $e');
      _dylib = null; // Reset library reference
    }
  }
  
  /// Get the current CPU usage percentage (0-100)
  Future<double> getCpuUsage() async {
    if (_dylib != null && _getCpuUsagePtr != null) {
      try {
        final function = _getCpuUsagePtr!.asFunction<double Function()>();
        final result = function();
        debugPrint('Native CPU usage: $result');
        if (result >= 0) return result;
      } catch (e) {
        debugPrint('Error getting CPU usage: $e');
      }
    } else {
      debugPrint('Native library not loaded for CPU usage');
    }
    
    // Return 0 if native method fails
    return 0.0;
  }
  
  /// Get the current memory usage information in MB
  Future<Map<String, int>> getMemoryInfo() async {
    if (_dylib != null && _getMemoryUsedPtr != null && _getMemoryTotalPtr != null) {
      try {
        final usedFunction = _getMemoryUsedPtr!.asFunction<int Function()>();
        final totalFunction = _getMemoryTotalPtr!.asFunction<int Function()>();
        
        final used = usedFunction();
        final total = totalFunction();
        
        debugPrint('Native memory info: used=$used MB, total=$total MB');
        if (used >= 0 && total >= 0) {
          return {'used': used, 'total': total};
        }
      } catch (e) {
        debugPrint('Error getting memory info: $e');
      }
    } else {
      debugPrint('Native library not loaded for memory info');
    }
    
    // Return zeros if native method fails
    return {'used': 0, 'total': 0};
  }
  
  /// Get the current disk usage percentage (0-100)
  Future<double> getDiskUsage() async {
    if (_dylib != null && _getDiskUsagePtr != null) {
      try {
        final function = _getDiskUsagePtr!.asFunction<double Function()>();
        final result = function();
        debugPrint('Native disk usage: $result%');
        if (result >= 0) return result;
      } catch (e) {
        debugPrint('Error getting disk usage: $e');
      }
    } else {
      debugPrint('Native library not loaded for disk usage');
    }
    
    // Return 0 if native method fails
    return 0.0;
  }
  
  /// Get the current disk used in MB
  Future<double> getDiskUsed() async {
    if (_dylib != null && _getDiskUsedPtr != null) {
      try {
        final function = _getDiskUsedPtr!.asFunction<double Function()>();
        final result = function();
        debugPrint('Native disk used: $result MB');
        if (result >= 0) return result;
      } catch (e) {
        debugPrint('Error getting disk used: $e');
      }
    } else {
      debugPrint('Native library not loaded for disk used');
    }
    
    // Return 0 if native method fails
    return 0.0;
  }
  
  /// Get the total disk size in MB
  Future<double> getDiskTotal() async {
    if (_dylib != null && _getDiskTotalPtr != null) {
      try {
        final function = _getDiskTotalPtr!.asFunction<double Function()>();
        final result = function();
        debugPrint('Native disk total: $result MB');
        if (result >= 0) return result;
      } catch (e) {
        debugPrint('Error getting disk total: $e');
      }
    } else {
      debugPrint('Native library not loaded for disk total');
    }
    
    // Return 0 if native method fails
    return 0.0;
  }
  
  /// Get the current CPU temperature in degrees Celsius
  Future<double> getTemperature() async {
    if (_dylib != null && _getTemperaturePtr != null) {
      try {
        final function = _getTemperaturePtr!.asFunction<double Function()>();
        final result = function();
        debugPrint('Native temperature: $result°C');
        if (result >= 0) return result;
      } catch (e) {
        debugPrint('Error getting temperature: $e');
      }
    } else {
      debugPrint('Native library not loaded for temperature');
    }
    
    // Return 0 if native method fails
    return 0.0;
  }
  
  /// Get the CPU model
  Future<String> getCpuModel() async {
    if (_dylib != null && _getCpuModelPtr != null) {
      try {
        final function = _getCpuModelPtr!.asFunction<Pointer<Char> Function()>();
        final result = function();
        final cpuModel = result.cast<Utf8>().toDartString();
        debugPrint('Native CPU model: $cpuModel');
        return cpuModel;
      } catch (e) {
        debugPrint('Error getting CPU model: $e');
      }
    } else {
      debugPrint('Native library not loaded for CPU model');
    }
    
    return 'Unknown CPU';
  }
  
  /// Get the OS version
  Future<String> getOsVersion() async {
    if (_dylib != null && _getOsVersionPtr != null) {
      try {
        final function = _getOsVersionPtr!.asFunction<Pointer<Char> Function()>();
        final result = function();
        final osVersion = result.cast<Utf8>().toDartString();
        debugPrint('Native OS version: $osVersion');
        return osVersion;
      } catch (e) {
        debugPrint('Error getting OS version: $e');
      }
    } else {
      debugPrint('Native library not loaded for OS version');
    }
    
    return Platform.operatingSystem;
  }
  
  /// Get the hostname
  Future<String> getHostname() async {
    if (_dylib != null && _getHostnamePtr != null) {
      try {
        final function = _getHostnamePtr!.asFunction<Pointer<Char> Function()>();
        final result = function();
        final hostname = result.cast<Utf8>().toDartString();
        debugPrint('Native hostname: $hostname');
        return hostname;
      } catch (e) {
        debugPrint('Error getting hostname: $e');
      }
    } else {
      debugPrint('Native library not loaded for hostname');
    }
    
    return 'Unknown Host';
  }
  
  /// Get the kernel version
  Future<String> getKernelVersion() async {
    if (_dylib != null && _getKernelVersionPtr != null) {
      try {
        final function = _getKernelVersionPtr!.asFunction<Pointer<Char> Function()>();
        final result = function();
        final kernelVersion = result.cast<Utf8>().toDartString();
        debugPrint('Native kernel version: $kernelVersion');
        return kernelVersion;
      } catch (e) {
        debugPrint('Error getting kernel version: $e');
      }
    } else {
      debugPrint('Native library not loaded for kernel version');
    }
    
    return 'Unknown Kernel';
  }
  
  /// Get the CPU core count
  Future<int> getCpuCoreCount() async {
    if (_dylib != null && _getCpuCoreCountPtr != null) {
      try {
        final function = _getCpuCoreCountPtr!.asFunction<int Function()>();
        final result = function();
        debugPrint('Native CPU core count: $result');
        return result;
      } catch (e) {
        debugPrint('Error getting CPU core count: $e');
      }
    } else {
      debugPrint('Native library not loaded for CPU core count');
    }
    
    return 0;
  }
}