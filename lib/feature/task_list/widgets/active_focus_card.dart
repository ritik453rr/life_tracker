import 'package:flutter/material.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../model/task_list_model.dart';

/// Gradient banner card displaying active focus task count and period subtitle.
class ActiveFocusCard extends StatelessWidget {
  /// Summary model holding total tasks count and period subtitle.
  final FocusSummaryModel summary;

  /// Creates an [ActiveFocusCard] with the given [summary] metrics.
  const ActiveFocusCard({
    super.key,
    required this.summary,
  });

  /// Builds the active focus layout.
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 22.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0044B3),
            Color(0xFF1D61E0),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D61E0).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Text Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                StringConstants.kActiveFocus,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF93C5FD),
                  letterSpacing: 0.8,
                ),
              ),
              6.h,
              Text(
                "${summary.totalTasks} ${StringConstants.kTasks}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              4.h,
              Text(
                summary.periodSubtitle,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFDBEAFE),
                ),
              ),
            ],
          ),
          // Right Circular Icon Badge
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.22),
            ),
            child: const Icon(
              Icons.checklist_rtl_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
