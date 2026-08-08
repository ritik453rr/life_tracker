import 'package:flutter/material.dart';

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
    this.description,
    this.timeLeft,
    required this.categoryColor,
    this.badgeColor = const Color(0xFF0066CC),
    this.isCompleted = false,
  });

  /// Helper getter returning true if the task is marked as expired.
  bool get isExpired => timeLeft?.toUpperCase() == "EXPIRED";
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
