import 'package:flutter/material.dart';
import '../model/dashboard_model.dart';

/// Service class providing dashboard data.
class DashboardService {
  /// Fetch statistical summary data.
  Future<StatSummaryModel> getStatSummary() async {
    return StatSummaryModel(
      total: 150,
      done: 120,
      pending: 30,
      expired: 15,
      efficiencyPercentage: 80.0,
    );
  }

  /// Fetch period stat cards data.
  Future<List<PeriodStatModel>> getPeriodStats() async {
    return [
      PeriodStatModel(
        periodName: "TODAY",
        count: 12,
        percentage: 80,
        themeColor: const Color(0xFF0066CC),
      ),
      PeriodStatModel(
        periodName: "WEEK",
        count: 48,
        percentage: 45,
        themeColor: const Color(0xFF0F9D58),
      ),
      PeriodStatModel(
        periodName: "MONTH",
        count: 184,
        percentage: 30,
        themeColor: const Color(0xFF9E6D00),
      ),
      PeriodStatModel(
        periodName: "EXPIRED",
        count: 15,
        percentage: null,
        themeColor: const Color(0xFFD32F2F),
      ),
    ];
  }

  /// Fetch upcoming tasks.
  Future<List<TaskModel>> getUpcomingTasks() async {
    return [
      TaskModel(
        id: "1",
        title: "Morning Yoga",
        category: "HEALTH",
        date: "25 July 2026",
        timeLeft: "2H LEFT",
        categoryColor: const Color(0xFF0066CC),
        isCompleted: false,
      ),
      TaskModel(
        id: "2",
        title: "Project Review",
        category: "WORK",
        date: "25 July 2026",
        timeLeft: null,
        categoryColor: const Color(0xFF0F9D58),
        isCompleted: true,
      ),
      TaskModel(
        id: "3",
        title: "Deep Work Session",
        category: "WORK",
        date: "25 July 2026",
        timeLeft: null,
        categoryColor: const Color(0xFF9E6D00),
        isCompleted: false,
      ),
    ];
  }
}
