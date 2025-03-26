/// Represents information about the system
class SystemInfo {
  final String cpuModel;
  final String osVersion;
  final String hostname;
  final String kernelVersion;
  final int cpuCores;

  SystemInfo({
    this.cpuModel = 'Unknown CPU',
    this.osVersion = 'Unknown OS',
    this.hostname = 'Unknown Host',
    this.kernelVersion = 'Unknown Kernel',
    this.cpuCores = 0,
  });

  SystemInfo copyWith({
    String? cpuModel,
    String? osVersion,
    String? hostname,
    String? kernelVersion,
    int? cpuCores,
  }) {
    return SystemInfo(
      cpuModel: cpuModel ?? this.cpuModel,
      osVersion: osVersion ?? this.osVersion,
      hostname: hostname ?? this.hostname,
      kernelVersion: kernelVersion ?? this.kernelVersion,
      cpuCores: cpuCores ?? this.cpuCores,
    );
  }

  factory SystemInfo.fromJson(Map<String, dynamic> json) {
    return SystemInfo(
      cpuModel: json['cpuModel'] ?? 'Unknown CPU',
      osVersion: json['osVersion'] ?? 'Unknown OS',
      hostname: json['hostname'] ?? 'Unknown Host',
      kernelVersion: json['kernelVersion'] ?? 'Unknown Kernel',
      cpuCores: json['cpuCores']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cpuModel': cpuModel,
      'osVersion': osVersion,
      'hostname': hostname,
      'kernelVersion': kernelVersion,
      'cpuCores': cpuCores,
    };
  }
} 