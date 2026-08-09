import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../model/dashboard_model.dart';

/// Card widget representing periodic statistics (Today, Week, Month, Expired).
class PeriodStatCard extends StatelessWidget {
  /// The period statistical model holding counts and colors.
  final PeriodStatModel stat;

  /// Creates a [PeriodStatCard] displaying the given [stat] data.
  const PeriodStatCard({
    super.key,
    required this.stat,
  });

  /// Builds the period stat card layout with static count and animated circular percentage badge.
  @override
  Widget build(BuildContext context) {
    final bool isExpired = stat.periodName == StringConstants.kExpired;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Content: Period Title and Static Count Display
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stat.periodName,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              6.h,
              Text(
                "${stat.count}",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: isExpired
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          // Right Content: Animated Small Circular Percentage Badge starting strictly from 0 over 2 seconds
          if (stat.percentage != null)
            _AnimatedSmallBadgeRing(
              targetPercentage: (stat.percentage! / 100).clamp(0.0, 1.0),
            ),
        ],
      ),
    );
  }
}

/// Stateful small badge ring widget that always animates starting strictly from 0.0 to [targetPercentage].
class _AnimatedSmallBadgeRing extends StatefulWidget {
  /// Target percentage between 0.0 and 1.0.
  final double targetPercentage;

  /// Creates an [_AnimatedSmallBadgeRing] with [targetPercentage].
  const _AnimatedSmallBadgeRing({
    required this.targetPercentage,
  });

  @override
  State<_AnimatedSmallBadgeRing> createState() => _AnimatedSmallBadgeRingState();
}

/// State managing animation controller for [_AnimatedSmallBadgeRing].
class _AnimatedSmallBadgeRingState extends State<_AnimatedSmallBadgeRing>
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

  /// Initializes animation controller starting strictly from 0.0 over 2 seconds.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward(from: 0.0);
  }

  /// Restarts animation from 0.0 if target percentage updates.
  @override
  void didUpdateWidget(covariant _AnimatedSmallBadgeRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetPercentage != widget.targetPercentage) {
      _controller.forward(from: 0.0);
    }
  }

  /// Disposes the animation controller when unmounted.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the animated small circular badge widget.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentProgress = _animation.value * widget.targetPercentage;
        final animatedPercentInt = (currentProgress * 100).round();
        final badgeColor = _getProgressColor(currentProgress);

        return SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(44, 44),
                painter: _SmallBadgePainter(
                  percentage: currentProgress,
                  color: badgeColor,
                  strokeWidth: 3.5,
                ),
              ),
              Text(
                "$animatedPercentInt%",
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: badgeColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter for rendering small circular badge progress arcs with anti-aliasing.
class _SmallBadgePainter extends CustomPainter {
  /// Progress percentage between 0.0 and 1.0.
  final double percentage;

  /// Theme accent color for the progress ring.
  final Color color;

  /// Width of the circular stroke line.
  final double strokeWidth;

  /// Creates a [_SmallBadgePainter] with given progress parameters.
  _SmallBadgePainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
  });

  /// Paints the background ring and animated progress arc smoothly on canvas.
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle with anti-aliasing
    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, bgPaint);

    if (percentage <= 0.0) return;

    // Active arc with anti-aliasing
    final activePaint = Paint()
      ..color = color
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

  /// Determines whether to repaint when painter properties change.
  @override
  bool shouldRepaint(covariant _SmallBadgePainter oldDelegate) {
    return oldDelegate.percentage != percentage || oldDelegate.color != color;
  }
}
