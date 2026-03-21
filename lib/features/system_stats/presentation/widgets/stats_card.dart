import 'package:flutter/material.dart';
import 'package:vaxmanegr/core/constants/app_colors.dart';
import 'dart:ui' as ui;
import 'glass_card.dart';

class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;
  final Widget? child; // New parameter for dynamic content
  final List<double> dataPoints; // Data points for chart

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
    this.child, // Initialize the new parameter
    this.dataPoints = const [], // Initialize chart data
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderColor: color,
      child: Stack(
        children: [
          // Chart in background
          if (dataPoints.isNotEmpty)
            Positioned.fill(
              top: 60,
              child: CustomPaint(
                painter: _ChartPainter(
                  data: dataPoints,
                  color: color,
                ),
              ),
            ),
          // Text content in foreground
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (child != null) // Render dynamic content if provided
                  child!
                else
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  unit,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Chart painter for rendering the graph
class _ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _ChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double stepX = size.width / (data.length - 1);

    double maxValue = data.reduce((curr, next) => curr > next ? curr : next);
    if (maxValue == 0) maxValue = 1;

    final double graphHeight = size.height * 0.8;
    final double topMargin = size.height * 0.2;

    path.moveTo(0, topMargin + graphHeight * (1 - (data[0] / maxValue)));

    for (int i = 0; i < data.length - 1; i++) {
      final x1 = i * stepX;
      final y1 = topMargin + graphHeight * (1 - (data[i] / maxValue));
      final x2 = (i + 1) * stepX;
      final y2 = topMargin + graphHeight * (1 - (data[i + 1] / maxValue));

      final controlX = (x1 + x2) / 2;
      path.cubicTo(controlX, y1, controlX, y2, x2, y2);
    }

    // Glow effect
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Main line
    canvas.drawPath(path, paint);

    // Gradient fill
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.height),
      [
        color.withValues(alpha: 0.25),
        color.withValues(alpha: 0.0),
      ],
    );

    canvas.drawPath(
      fillPath,
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
