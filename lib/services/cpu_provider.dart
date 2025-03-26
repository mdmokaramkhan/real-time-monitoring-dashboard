import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:real_time_monitoring_dashboard/models/system_info.dart';
import 'package:real_time_monitoring_dashboard/services/cpu_services.dart';
import '../models/system_stats.dart';

class CpuProvider extends ChangeNotifier {
  final CpuService _cpuService = CpuService();
  SystemStats _stats = SystemStats(
    cpuUsage: 0.0,
    memoryUsed: 0,
    memoryTotal: 0,
    diskUsage: 0.0,
    temperature: 0.0,
    diskUsed: 0.0,
    diskTotal: 0.0,
  );
  SystemInfo _systemInfo = SystemInfo();
  Timer? _updateTimer;
  bool _isMonitoring = false;
  bool _nativeLibraryLoaded = false;
  
  // Track histories
  final List<double> _cpuHistory = [];
  final List<double> _memoryHistory = [];
  final List<double> _diskHistory = [];
  final int _maxHistoryPoints = 30;
  
  SystemStats get stats => _stats;
  SystemInfo get systemInfo => _systemInfo;
  bool get isMonitoring => _isMonitoring;
  List<double> get cpuHistory => List.unmodifiable(_cpuHistory);
  List<double> get memoryHistory => List.unmodifiable(_memoryHistory);
  List<double> get diskHistory => List.unmodifiable(_diskHistory);
  bool get nativeLibraryLoaded => _nativeLibraryLoaded;
  
  CpuProvider() {
    // Initialize the native library
    CpuService.initialize();
    
    // Initial setup sequence
    _initializeData();
  }
  
  /// Set up initial data loading and monitoring
  Future<void> _initializeData() async {
    // Try to get initial data to check if native library works
    await _checkNativeLibrary();
    
    // Get initial system statistics
    await _updateStats();
    
    // Get detailed system information
    await _fetchSystemInfo();
    
    // Automatically start monitoring with a small delay to ensure UI is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      startMonitoring();
    });
  }
  
  /// Test if the native library is loaded and working
  Future<void> _checkNativeLibrary() async {
    try {
      final cpuUsage = await _cpuService.getCpuUsage();
      final memoryInfo = await _cpuService.getMemoryInfo();
      
      // Check if we got non-zero values back - this would indicate
      // the native library is working properly
      if (cpuUsage > 0 || (memoryInfo['used'] ?? 0) > 0) {
        _nativeLibraryLoaded = true;
        debugPrint('Native library successfully loaded and working!');
      } else {
        debugPrint('Native library loaded but returned zero values');
        _nativeLibraryLoaded = false;
      }
    } catch (e) {
      debugPrint('Native library check failed: $e');
      _nativeLibraryLoaded = false;
    }
  }
  
  /// Fetch system information from native code
  Future<void> _fetchSystemInfo() async {
    try {
      if (_nativeLibraryLoaded) {
        // Get system info using native code
        final cpuModel = await _cpuService.getCpuModel();
        final osVersion = await _cpuService.getOsVersion();
        final hostname = await _cpuService.getHostname();
        final kernelVersion = await _cpuService.getKernelVersion();
        final cpuCores = await _cpuService.getCpuCoreCount();
        
        _systemInfo = SystemInfo(
          cpuModel: cpuModel,
          osVersion: osVersion,
          hostname: hostname,
          kernelVersion: kernelVersion,
          cpuCores: cpuCores,
        );
      } else {
        // Use platform information if native library isn't working
        debugPrint('Using simulated system info because native library is not working');
        _systemInfo = SystemInfo(
          cpuModel: 'Simulated CPU',
          osVersion: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
          hostname: 'Simulated Host',
          kernelVersion: 'Simulated Kernel',
          cpuCores: 4, // Assume 4 cores
        );
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching system info: $e');
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
    try {
      double cpuUsage;
      Map<String, int> memoryInfo;
      double diskUsed;
      double diskTotal;
      double diskUsage;
      double temperature;
      
      if (_nativeLibraryLoaded) {
        // Get system stats using native code
        cpuUsage = await _cpuService.getCpuUsage();
        memoryInfo = await _cpuService.getMemoryInfo();
        diskUsed = await _cpuService.getDiskUsed();
        diskTotal = await _cpuService.getDiskTotal();
        diskUsage = diskTotal > 0 ? (diskUsed / diskTotal * 100) : 0.0;
        temperature = await _cpuService.getTemperature();
      } else {
        // Use simulated data if native library isn't working
        debugPrint('Using simulated data because native library is not working');
        final random = Random();
        
        // CPU: 10-80% usage
        cpuUsage = 10.0 + random.nextDouble() * 70.0;
        
        // Memory: 4-12GB of 16GB
        final memUsed = 4096 + random.nextInt(8192);
        final memTotal = 16384;
        memoryInfo = {'used': memUsed, 'total': memTotal};
        
        // Disk: 40-90% usage of 500GB
        diskUsage = 40.0 + random.nextDouble() * 50.0;
        diskTotal = 500 * 1024; // 500GB in MB
        diskUsed = (diskUsage / 100) * diskTotal;
        
        // Temperature: 35-60°C
        temperature = 35.0 + random.nextDouble() * 25.0;
      }
      
      final memUsed = memoryInfo['used'] ?? 0;
      final memTotal = memoryInfo['total'] ?? 1;
      
      _stats = _stats.copyWith(
        cpuUsage: cpuUsage,
        memoryUsed: memUsed,
        memoryTotal: memTotal,
        diskUsage: diskUsage,
        temperature: temperature,
        diskUsed: diskUsed,
        diskTotal: diskTotal,
      );
      
      // Update histories
      _updateCpuHistory(cpuUsage);
      _updateMemoryHistory(memTotal > 0 ? (memUsed / memTotal) * 100 : 0.0);
      _updateDiskHistory(diskUsage);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating system stats: $e');
    }
  }
  
  /// Refresh system information
  Future<void> refreshSystemInfo() async {
    await _fetchSystemInfo();
  }
  
  /// Update the CPU usage history
  void _updateCpuHistory(double cpuUsage) {
    _cpuHistory.add(cpuUsage);
    if (_cpuHistory.length > _maxHistoryPoints) {
      _cpuHistory.removeAt(0);
    }
  }
  
  /// Update the memory usage history
  void _updateMemoryHistory(double memoryPercentage) {
    _memoryHistory.add(memoryPercentage);
    if (_memoryHistory.length > _maxHistoryPoints) {
      _memoryHistory.removeAt(0);
    }
  }
  
  /// Update the disk usage history
  void _updateDiskHistory(double diskPercentage) {
    _diskHistory.add(diskPercentage);
    if (_diskHistory.length > _maxHistoryPoints) {
      _diskHistory.removeAt(0);
    }
  }
  
  /// Get smoothed CPU history using moving average
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
  
  /// Force reload all data
  Future<void> refreshAllData() async {
    final wasMonitoring = _isMonitoring;
    
    // Temporarily stop monitoring
    if (wasMonitoring) {
      stopMonitoring();
    }
    
    // Clear existing history data for a fresh start
    _cpuHistory.clear();
    _memoryHistory.clear();
    _diskHistory.clear();
    
    // Reload all data
    await _updateStats();
    await _fetchSystemInfo();
    
    // Restart monitoring
    if (wasMonitoring) {
      startMonitoring();
    }
    
    notifyListeners();
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}