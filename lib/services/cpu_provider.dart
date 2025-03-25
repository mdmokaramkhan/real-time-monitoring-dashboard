import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:real_time_monitoring_dashboard/services/cpu_services.dart';
import '../models/system_stats.dart';

class CpuProvider extends ChangeNotifier {
  final CpuService _cpuService = CpuService();
  SystemStats _stats = SystemStats();
  Timer? _updateTimer;
  bool _isMonitoring = false;
  
  // Modify CPU history tracking to store only last 30 seconds
  final List<double> _cpuHistory = [];
  final int _maxHistoryPoints = 30; // Reduced to 30 seconds of data
  
  // Add memory history tracking
  final List<double> _memoryHistory = [];
  
  SystemStats get stats => _stats;
  bool get isMonitoring => _isMonitoring;
  List<double> get cpuHistory => List.unmodifiable(_cpuHistory);
  List<double> get memoryHistory => List.unmodifiable(_memoryHistory);
  
  CpuProvider() {
    // Initialize the native library
    CpuService.initialize();
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
      
      _stats = _stats.copyWith(
        cpuUsage: cpuUsage,
        memoryUsed: memoryInfo['used'],
        memoryTotal: memoryInfo['total'],
        diskUsage: diskUsage,
        temperature: temperature,
      );
      
      // Update CPU history
      _updateCpuHistory(cpuUsage);
      
      // Update memory history - calculate percentage
      double memoryPercentage = (memoryInfo['used']! / memoryInfo['total']!) * 100;
      _updateMemoryHistory(memoryPercentage);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating system stats: $e');
      // Keep using the last available stats
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