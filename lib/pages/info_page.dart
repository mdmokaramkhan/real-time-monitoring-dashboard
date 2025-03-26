// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cpu_provider.dart';
import '../theme/app_theme.dart';

// Helper model for specification items
class SpecItem {
  final String label;
  final String value;
  
  SpecItem(this.label, this.value);
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final systemInfo = cpuProvider.systemInfo;
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.primaryDark,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'System Information',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hardware and software specifications',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                _buildSystemStatusChip(context),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // System Overview Card
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getDeviceTypeIcon(systemInfo.osVersion),
                                  color: AppTheme.primaryDark,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'System Overview',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            
                            // Device & Hostname
                            _buildDetailRow(
                              context, 
                              'Device Type', 
                              _getDeviceType(systemInfo.osVersion)
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context, 
                              'Hostname', 
                              systemInfo.hostname
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context, 
                              'OS', 
                              systemInfo.osVersion
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context, 
                              'Kernel Version', 
                              systemInfo.kernelVersion
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Hardware Specifications
                    Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.memory_rounded,
                                      color: AppTheme.primaryDark,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Hardware',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.refresh_rounded,
                                    color: AppTheme.primaryDark,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Refreshing system information...'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                    
                                    await cpuProvider.refreshSystemInfo();
                                  },
                                  tooltip: 'Refresh hardware information',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            
                            // CPU information
                            Text(
                              'Processor',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildDetailRow(
                              context, 
                              'Model', 
                              systemInfo.cpuModel
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context, 
                              'Cores', 
                              '${systemInfo.cpuCores}'
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context, 
                              'Architecture', 
                              _getArchitecture(systemInfo.cpuModel)
                            ),
                            
                            const SizedBox(height: 16),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            
                            // Technical specifications grid
                            Row(
                              children: [
                                Expanded(
                                  child: _buildMetricCard(
                                    context,
                                    title: 'CPU Family',
                                    value: _getCpuFamily(systemInfo.cpuModel),
                                    icon: Icons.memory_rounded,
                                    color: AppTheme.success,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    context,
                                    title: 'OS Type',
                                    value: _getOSType(systemInfo.osVersion),
                                    icon: Icons.desktop_windows_rounded,
                                    color: AppTheme.info,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildMetricCard(
                                    context,
                                    title: 'Cores',
                                    value: '${systemInfo.cpuCores}',
                                    icon: Icons.developer_board_rounded,
                                    color: AppTheme.warning,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Performance & Software
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Performance metrics
                        Expanded(
                          flex: 3,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.speed_rounded,
                                        color: AppTheme.primaryDark,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Performance',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 16),
                                  
                                  // Performance scores
                                  _buildScoreIndicator(context, 'CPU', 85, AppTheme.success),
                                  const SizedBox(height: 12),
                                  _buildScoreIndicator(context, 'Memory', 72, AppTheme.warning),
                                  const SizedBox(height: 12),
                                  _buildScoreIndicator(context, 'Disk', 90, AppTheme.success),
                                  const SizedBox(height: 12),
                                  _buildScoreIndicator(context, 'Overall', 82, AppTheme.info),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Software environment
                        Expanded(
                          flex: 2,
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.code_rounded,
                                        color: AppTheme.primaryDark,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Software',
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(height: 1),
                                  const SizedBox(height: 16),
                                  
                                  // Software versions
                                  _buildSoftwareVersionItem(context, 'Flutter', 'v3.16.0', Colors.blue),
                                  const SizedBox(height: 12),
                                  _buildSoftwareVersionItem(context, 'Dart', 'v3.2.0', Colors.teal),
                                  const SizedBox(height: 12),
                                  _buildSoftwareVersionItem(context, 'App', 'v1.0.0', AppTheme.primaryDark),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildSystemStatusChip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.success.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'System Ready',
            style: TextStyle(
              color: AppTheme.success,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildScoreIndicator(BuildContext context, String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: score / 100,
          backgroundColor: color.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _getPerformanceLabel(score),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildSoftwareVersionItem(
    BuildContext context,
    String name,
    String version,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.code_rounded,
              size: 14,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                Text(
                  version,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper methods
  String _getArchitecture(String cpuModel) {
    if (cpuModel.toLowerCase().contains('arm')) {
      return 'ARM64';
    } else if (cpuModel.toLowerCase().contains('apple')) {
      return 'Apple Silicon';
    } else if (cpuModel.toLowerCase().contains('intel')) {
      return 'x86_64';
    } else {
      return 'x86_64';
    }
  }
  
  String _getCpuFamily(String cpuModel) {
    if (cpuModel.toLowerCase().contains('intel core i9')) {
      return 'Intel Core i9';
    } else if (cpuModel.toLowerCase().contains('intel core i7')) {
      return 'Intel Core i7';
    } else if (cpuModel.toLowerCase().contains('intel core i5')) {
      return 'Intel Core i5';
    } else if (cpuModel.toLowerCase().contains('intel core i3')) {
      return 'Intel Core i3';
    } else if (cpuModel.toLowerCase().contains('apple m1')) {
      return 'Apple M1';
    } else if (cpuModel.toLowerCase().contains('apple m2')) {
      return 'Apple M2';
    } else if (cpuModel.toLowerCase().contains('apple m3')) {
      return 'Apple M3';
    } else if (cpuModel.toLowerCase().contains('amd ryzen')) {
      return 'AMD Ryzen';
    } else {
      return cpuModel.length > 20 ? '${cpuModel.substring(0, 20)}...' : cpuModel;
    }
  }
  
  String _getPerformanceLabel(int score) {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 60) return 'Average';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }
  
  IconData _getDeviceTypeIcon(String osVersion) {
    final os = osVersion.toLowerCase();
    if (os.contains('mac') || os.contains('darwin')) {
      return Icons.laptop_mac_rounded;
    } else if (os.contains('win')) {
      return Icons.laptop_windows_rounded;
    } else if (os.contains('linux')) {
      return Icons.laptop_rounded;
    } else if (os.contains('ios')) {
      return Icons.phone_iphone_rounded;
    } else if (os.contains('android')) {
      return Icons.phone_android_rounded;
    }
    return Icons.devices_rounded;
  }
  
  String _getDeviceType(String osVersion) {
    final os = osVersion.toLowerCase();
    if (os.contains('mac') || os.contains('darwin')) {
      return 'Mac Computer';
    } else if (os.contains('win')) {
      return 'Windows PC';
    } else if (os.contains('linux')) {
      return 'Linux System';
    } else if (os.contains('ios')) {
      return 'iOS Device';
    } else if (os.contains('android')) {
      return 'Android Device';
    }
    return 'Unknown Device';
  }
  
  String _getOSType(String osVersion) {
    final os = osVersion.toLowerCase();
    if (os.contains('mac') || os.contains('darwin')) {
      return 'macOS';
    } else if (os.contains('win')) {
      return 'Windows';
    } else if (os.contains('linux')) {
      return 'Linux';
    } else if (os.contains('ios')) {
      return 'iOS';
    } else if (os.contains('android')) {
      return 'Android';
    }
    return 'Unknown';
  }
}
