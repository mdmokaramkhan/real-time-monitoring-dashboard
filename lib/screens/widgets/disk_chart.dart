// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:real_time_monitoring_dashboard/models/system_stats.dart';

import '../../services/cpu_provider.dart';
import '../../theme/app_theme.dart';

class DiskChartCard extends StatelessWidget {
  const DiskChartCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CpuProvider>(context);
    final stats = provider.stats;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
            // Header section - more compact
            Row(
              children: [
                Icon(Icons.storage_outlined, color: Colors.blue, size: 20),
                const SizedBox(width: 6),
                Text('Disk Storage', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                _buildDiskIndicator(context, stats.diskUsagePercentage),
              ],
            ),
            
            const SizedBox(height: 12), // Reduced spacing
            
            // Progress bar section
            _buildUsageProgressBar(context, stats),
            
            const SizedBox(height: 12), // Reduced spacing
            const Divider(height: 1),
            const SizedBox(height: 8), // Reduced spacing
            
            // Key metrics - more compact layout
            Expanded(
              child: _buildKeyMetrics(context, stats),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiskIndicator(BuildContext context, double diskUsage) {
    Color color = _getUsageColor(diskUsage);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${diskUsage.toStringAsFixed(1)}%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildUsageProgressBar(BuildContext context, SystemStats stats) {
    final usageColor = _getUsageColor(stats.diskUsagePercentage);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: stats.diskUsagePercentage / 100,
            backgroundColor: Colors.grey.shade200,
            color: usageColor,
            minHeight: 10, // Slightly smaller for compactness
          ),
        ),
        
        // Labels for used and free - more compact
        const SizedBox(height: 4), // Reduced spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Used: ${(stats.diskUsed / 1024).toStringAsFixed(1)} GB',
              style: TextStyle(
                fontSize: 12, // Smaller font
                fontWeight: FontWeight.w500,
                color: usageColor,
              ),
            ),
            Text(
              'Free: ${(stats.diskFree / 1024).toStringAsFixed(1)} GB',
              style: TextStyle(
                fontSize: 12, // Smaller font
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(BuildContext context, SystemStats stats) {
    // If no data, show loading state
    if (stats.diskTotal <= 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading disk information...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    // More compact text-based layout in three columns
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disk Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13, // Smaller font
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8), // Reduced spacing
        
        // Main info row - three columns
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextInfo('Total:', '${(stats.diskTotal / 1024).toStringAsFixed(1)} GB', Colors.blue),
                    const SizedBox(height: 8), // Reduced spacing
                    _buildTextInfo('Used:', '${(stats.diskUsed / 1024).toStringAsFixed(1)} GB', 
                        _getUsageColor(stats.diskUsagePercentage)),
                    const SizedBox(height: 8), // Reduced spacing
                    _buildTextInfo('Free:', '${(stats.diskFree / 1024).toStringAsFixed(1)} GB', Colors.grey.shade700),
                  ],
                ),
              ),
              
              // Second column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextInfo('File System:', 'NTFS', Colors.teal),
                    const SizedBox(height: 8), // Reduced spacing
                    _buildTextInfo('Mount Point:', 'C:/', Colors.amber.shade700),
                    const SizedBox(height: 8), // Reduced spacing
                    _buildTextInfo('R/W Speed:', '${(250 + (stats.diskUsagePercentage / 2)).toStringAsFixed(0)} MB/s', Colors.purple),
                  ],
                ),
              ),
              
              // Third column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextInfo('Health:', _getDiskHealthStatus(stats.diskUsagePercentage), 
                        _getDiskHealthColor(stats.diskUsagePercentage)),
                    const SizedBox(height: 8), // Reduced spacing
                    _buildTextInfo('Usage:', '${stats.diskUsagePercentage.toStringAsFixed(1)}%', 
                        _getUsageColor(stats.diskUsagePercentage)),
                    const SizedBox(height: 8), // Reduced spacing
                    _buildTextInfo('Format Date:', '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}', 
                        Colors.blue.shade700),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTextInfo(String label, String value, Color valueColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11, // Smaller font
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 4), // Smaller spacing
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
  
  String _getDiskHealthStatus(double percentage) {
    if (percentage < 50) return 'Good';
    if (percentage < 80) return 'Warning';
    return 'Critical';
  }
  
  Color _getDiskHealthColor(double percentage) {
    if (percentage < 50) return AppTheme.success;
    if (percentage < 80) return AppTheme.warning;
    return AppTheme.error;
  }
  
  Color _getUsageColor(double percentage) {
    if (percentage < 50) return AppTheme.success;
    if (percentage < 80) return AppTheme.warning;
    return AppTheme.error;
  }
}
