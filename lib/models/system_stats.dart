class SystemStats {
  final double cpuUsage;
  final int memoryUsed;
  final int memoryTotal;
  final int diskUsed;    // Changed from double to int
  final int diskTotal;   // Added new field
  final double temperature;

  SystemStats({
    this.cpuUsage = 0.0,
    this.memoryUsed = 0,
    this.memoryTotal = 0,
    this.diskUsed = 0,
    this.diskTotal = 0,
    this.temperature = 0.0,
  });

  String get memoryString {
    // Convert bytes to GB (1 GB = 1024 * 1024 * 1024 bytes)
    final usedGB = (memoryUsed / (1024 * 1024 * 1024)).toStringAsFixed(1);
    final totalGB = (memoryTotal / (1024 * 1024 * 1024)).toStringAsFixed(1);
    return '${usedGB}GB / ${totalGB}GB';
  }
  
  String get cpuString => '${cpuUsage.toStringAsFixed(1)}%';
  
  String get diskString {
    final usedGB = (diskUsed / (1024 * 1024 * 1024)).toStringAsFixed(1);
    final totalGB = (diskTotal / (1024 * 1024 * 1024)).toStringAsFixed(1);
    return '${usedGB}GB / ${totalGB}GB';
  }
  
  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';

  // Add computed diskUsage getter
  double get diskUsage => diskTotal > 0 ? (diskUsed / diskTotal) * 100 : 0.0;

  SystemStats copyWith({
    double? cpuUsage,
    int? memoryUsed,
    int? memoryTotal,
    int? diskUsed,
    int? diskTotal,
    double? temperature,
  }) {
    return SystemStats(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsed: memoryUsed ?? this.memoryUsed,
      memoryTotal: memoryTotal ?? this.memoryTotal,
      diskUsed: diskUsed ?? this.diskUsed,
      diskTotal: diskTotal ?? this.diskTotal,
      temperature: temperature ?? this.temperature,
    );
  }
}