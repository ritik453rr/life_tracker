import 'package:flutter/material.dart';
import '../model/dashboard_model.dart';

/// Service class providing dashboard data.
class DashboardService {
  /// Fetch statistical summary data.
  Future<StatSummaryModel> getStatSummary() async {
    return StatSummaryModel(
      total: 0,
      done: 0,
      pending: 0,
      expired: 0,
      efficiencyPercentage: 0.0,
    );
  }

  /// Fetch period stat cards data.
  Future<List<PeriodStatModel>> getPeriodStats() async {
    return [
      PeriodStatModel(
        periodName: "TODAY",
        count: 0,
        percentage: 0,
        themeColor: const Color(0xFF0066CC),
      ),
      PeriodStatModel(
        periodName: "WEEK",
        count: 0,
        percentage: 0,
        themeColor: const Color(0xFF0F9D58),
      ),
      PeriodStatModel(
        periodName: "MONTH",
        count: 0,
        percentage: 0,
        themeColor: const Color(0xFF9E6D00),
      ),
      PeriodStatModel(
        periodName: "EXPIRED",
        count: 0,
        percentage: null,
        themeColor: const Color(0xFFD32F2F),
      ),
    ];
  }

  /// Fetch upcoming tasks.
  Future<List<TaskModel>> getUpcomingTasks() async {
    return [];
  }
}
