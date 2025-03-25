import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:real_time_monitoring_dashboard/services/cpu_services.dart';
import '../models/system_stats.dart';

class CpuProvider extends ChangeNotifier {
  final CpuService _cpuService = CpuService();
  SystemStats _stats = SystemStats(
    cpuUsage: 0.0,
    memoryUsed: 0,
    memoryTotal: 8192, // 8GB
    diskUsage: 0.0,
    temperature: 0.0,
    diskUsed: 0.0,
    diskTotal: 1024 * 1024, // 1TB in MB
  );
  Timer? _updateTimer;
  bool _isMonitoring = false;
  
  // Track histories
  final List<double> _cpuHistory = [];
  final List<double> _memoryHistory = [];
  final List<double> _diskHistory = [];
  final int _maxHistoryPoints = 30;
  
  SystemStats get stats => _stats;
  bool get isMonitoring => _isMonitoring;
  List<double> get cpuHistory => List.unmodifiable(_cpuHistory);
  List<double> get memoryHistory => List.unmodifiable(_memoryHistory);
  List<double> get diskHistory => List.unmodifiable(_diskHistory);
  
  CpuProvider() {
    // Initialize the native library
    CpuService.initialize();
    
    // Start with some initial data
    _simulateData();
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
      final cpuUsage = await _cpuService.getCpuUsage();
      final memoryInfo = await _cpuService.getMemoryInfo();
      final diskUsage = await _cpuService.getDiskUsage();
      final temperature = await _cpuService.getTemperature();
      
      // Get disk used and total in MB
      final diskTotal = 1024 * 1024; // 1TB in MB
      final diskUsed = (diskUsage / 100) * diskTotal;
      
      _stats = _stats.copyWith(
        cpuUsage: cpuUsage,
        memoryUsed: memoryInfo['used'],
        memoryTotal: memoryInfo['total'],
        diskUsage: diskUsage,
        temperature: temperature,
        diskUsed: diskUsed,
        diskTotal: diskTotal.toDouble(),
      );
      
      // Update histories
      _updateCpuHistory(cpuUsage);
      _updateMemoryHistory((memoryInfo['used']! / memoryInfo['total']!) * 100);
      _updateDiskHistory(diskUsage);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating system stats: $e');
      // If there's an error, use simulated data instead
      _simulateData();
    }
  }
  
  /// Generate simulated data (for testing or when real data is unavailable)
  void _simulateData() {
    final random = Random();
    
    // CPU: 10-80% usage
    final cpuUsage = 10.0 + random.nextDouble() * 70.0;
    
    // Memory: 2-7GB used of 8GB
    final memoryUsed = 2048 + random.nextInt(5120);
    final memoryTotal = 8192; // 8GB
    
    // Disk: 40-90% usage of 1TB
    final diskUsage = 40.0 + random.nextDouble() * 50.0;
    final diskTotal = 1024 * 1024; // 1TB in MB
    final diskUsed = (diskUsage / 100) * diskTotal;
    
    // Temperature: 35-75°C
    final temperature = 35.0 + random.nextDouble() * 40.0;
    
    _stats = _stats.copyWith(
      cpuUsage: cpuUsage,
      memoryUsed: memoryUsed,
      memoryTotal: memoryTotal,
      diskUsage: diskUsage,
      temperature: temperature,
      diskUsed: diskUsed,
      diskTotal: diskTotal.toDouble(),
    );
    
    // Update histories
    _updateCpuHistory(cpuUsage);
    _updateMemoryHistory((memoryUsed / memoryTotal) * 100);
    _updateDiskHistory(diskUsage);
    
    notifyListeners();
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