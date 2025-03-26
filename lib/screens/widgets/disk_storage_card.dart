// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/cpu_provider.dart';
import '../../theme/app_theme.dart';
import 'dart:math' as math;

class DiskStorageCard extends StatelessWidget {
  const DiskStorageCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CpuProvider>(
      builder: (context, provider, child) {
        final stats = provider.stats;
        final theme = Theme.of(context);
        
        // Calculate disk usage percentage
        final diskUsagePercent = stats.diskUsagePercentage;
        
        // Determine color based on disk usage
        final Color diskColor = _getDiskUsageColor(diskUsagePercent);
        
        return Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isWide = constraints.maxWidth > 600;
              final bool isTall = constraints.maxHeight > 300;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Colored header based on usage
                  Container(
                    color: diskColor.withOpacity(0.1),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storage_rounded,
                              color: diskColor,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Disk Storage',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${diskUsagePercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: diskColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Main content area
                  Expanded(
                    child: isTall
                        ? _buildDetailedContent(context, stats, diskUsagePercent, diskColor, isWide, constraints)
                        : _buildCompactContent(context, stats, diskUsagePercent, diskColor),
                  ),
                  
                  // Bottom action/status bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Status text
                        Expanded(
                          child: Text(
                            _getShortStatusText(diskUsagePercent),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: diskColor,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Action button
                        if (isTall)
                          TextButton.icon(
                            onPressed: () {
                              // Add disk cleanup action
                            },
                            icon: Icon(
                              Icons.cleaning_services_outlined,
                              size: 16,
                              color: diskColor,
                            ),
                            label: Text(
                              'Details',
                              style: TextStyle(
                                color: diskColor,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
  
  // Detailed content with visualization when we have enough space
  Widget _buildDetailedContent(
    BuildContext context,
    dynamic stats,
    double diskUsagePercent,
    Color diskColor,
    bool isWide,
    BoxConstraints constraints,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Column 1: Chart visualization
          Expanded(
            flex: 3,
            child: _buildDiskChart(context, stats, diskUsagePercent, diskColor),
          ),
          
          const SizedBox(width: 12),
          
          // Column 2: Storage metrics
          Expanded(
            flex: 2,
            child: _buildStorageMetrics(context, stats, diskColor),
          ),
          
          const SizedBox(width: 12),
          
          // Column 3: Storage categories
          Expanded(
            flex: 2,
            child: _buildStorageBreakdown(context, stats),
          ),
        ],
      ),
    );
  }
  
  // Compact content for small spaces
  Widget _buildCompactContent(
    BuildContext context,
    dynamic stats,
    double diskUsagePercent,
    Color diskColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Progress bar for usage
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: diskUsagePercent / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(diskColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 12),
          
          // Storage info in one row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStorageStat('Total', _formatSize(stats.diskTotal.toInt()), AppTheme.warning),
              _buildStorageStat('Used', _formatSize(stats.diskUsed.toInt()), AppTheme.error),
              _buildStorageStat('Free', _formatSize(stats.diskFree.toInt()), AppTheme.success),
            ],
          ),
        ],
      ),
    );
  }
  
  // Chart visualization column
  Widget _buildDiskChart(
    BuildContext context,
    dynamic stats,
    double diskUsagePercent,
    Color diskColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Usage Overview',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: DiskUsagePainter(
                  usagePercent: diskUsagePercent,
                  primaryColor: diskColor,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${diskUsagePercent.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: diskColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Used',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Storage metrics column
  Widget _buildStorageMetrics(
    BuildContext context,
    dynamic stats,
    Color diskColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const Divider(height: 24),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStorageDetail(
                  context,
                  'Total Storage',
                  _formatSize(stats.diskTotal.toInt()),
                  Icons.storage_rounded,
                  AppTheme.warning,
                ),
                
                _buildStorageDetail(
                  context,
                  'Used Space',
                  _formatSize(stats.diskUsed.toInt()),
                  Icons.folder_outlined,
                  AppTheme.error,
                ),
                
                _buildStorageDetail(
                  context,
                  'Free Space',
                  _formatSize(stats.diskFree.toInt()),
                  Icons.check_circle_outline,
                  AppTheme.success,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Storage breakdown column
  Widget _buildStorageBreakdown(
    BuildContext context,
    dynamic stats,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Storage Breakdown',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          const Divider(height: 24),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBreakdownItem(
                  context,
                  'System',
                  _getRandomFilledSize(stats.diskUsed * 0.35).toInt(),
                  AppTheme.info,
                  35,
                ),
                
                _buildBreakdownItem(
                  context,
                  'Applications',
                  _getRandomFilledSize(stats.diskUsed * 0.3).toInt(),
                  AppTheme.warning,
                  30,
                ),
                
                _buildBreakdownItem(
                  context,
                  'User Files',
                  _getRandomFilledSize(stats.diskUsed * 0.35).toInt(),
                  AppTheme.success,
                  35,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Storage detail item for the second column
  Widget _buildStorageDetail(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                maxLines: 1,
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Breakdown item for the third column
  Widget _buildBreakdownItem(
    BuildContext context,
    String label,
    int sizeInMb,
    Color color,
    int percentage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatSize(sizeInMb),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Simple storage stat for compact layout
  Widget _buildStorageStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  // Get a shorter version of status text
  String _getShortStatusText(double usagePercent) {
    if (usagePercent < 70) {
      return 'Storage healthy';
    } else if (usagePercent < 90) {
      return 'Consider freeing up space';
    } else {
      return 'Low disk space';
    }
  }
  
  // Format size from MB to appropriate unit
  String _formatSize(int sizeInMb) {
    if (sizeInMb < 1024) {
      return '$sizeInMb MB';
    } else {
      final sizeInGb = sizeInMb / 1024;
      return '${sizeInGb.toStringAsFixed(1)} GB';
    }
  }
  
  // Get color based on disk usage percentage
  Color _getDiskUsageColor(double usagePercent) {
    if (usagePercent < 70) {
      return AppTheme.success;
    } else if (usagePercent < 90) {
      return AppTheme.warning;
    } else {
      return AppTheme.error;
    }
  }
  
  // Helper to get random filled size (for visual purposes only)
  int _getRandomFilledSize(double baseSizeMb) {
    final random = math.Random();
    final variance = baseSizeMb * 0.1; // 10% variance
    return (baseSizeMb + (random.nextDouble() * variance - variance / 2)).round();
  }
}

// Disk usage custom painter for circular progress
class DiskUsagePainter extends CustomPainter {
  final double usagePercent;
  final Color primaryColor;
  final Color backgroundColor;
  
  DiskUsagePainter({
    required this.usagePercent,
    required this.primaryColor,
    required this.backgroundColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.85; // Slightly smaller to fit text
    final strokeWidth = radius * 0.2;
    final usageAngle = (usagePercent / 100) * 2 * math.pi;
    
    // Draw background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);
    
    // Draw usage arc
    final foregroundPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2, // Start from top
      usageAngle,
      false,
      foregroundPaint,
    );
    
    // Add shading to the disk usage ring
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.1),
        ],
        stops: const [0.0, 0.9],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.9
      ..strokeCap = StrokeCap.round;
      
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      usageAngle,
      false,
      gradientPaint,
    );
  }
  
  @override
  bool shouldRepaint(DiskUsagePainter oldDelegate) {
    return oldDelegate.usagePercent != usagePercent ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
} 