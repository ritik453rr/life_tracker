import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../model/dashboard_model.dart';

/// Card displaying animated yearly progress donut chart and summary statistics.
class YearlyProgressCard extends StatelessWidget {
  /// The summary model holding statistical values.
  final StatSummaryModel summary;

  /// Creates a [YearlyProgressCard] with the given [summary] statistics.
  const YearlyProgressCard({
    super.key,
    required this.summary,
  });

  /// Builds the main layout card containing animated circular progress and static count statistics.
  @override
  Widget build(BuildContext context) {
    final targetPercentage = (summary.efficiencyPercentage / 100).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            StringConstants.kYearlyProgress,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF334155),
            ),
          ),
          20.h,
          // Animated Donut Ring Indicator starting strictly from 0 with 2-second smooth curve
          _AnimatedDonutRing(targetPercentage: targetPercentage),
          28.h,
          // Bottom Stats Row with Static Number Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem("${summary.total}", StringConstants.kTotal, const Color(0xFF0F172A)),
              _buildVerticalDivider(),
              _buildStatItem("${summary.done}", StringConstants.kDone, const Color(0xFF10B981)),
              _buildVerticalDivider(),
              _buildStatItem("${summary.pending}", StringConstants.kPending, const Color(0xFF9E6D00)),
              _buildVerticalDivider(),
              _buildStatItem("${summary.expired}", StringConstants.kExpired, const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a static statistic column with value and label.
  Widget _buildStatItem(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        4.h,
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Builds a thin vertical divider between statistic items.
  Widget _buildVerticalDivider() {
    return Container(
      height: 32,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}

/// Stateful donut ring widget that always animates starting strictly from 0.0 to [targetPercentage].
class _AnimatedDonutRing extends StatefulWidget {
  /// Target progress percentage between 0.0 and 1.0.
  final double targetPercentage;

  /// Creates an [_AnimatedDonutRing] with the given [targetPercentage].
  const _AnimatedDonutRing({
    required this.targetPercentage,
  });

  @override
  State<_AnimatedDonutRing> createState() => _AnimatedDonutRingState();
}

/// State managing animation controller for [_AnimatedDonutRing].
class _AnimatedDonutRingState extends State<_AnimatedDonutRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Calculates the progress color smoothly interpolating between Red (0%) -> Amber (50%) -> Green (100%).
  Color _getProgressColor(double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    if (clamped <= 0.5) {
      return Color.lerp(
        const Color(0xFFEF4444), // Red
        const Color(0xFFF59E0B), // Amber
        clamped * 2,
      )!;
    } else {
      return Color.lerp(
        const Color(0xFFF59E0B), // Amber
        const Color(0xFF10B981), // Green
        (clamped - 0.5) * 2,
      )!;
    }
  }

  /// Initializes animation controller over 600ms starting from 0.0 to target percentage.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.targetPercentage,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));
    _controller.forward();
  }

  /// Animates smoothly from current progress to new target percentage when widget updates.
  @override
  void didUpdateWidget(covariant _AnimatedDonutRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetPercentage != widget.targetPercentage) {
      final current = _animation.value;
      _animation = Tween<double>(
        begin: current,
        end: widget.targetPercentage,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutCubic,
      ));
      _controller.forward(from: 0.0);
    }
  }

  /// Disposes the animation controller when unmounted.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the animated donut ring widget using current interpolated progress.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentProgress = _animation.value.clamp(0.0, 1.0);
        final animatedPercentInt = (currentProgress * 100).round();
        final currentColor = _getProgressColor(currentProgress);

        return SizedBox(
          width: 170,
          height: 170,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(170, 170),
                painter: _DonutChartPainter(
                  percentage: currentProgress,
                  activeColor: currentColor,
                  backgroundColor: currentColor.withValues(alpha: 0.15),
                  strokeWidth: 16,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$animatedPercentInt%",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: currentColor,
                      height: 1.0,
                    ),
                  ),
                  4.h,
                  Text(
                    StringConstants.kEfficiency,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: currentColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for drawing the circular progress donut chart with anti-aliasing.
class _DonutChartPainter extends CustomPainter {
  /// Progress percentage value between 0.0 and 1.0.
  final double percentage;

  /// Active stroke color for the progress arc.
  final Color activeColor;

  /// Track background color.
  final Color backgroundColor;

  /// Width of the circular stroke line.
  final double strokeWidth;

  /// Creates a [_DonutChartPainter] with progress properties.
  _DonutChartPainter({
    required this.percentage,
    required this.activeColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  /// Paints the background track and animated progress arc smoothly on canvas.
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background track with anti-aliasing
    final bgPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, bgPaint);

    if (percentage <= 0.0) return;

    // Active progress arc with smooth anti-aliasing
    final activePaint = Paint()
      ..color = activeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeCap = StrokeCap.round;

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * percentage.clamp(0.0, 1.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  /// Determines if the chart painter needs to repaint when properties change.
  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
