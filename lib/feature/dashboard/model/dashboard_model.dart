import 'package:flutter/material.dart';
import '../../../core/language/string_constants.dart';

/// Task item model representing a task across the application.
class TaskModel {
  /// Unique identifier for the task.
  final String id;

  /// Title description of the task.
  final String title;

  /// Category tag string (e.g. WORK, HEALTH, PERSONAL).
  final String category;

  /// Formatted date string of the task.
  final String date;

  /// Optional target due date for real-time countdown calculation.
  final DateTime? dueDate;

  /// Optional description notes for the task.
  final String? description;

  /// Optional time remaining or status badge text (e.g. "2H LEFT", "EXPIRED").
  final String? timeLeft;

  /// Accent color associated with the task category.
  final Color categoryColor;

  /// Color used for status badge tags.
  final Color badgeColor;

  /// Boolean state indicating if the task has been marked completed.
  bool isCompleted;

  /// Creates a [TaskModel] instance with required details.
  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.dueDate,
    this.description,
    this.timeLeft,
    required this.categoryColor,
    this.badgeColor = const Color(0xFF0066CC),
    this.isCompleted = false,
  });

  /// Getter returning display title: user title if present, otherwise excerpt from description, or fallback untitled.
  String get displayTitle {
    if (title.trim().isNotEmpty) return title.trim();
    if (description != null && description!.trim().isNotEmpty) {
      final firstLine = description!.trim().split('\n').first.trim();
      return firstLine.length > 35 ? "${firstLine.substring(0, 35)}..." : firstLine;
    }
    return StringConstants.kUntitledTask;
  }

  /// Calculates target due date, falling back to parsed date string at end of day.
  DateTime get targetDueDate {
    if (dueDate != null) return dueDate!;
    try {
      final parts = date.trim().split(' ');
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.tryParse(parts[2]);
        final months = [
          'jan', 'feb', 'mar', 'apr', 'may', 'jun',
          'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
        ];
        int month = 1;
        for (int i = 0; i < months.length; i++) {
          if (monthStr.startsWith(months[i])) {
            month = i + 1;
            break;
          }
        }
        if (day != null && year != null) {
          return DateTime(year, month, day, 23, 59, 59);
        }
      }
    } catch (_) {}
    return DateTime.now().add(const Duration(hours: 2));
  }

  /// Calculates real-time remaining duration formatted string.
  String getRealTimeRemaining(DateTime now) {
    if (timeLeft?.toUpperCase() == StringConstants.kExpired) return StringConstants.kExpired;
    final target = targetDueDate;
    final diff = target.difference(now);
    if (diff.isNegative) return StringConstants.kExpired;
    if (diff.inDays > 0) {
      return "${diff.inDays}D ${diff.inHours % 24}${StringConstants.kHoursLeft}";
    } else if (diff.inHours > 0) {
      return "${diff.inHours}H ${diff.inMinutes % 60}${StringConstants.kMinutesLeft}";
    } else if (diff.inMinutes > 0) {
      return "${diff.inMinutes}M ${diff.inSeconds % 60}${StringConstants.kSecondsLeft}";
    } else {
      return "${diff.inSeconds} ${StringConstants.kSecondsLeft}";
    }
  }

  /// Calculates badge color based on real-time remaining duration.
  Color getRealTimeBadgeColor(DateTime now) {
    if (timeLeft?.toUpperCase() == "EXPIRED") return const Color(0xFFEF4444);
    final target = targetDueDate;
    final diff = target.difference(now);
    if (diff.isNegative || diff.inHours < 1) return const Color(0xFFEF4444);
    if (diff.inHours < 3) return const Color(0xFFF97316);
    if (diff.inHours < 6) return const Color(0xFFF59E0B);
    if (diff.inHours < 24) return const Color(0xFF0066CC);
    return const Color(0xFF0F9D58);
  }

  /// Helper getter returning true if the task deadline is past or marked expired.
  bool get isExpired {
    if (timeLeft?.toUpperCase() == "EXPIRED") return true;
    return DateTime.now().isAfter(targetDueDate);
  }
}

/// Overall stats summary model.
class StatSummaryModel {
  /// Total task count.
  final int total;

  /// Completed task count.
  final int done;

  /// Pending task count.
  final int pending;

  /// Expired task count.
  final int expired;

  /// Overall efficiency percentage.
  final double efficiencyPercentage;

  /// Creates a [StatSummaryModel] instance.
  StatSummaryModel({
    required this.total,
    required this.done,
    required this.pending,
    required this.expired,
    required this.efficiencyPercentage,
  });
}

/// Period-specific stat model (Today, Week, Month, Expired).
class PeriodStatModel {
  /// Name of the period (e.g. TODAY, WEEK, MONTH, EXPIRED).
  final String periodName;

  /// Task count for this period.
  final int count;

  /// Optional percentage completion score.
  final int? percentage;

  /// Accent color associated with the period card.
  final Color themeColor;

  /// Creates a [PeriodStatModel] instance.
  PeriodStatModel({
    required this.periodName,
    required this.count,
    this.percentage,
    required this.themeColor,
  });
}
