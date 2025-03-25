import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_monitoring_dashboard/theme/app_theme.dart';
import '../../services/cpu_provider.dart';
import 'dart:io' show Platform;

class SystemInfoCard extends StatelessWidget {
  const SystemInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(0.05 * 255 ~/ 1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withAlpha(0.3 * 255 ~/ 1),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - compact
            Row(
              children: [
                Icon(
                  Icons.computer_rounded,
                  color: AppTheme.warning,
                  size: 20,
                ),
                const SizedBox(width: 6), // Reduced spacing
                Text(
                  'System Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            
            const SizedBox(height: 12), // Reduced spacing
            const Divider(height: 1),
            const SizedBox(height: 12), // Reduced spacing
            
            // Main content - more compact
            Expanded(
              child: Consumer<CpuProvider>(
                builder: (context, provider, _) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Operating System'),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem('Platform:', _getPlatformName(), Theme.of(context).primaryColor),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem('Version:', _getSystemVersion(), Colors.teal),
                            
                            // const Spacer(),
                            
                            _buildSectionTitle(context, 'Performance'),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem(
                              'CPU:',
                              '${provider.stats.cpuUsage.toStringAsFixed(1)}%',
                              _getStatusColor(provider.stats.cpuUsage)
                            ),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem(
                              'Memory:',
                              '${((provider.stats.memoryUsed / provider.stats.memoryTotal) * 100).toStringAsFixed(1)}%',
                              _getStatusColor((provider.stats.memoryUsed / provider.stats.memoryTotal) * 100)
                            ),
                          ],
                        ),
                      ),
                      
                      // Right column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Hardware'),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem('CPU Cores:', _getProcessorCount(), Colors.purple.shade700),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem(
                              'Memory:',
                              '${(provider.stats.memoryTotal / 1024).toStringAsFixed(1)} GB', 
                              Colors.blue
                            ),
                            
                            // const Spacer(),
                            
                            _buildSectionTitle(context, 'Status'),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem(
                              'System:',
                              provider.isMonitoring ? 'Active' : 'Inactive',
                              provider.isMonitoring ? Colors.green : Colors.red
                            ),
                            const SizedBox(height: 6), // Reduced spacing
                            _buildInfoItem('Uptime:', _getUptimeString(), Colors.amber.shade700),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12, // Smaller font
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11, // Smaller font
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4), // Reduced spacing
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12, // Smaller font
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(double percentage) {
    if (percentage < 50) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
  }

  // Helper methods to get system information
  String _getPlatformName() {
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isIOS) return 'iOS';
    return 'Unknown';
  }

  String _getSystemVersion() {
    // In a real app, you would get the actual OS version
    // This is just a placeholder
    if (Platform.isWindows) return 'Windows 11';
    if (Platform.isMacOS) return 'macOS Sonoma';
    if (Platform.isLinux) return 'Linux Kernel ${Platform.operatingSystemVersion}';
    return Platform.operatingSystemVersion;
  }

  String _getProcessorCount() {
    return '${Platform.numberOfProcessors} Cores';
  }

  String _getUptimeString() {
    final uptime = DateTime.now().difference(DateTime.now().subtract(const Duration(hours: 48)));
    final days = uptime.inDays;
    final hours = uptime.inHours % 24;
    final minutes = uptime.inMinutes % 60;
    
    if (days > 0) {
      return '$days day${days > 1 ? "s" : ""}, $hours hr';
    } else if (hours > 0) {
      return '$hours hr${hours > 1 ? "s" : ""}, $minutes min';
    } else {
      return '$minutes min';
    }
  }
}
