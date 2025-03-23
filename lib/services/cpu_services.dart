import 'dart:ffi';
import 'dart:io';
import 'package:path/path.dart' as path;

/// A service to interact with native code for CPU and system monitoring
class CpuService {
  static DynamicLibrary? _dylib;
  
  /// Function pointers for the native functions
  static Pointer<NativeFunction<Double Function()>>? _getCpuUsagePtr;
  static Pointer<NativeFunction<Int Function()>>? _getMemoryUsedPtr;
  static Pointer<NativeFunction<Int Function()>>? _getMemoryTotalPtr;
  static Pointer<NativeFunction<Double Function()>>? _getDiskUsagePtr;
  static Pointer<NativeFunction<Double Function()>>? _getTemperaturePtr;
  
  /// Initialize the native library
  static void initialize() {
    if (_dylib != null) return;
    
    try {
      final String libraryPath = _getLibraryPath();
      print('Loading library from: $libraryPath');
      
      if (!File(libraryPath).existsSync()) {
        print('Library not found at: $libraryPath');
        return; // Early return if library doesn't exist
      }
      
      _dylib = DynamicLibrary.open(libraryPath);
      _initFunctionPointers();
      print('Native library loaded successfully');
    } catch (e) {
      print('Error loading native library: $e');
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
    
    // Look in the build/libs directory where our build script places the libraries
    return path.join(Directory.current.path, 'build', 'libs', filename);
  }
  
  /// Initialize the function pointers to the native functions
  static void _initFunctionPointers() {
    if (_dylib == null) return;
    
    try {
      _getCpuUsagePtr = _dylib!.lookup<NativeFunction<Double Function()>>('getCpuUsage');
      _getMemoryUsedPtr = _dylib!.lookup<NativeFunction<Int Function()>>('getMemoryUsed');
      _getMemoryTotalPtr = _dylib!.lookup<NativeFunction<Int Function()>>('getMemoryTotal');
      _getDiskUsagePtr = _dylib!.lookup<NativeFunction<Double Function()>>('getDiskUsage');
      _getTemperaturePtr = _dylib!.lookup<NativeFunction<Double Function()>>('getTemperature');
    } catch (e) {
      print('Error initializing function pointers: $e');
      _dylib = null; // Reset library reference
    }
  }
  
  /// Get the current CPU usage percentage (0-100)
  Future<double> getCpuUsage() async {
    if (_dylib != null && _getCpuUsagePtr != null) {
      try {
        final function = _getCpuUsagePtr!.asFunction<double Function()>();
        final result = function();
        if (result >= 0) return result;
      } catch (e) {
        print('Error getting CPU usage: $e');
      }
    }
    
    // Fallback to mock data
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => 30.0 + (DateTime.now().second % 40),
    );
  }
  
  /// Get the current memory usage information in MB
  Future<Map<String, int>> getMemoryInfo() async {
    if (_dylib != null && _getMemoryUsedPtr != null && _getMemoryTotalPtr != null) {
      try {
        final usedFunction = _getMemoryUsedPtr!.asFunction<int Function()>();
        final totalFunction = _getMemoryTotalPtr!.asFunction<int Function()>();
        
        final used = usedFunction();
        final total = totalFunction();
        
        if (used >= 0 && total >= 0) {
          return {'used': used, 'total': total};
        }
      } catch (e) {
        print('Error getting memory info: $e');
      }
    }
    
    // Fallback to mock data
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => {
        'used': 4096 + (DateTime.now().second * 10),
        'total': 16384,
      },
    );
  }
  
  /// Get the current disk usage percentage (0-100)
  Future<double> getDiskUsage() async {
    if (_dylib != null && _getDiskUsagePtr != null) {
      try {
        final function = _getDiskUsagePtr!.asFunction<double Function()>();
        final result = function();
        if (result >= 0) return result;
      } catch (e) {
        print('Error getting disk usage: $e');
      }
    }
    
    // Fallback to mock data
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => 40.0 + (DateTime.now().minute % 30),
    );
  }
  
  /// Get the current CPU temperature in degrees Celsius
  Future<double> getTemperature() async {
    if (_dylib != null && _getTemperaturePtr != null) {
      try {
        final function = _getTemperaturePtr!.asFunction<double Function()>();
        final result = function();
        if (result >= 0) return result;
      } catch (e) {
        print('Error getting temperature: $e');
      }
    }
    
    // Fallback to mock data
    return Future.delayed(
      const Duration(milliseconds: 100),
      () => 40.0 + (DateTime.now().second % 15),
    );
  }
}