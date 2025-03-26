// ignore_for_file: sized_box_for_whitespace, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cpu_provider.dart';
import '../../theme/app_theme.dart';

class SystemInfoCard extends StatelessWidget {
  const SystemInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final cpuProvider = Provider.of<CpuProvider>(context);
    final systemInfo = cpuProvider.systemInfo;
    final theme = Theme.of(context);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and refresh button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.info,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'System Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 16),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => cpuProvider.refreshSystemInfo(),
                  tooltip: 'Refresh system info',
                ),
              ],
            ),
            const Divider(height: 24),
            
            // System info in a compact grid
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                // CPU Model
                _buildCompactInfoItem(
                  context,
                  'CPU',
                  systemInfo.cpuModel,
                  Icons.memory,
                  AppTheme.success,
                ),
                
                // CPU Cores
                _buildCompactInfoItem(
                  context,
                  'Cores',
                  '${systemInfo.cpuCores} Logical',
                  Icons.developer_board,
                  AppTheme.primaryDark,
                ),
                
                // OS Info
                _buildCompactInfoItem(
                  context,
                  'OS',
                  systemInfo.osVersion,
                  Icons.computer,
                  AppTheme.warning,
                ),
                
                // Hostname
                _buildCompactInfoItem(
                  context,
                  'Host',
                  systemInfo.hostname,
                  Icons.devices,
                  AppTheme.error,
                ),
                
                // Kernel Version
                _buildCompactInfoItem(
                  context,
                  'Kernel',
                  _formatKernelVersion(systemInfo.kernelVersion),
                  Icons.terminal,
                  AppTheme.info,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Format kernel version to be more compact
  String _formatKernelVersion(String version) {
    // If kernel version is very long, extract the version number only
    if (version.length > 25) {
      // Try to extract just the version number (typically in format X.X.X)
      final match = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(version);
      if (match != null) {
        return match.group(1) ?? version;
      }
    }
    return version;
  }
  
  Widget _buildCompactInfoItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Container(
      width: isSmallScreen ? double.infinity : (screenWidth / 2) - 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
