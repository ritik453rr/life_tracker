import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/common_widgets/app_checkbox.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../model/dashboard_model.dart';

/// Task item card widget displaying task details, completion toggle, and optional slide-to-delete.
class TaskItemCard extends StatelessWidget {
  /// The task model containing title, category, date, and completion status.
  final TaskModel task;

  /// Callback function triggered when the user toggles completion status.
  final VoidCallback onToggle;

  /// Optional callback function triggered when tapping the card to edit task.
  final VoidCallback? onTap;

  /// Optional callback function triggered when sliding to delete the task.
  final VoidCallback? onDelete;

  /// Creates a [TaskItemCard] with [task] details, [onToggle], optional [onTap], and optional [onDelete] handler.
  const TaskItemCard({
    super.key,
    required this.task,
    required this.onToggle,
    this.onTap,
    this.onDelete,
  });

  Widget _buildCard({EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 16.0)}) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Accent Strip
              Container(
                width: 5,
                color: task.categoryColor,
              ),
              // Card Details & Action Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 14.0,
                  ),
                  child: Row(
                    children: [
                      // Information Side
                      Expanded(
                        child: GestureDetector(
                          onTap: onTap,
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Tag
                              Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: task.categoryColor,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              4.h,
                              // Task Title
                              Text(
                                task.displayTitle,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: task.isCompleted
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF0F172A),
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: const Color(0xFF94A3B8),
                                ),
                              ),
                              10.h,
                              // Date & Time Left Row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 13,
                                    color: Color(0xFF94A3B8),
                                  ),
                                  5.w,
                                  Text(
                                    task.date,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  12.w,
                                  Visibility(
                                    visible: !task.isCompleted,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: _RealTimeBadge(task: task),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Checkbox Button (Shown if NOT expired, or if completed)
                      if (!task.isExpired || task.isCompleted) ...[
                        12.w,
                        AppCheckbox(
                          isChecked: task.isCompleted,
                          onTap: (task.isCompleted && task.isExpired) ? null : onToggle,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the task item card with category accent strip, details, and optional slide-to-delete wrapper.
  @override
  Widget build(BuildContext context) {
    if (onDelete == null || task.isExpired || task.isCompleted) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildCard(),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          extentRatio: 0.25,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0, left: 6.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        2.h,
                        const Text(
                          StringConstants.kDelete,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
        child: _buildCard(),
      ),
    );
  }
}

/// Stateful widget rendering a real-time ticking badge for remaining task time.
class _RealTimeBadge extends StatefulWidget {
  /// The task model whose remaining time is displayed.
  final TaskModel task;

  /// Creates a [_RealTimeBadge] instance with required [task].
  const _RealTimeBadge({required this.task});

  @override
  State<_RealTimeBadge> createState() => _RealTimeBadgeState();
}

/// State class managing 1-second periodic timer for [_RealTimeBadge].
class _RealTimeBadgeState extends State<_RealTimeBadge> {
  Timer? _timer;

  /// Starts periodic timer on initialization.
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// Schedules 1-second periodic timer to refresh remaining time badge.
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  /// Cancels periodic timer when unmounted.
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Builds remaining time badge with dynamic text and background color.
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final remainingText = widget.task.getRealTimeRemaining(now);
    final badgeColor = widget.task.getRealTimeBadgeColor(now);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 12,
            color: Colors.white,
          ),
          4.w,
          Text(
            remainingText,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
