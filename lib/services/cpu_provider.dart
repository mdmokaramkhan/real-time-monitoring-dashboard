import 'dart:async';
import 'dart:math';
import 'dart:ffi';
import 'package:ffi/ffi.dart';  // Add this import for calloc
import 'package:flutter/foundation.dart';
import '../models/system_stats.dart';

typedef GetCpuUsageFunc = Double Function();
typedef GetCpuUsage = double Function();

// Add new typedefs for native functions
typedef GetMemoryInfoFunc = Void Function(Pointer<Uint64> used, Pointer<Uint64> total);
typedef GetMemoryInfo = void Function(Pointer<Uint64> used, Pointer<Uint64> total);

// Add new typedef for temperature function
typedef GetCpuTemperatureFunc = Double Function();
typedef GetCpuTemperature = double Function();

typedef GetDiskInfoFunc = Void Function(Pointer<Uint64> used, Pointer<Uint64> total);
typedef GetDiskInfo = void Function(Pointer<Uint64> used, Pointer<Uint64> total);

class CpuProvider extends ChangeNotifier {
  SystemStats _stats = SystemStats();
  Timer? _updateTimer;
  bool _isMonitoring = false;
  
  final List<double> _cpuHistory = [];
  final List<double> _memoryHistory = [];
  final int _maxHistoryPoints = 30;
  
  SystemStats get stats => _stats;
  bool get isMonitoring => _isMonitoring;
  List<double> get cpuHistory => List.unmodifiable(_cpuHistory);
  List<double> get memoryHistory => List.unmodifiable(_memoryHistory);
  
  final DynamicLibrary nativeCpuLib;
  late final GetCpuUsage _getCpuUsage;
  late final GetMemoryInfo _getMemoryInfo;
  late final GetCpuTemperature _getCpuTemperature;
  late final GetDiskInfo _getDiskInfo;
  bool _isInitialized = false;

  CpuProvider({required this.nativeCpuLib}) {
    _initializeNativeFunctions();
  }

  void _initializeNativeFunctions() {
    try {
      // Initialize CPU function
      _getCpuUsage = nativeCpuLib
          .lookup<NativeFunction<GetCpuUsageFunc>>('getCpuUsage')
          .asFunction<GetCpuUsage>();

      // Initialize Memory function
      _getMemoryInfo = nativeCpuLib
          .lookup<NativeFunction<GetMemoryInfoFunc>>('getMemoryInfo')
          .asFunction<GetMemoryInfo>();

      // Initialize Disk info function
      _getDiskInfo = nativeCpuLib
          .lookup<NativeFunction<GetDiskInfoFunc>>('getDiskInfo')
          .asFunction<GetDiskInfo>();

      // Initialize Temperature function
      _getCpuTemperature = nativeCpuLib
          .lookup<NativeFunction<GetCpuTemperatureFunc>>('getCpuTemperature')
          .asFunction<GetCpuTemperature>();

      _isInitialized = true;
      debugPrint('Native functions initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('Error initializing function pointers: $e');
      debugPrint('Stack trace: $stackTrace');
      _isInitialized = false;
    }
  }
  
  /// Start monitoring system statistics at regular intervals
  void startMonitoring({Duration interval = const Duration(seconds: 1)}) {
    if (_isMonitoring) return;
    
    _isMonitoring = true;
    _updateStats(); // Update immediately
    
    // Set up periodic updates
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(interval, (_) => _updateStats());
    notifyListeners();
  }
  
  /// Stop monitoring system statistics
  void stopMonitoring() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _isMonitoring = false;
    notifyListeners();
  }
  
  /// Update all system statistics from the native code
  Future<void> _updateStats() async {
    if (!_isInitialized) {
      debugPrint('Native functions not initialized');
      return;
    }

    try {
      // Get CPU usage
      final cpuUsage = _getCpuUsage();

      // Use calloc from ffi package
      final used = malloc<Uint64>();
      final total = malloc<Uint64>();
      _getMemoryInfo(used, total);
      final memoryUsed = used.value;
      final memoryTotal = total.value;
      malloc.free(used);
      malloc.free(total);

      // Get CPU temperature
      final temperature = _getCpuTemperature();

      // Get disk info
      final diskUsed = malloc<Uint64>();
      final diskTotal = malloc<Uint64>();
      _getDiskInfo(diskUsed, diskTotal);
      final usedBytes = diskUsed.value;
      final totalBytes = diskTotal.value;
      malloc.free(diskUsed);
      malloc.free(diskTotal);

      _stats = _stats.copyWith(
        cpuUsage: cpuUsage,
        memoryUsed: memoryUsed,
        memoryTotal: memoryTotal,
        diskUsed: usedBytes,
        diskTotal: totalBytes,
        temperature: temperature,
      );

      _updateCpuHistory(cpuUsage);
      _updateMemoryHistory((memoryUsed / memoryTotal) * 100);

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating system stats: $e');
    }
  }
  
  /// Update the CPU usage history
  void _updateCpuHistory(double cpuUsage) {
    _cpuHistory.add(cpuUsage);
    
    // Limit the history to the maximum number of points
    if (_cpuHistory.length > _maxHistoryPoints) {
      _cpuHistory.removeAt(0);
    }
  }
  
  /// Update the memory usage history
  void _updateMemoryHistory(double memoryPercentage) {
    _memoryHistory.add(memoryPercentage);
    
    // Limit the history to the maximum number of points
    if (_memoryHistory.length > _maxHistoryPoints) {
      _memoryHistory.removeAt(0);
    }
  }
  
  /// Get smoothed CPU history using moving average (only last 30 seconds)
  List<double> get smoothedCpuHistory {
    if (_cpuHistory.isEmpty) return [];
    
    final smoothedData = <double>[];
    const windowSize = 3; // Smaller window size for more responsive visualization
    
    for (int i = 0; i < _cpuHistory.length; i++) {
      double sum = 0;
      int count = 0;
      
      // Calculate moving average for this point
      for (int j = max(0, i - windowSize + 1); j <= i; j++) {
        sum += _cpuHistory[j];
        count++;
      }
      
      smoothedData.add(sum / count);
    }
    
    return smoothedData;
  }
  
  /// Get smoothed memory history using moving average
  List<double> get smoothedMemoryHistory {
    if (_memoryHistory.isEmpty) return [];
    
    final smoothedData = <double>[];
    const windowSize = 3; // Same window size as CPU for consistency
    
    for (int i = 0; i < _memoryHistory.length; i++) {
      double sum = 0;
      int count = 0;
      
      // Calculate moving average for this point
      for (int j = max(0, i - windowSize + 1); j <= i; j++) {
        sum += _memoryHistory[j];
        count++;
      }
      
      smoothedData.add(sum / count);
    }
    
    return smoothedData;
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}