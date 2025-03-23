class SystemStats {
  final double cpuUsage;
  final int memoryUsed;
  final int memoryTotal;
  final double diskUsage;
  final double temperature;

  SystemStats({
    this.cpuUsage = 0.0,
    this.memoryUsed = 0,
    this.memoryTotal = 0,
    this.diskUsage = 0.0,
    this.temperature = 0.0,
  });

  String get memoryString => 
      '${(memoryUsed / 1024).toStringAsFixed(1)}GB / ${(memoryTotal / 1024).toStringAsFixed(1)}GB';
  
  String get cpuString => '${cpuUsage.toStringAsFixed(1)}%';
  
  String get diskString => '${diskUsage.toStringAsFixed(1)}%';
  
  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';

  SystemStats copyWith({
    double? cpuUsage,
    int? memoryUsed,
    int? memoryTotal,
    double? diskUsage,
    double? temperature,
  }) {
    return SystemStats(
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsed: memoryUsed ?? this.memoryUsed,
      memoryTotal: memoryTotal ?? this.memoryTotal,
      diskUsage: diskUsage ?? this.diskUsage,
      temperature: temperature ?? this.temperature,
    );
  }
}