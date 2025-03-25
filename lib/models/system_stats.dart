class SystemStats {
  final double cpuUsage;
  final int memoryUsed;
  final int memoryTotal;
  final double diskUsage;
  final double temperature;
  final double diskUsed;
  final double diskTotal;

  SystemStats({
    this.cpuUsage = 0.0,
    this.memoryUsed = 0,
    this.memoryTotal = 0,
    this.diskUsage = 0.0,
    this.temperature = 0.0,
    this.diskUsed = 0.0,
    this.diskTotal = 0.0,
  });

  String get memoryString => 
      '${(memoryUsed / 1024).toStringAsFixed(1)}GB / ${(memoryTotal / 1024).toStringAsFixed(1)}GB';
  
  String get cpuString => '${cpuUsage.toStringAsFixed(1)}%';
  
  String get diskString => 
      '${(diskUsed / 1024).toStringAsFixed(1)}GB / ${(diskTotal / 1024).toStringAsFixed(1)}GB';
  
  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';

  // Get free disk space
  double get diskFree => diskTotal - diskUsed;

  // Get disk usage percentage
  double get diskUsagePercentage => diskTotal > 0 ? (diskUsed / diskTotal * 100) : 0.0;

  SystemStats copyWith({
    double? cpuUsage,
    int? memoryUsed,
    int? memoryTotal,
    double? diskUsage,
    double? temperature,
    double? diskUsed,
    double? diskTotal,
  }) {
    return SystemStats(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsed: memoryUsed ?? this.memoryUsed,
      memoryTotal: memoryTotal ?? this.memoryTotal,
      diskUsage: diskUsage ?? this.diskUsage,
      temperature: temperature ?? this.temperature,
      diskUsed: diskUsed ?? this.diskUsed,
      diskTotal: diskTotal ?? this.diskTotal,
    );
  }

  factory SystemStats.fromJson(Map<String, dynamic> json) {
    return SystemStats(
      cpuUsage: json['cpuUsage']?.toDouble() ?? 0.0,
      memoryUsed: json['memoryUsed']?.toInt() ?? 0,
      memoryTotal: json['memoryTotal']?.toInt() ?? 0,
      temperature: json['temperature']?.toDouble() ?? 0.0,
      diskUsage: json['diskUsage']?.toDouble() ?? 0.0,
      diskUsed: json['diskUsed']?.toDouble() ?? 0.0,
      diskTotal: json['diskTotal']?.toDouble() ?? 0.0,
    );
  }
}