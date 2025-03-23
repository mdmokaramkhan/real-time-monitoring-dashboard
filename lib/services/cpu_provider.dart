import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:real_time_monitoring_dashboard/services/cpu_services.dart';
import '../models/system_stats.dart';

class CpuProvider extends ChangeNotifier {
  final CpuService _cpuService = CpuService();
  SystemStats _stats = SystemStats();
  Timer? _updateTimer;
  bool _isMonitoring = false;
  
  SystemStats get stats => _stats;
  bool get isMonitoring => _isMonitoring;
  
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
      // final temperature = await _cpuService.getTemperature();
      
      _stats = _stats.copyWith(
        cpuUsage: cpuUsage,
        memoryUsed: memoryInfo['used'],
        memoryTotal: memoryInfo['total'],
        diskUsage: diskUsage,
        temperature: 0,
      );
      
      notifyListeners();
    } catch (e) {
      print('Error updating system stats: $e');
      // Keep using the last available stats
    }
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}