import 'package:flutter/material.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? valueColor;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Safely parse percentage for display
    final percentage = _parsePercentage(value);
    final displayPercentage = percentage.isNaN || percentage.isInfinite 
        ? "--" 
        : "${percentage.round()}%";

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: (valueColor ?? theme.colorScheme.primary).withAlpha(0.15 * 255 ~/ 1),
          width: 0.8,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              isDarkMode ? theme.cardColor : theme.cardColor.withAlpha(0.97 * 255 ~/ 1),
              isDarkMode ? theme.cardColor.withAlpha(0.85 * 255 ~/ 1) : Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: (valueColor ?? theme.colorScheme.primary).withAlpha(0.15 * 255 ~/ 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: valueColor ?? theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.textTheme.titleMedium?.color?.withAlpha(0.7 * 255 ~/ 1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: valueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Compact circular progress indicator
              SizedBox(
                height: 40,
                width: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      painter: _CircularProgressPainter(
                        valueColor: valueColor ?? theme.colorScheme.primary,
                        value: percentage.isNaN || percentage.isInfinite ? 0.0 : percentage,
                        strokeWidth: 2.8,
                      ),
                      size: const Size(38, 38),
                    ),
                    Text(
                      displayPercentage,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _parsePercentage(String value) {
    // Extract percentage from value string
    if (value.contains('%')) {
      try {
        return double.parse(value.replaceAll('%', '').trim());
      } catch (e) {
        return 0.0;
      }
    } else if (value.contains('/')) {
      // For memory format like "4.0GB / 16.0GB"
      try {
        final parts = value.split('/');
        final used = double.parse(parts[0].replaceAll(RegExp(r'[^0-9.]'), ''));
        final total = double.parse(parts[1].replaceAll(RegExp(r'[^0-9.]'), ''));
        return total > 0 ? (used / total) * 100 : 0.0; // Prevent division by zero
      } catch (e) {
        return 0.0;
      }
    } else if (value.contains('°C')) {
      // For temperature, assume 80°C is 100%
      try {
        final temp = double.parse(value.replaceAll('°C', '').trim());
        return (temp / 80) * 100;
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

class _CircularProgressPainter extends CustomPainter {
  final Color valueColor;
  final double value; // 0 to 100
  final double strokeWidth;

  _CircularProgressPainter({
    required this.valueColor,
    required this.value,
    this.strokeWidth = 3.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = valueColor.withAlpha(0.15 * 255 ~/ 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
      
    canvas.drawCircle(center, radius - (strokeWidth / 2), backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
      
    // Make sure we have a valid value between 0 and 100
    final safeValue = value.clamp(0.0, 100.0);
    final progressAngle = 2 * 3.14159 * (safeValue / 100);
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - (strokeWidth / 2)),
      -3.14159 / 2, // Start from top
      progressAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value || 
           oldDelegate.valueColor != valueColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}