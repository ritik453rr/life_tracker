import 'package:flutter/material.dart';
import '../../../core/language/string_constants.dart';
import '../model/task_list_model.dart';
import '../../dashboard/model/dashboard_model.dart';

/// Feature service providing task list and focus summary data filtered by period.
class TaskListService {
  /// Fetches focus summary metrics corresponding to the specified [filter] period.
  Future<FocusSummaryModel> getFocusSummaryByPeriod(String filter) async {
    final upperFilter = filter.toUpperCase();
    if (upperFilter == StringConstants.kWeek) {
      return FocusSummaryModel(
        totalTasks: 48,
        periodSubtitle: "32 tasks scheduled for this week",
      );
    } else if (upperFilter == StringConstants.kMonth) {
      return FocusSummaryModel(
        totalTasks: 184,
        periodSubtitle: "120 tasks scheduled for this month",
      );
    } else if (upperFilter == StringConstants.kExpired) {
      return FocusSummaryModel(
        totalTasks: 15,
        periodSubtitle: "15 tasks expired and pending review",
      );
    } else if (upperFilter == StringConstants.kToday) {
      return FocusSummaryModel(
        totalTasks: 12,
        periodSubtitle: StringConstants.kScheduledForPeriod,
      );
    }
    // Default to ALL
    return FocusSummaryModel(
      totalTasks: 259,
      periodSubtitle: "All 259 tasks scheduled across all periods",
    );
  }

  /// Fetches task models corresponding to the specified [filter] period.
  Future<List<TaskModel>> getTasksByPeriod(String filter) async {
    final upperFilter = filter.toUpperCase();

    final todayTasks = [
      TaskModel(
        id: "t1",
        title: "Q3 Strategy Alignment",
        category: "WORK",
        date: "25 July 2026",
        categoryColor: const Color(0xFF0066CC),
        isCompleted: false,
      ),
      TaskModel(
        id: "t2",
        title: "45min Morning Flow",
        category: "HEALTH",
        date: "25 July 2026",
        categoryColor: const Color(0xFF0F9D58),
        isCompleted: false,
      ),
      TaskModel(
        id: "t3",
        title: "Grocery Restock",
        category: "PERSONAL",
        date: "25 July 2026",
        categoryColor: const Color(0xFF9E6D00),
        isCompleted: false,
      ),
      TaskModel(
        id: "t4",
        title: "Project Launch Review",
        category: "WORK",
        date: "25 July 2026",
        categoryColor: const Color(0xFF0066CC),
        isCompleted: false,
      ),
    ];

    final weekTasks = [
      TaskModel(
        id: "w1",
        title: "Sprint Planning",
        category: "WORK",
        date: "26 July 2026",
        categoryColor: const Color(0xFF0066CC),
        isCompleted: false,
      ),
      TaskModel(
        id: "w2",
        title: "Team Sync & Catchup",
        category: "WORK",
        date: "27 July 2026",
        categoryColor: const Color(0xFF0066CC),
        isCompleted: false,
      ),
      TaskModel(
        id: "w3",
        title: "Weekly Cardio Workout",
        category: "HEALTH",
        date: "28 July 2026",
        categoryColor: const Color(0xFF0F9D58),
        isCompleted: false,
      ),
      TaskModel(
        id: "w4",
        title: "Family Dinner",
        category: "PERSONAL",
        date: "29 July 2026",
        categoryColor: const Color(0xFF9E6D00),
        isCompleted: false,
      ),
    ];

    final monthTasks = [
      TaskModel(
        id: "m1",
        title: "Monthly Budget Audit",
        category: "PERSONAL",
        date: "01 August 2026",
        categoryColor: const Color(0xFF9E6D00),
        isCompleted: false,
      ),
      TaskModel(
        id: "m2",
        title: "Architecture Refactoring",
        category: "WORK",
        date: "05 August 2026",
        categoryColor: const Color(0xFF0066CC),
        isCompleted: false,
      ),
      TaskModel(
        id: "m3",
        title: "Health Checkup",
        category: "HEALTH",
        date: "12 August 2026",
        categoryColor: const Color(0xFF0F9D58),
        isCompleted: false,
      ),
    ];

    final expiredTasks = [
      TaskModel(
        id: "e1",
        title: "Quarterly Tax Filing",
        category: "WORK",
        date: "15 July 2026",
        categoryColor: const Color(0xFFEF4444),
        badgeColor: const Color(0xFFEF4444),
        timeLeft: "EXPIRED",
        isCompleted: false,
      ),
      TaskModel(
        id: "e2",
        title: "Dentist Appointment",
        category: "HEALTH",
        date: "18 July 2026",
        categoryColor: const Color(0xFFEF4444),
        badgeColor: const Color(0xFFEF4444),
        timeLeft: "EXPIRED",
        isCompleted: false,
      ),
    ];

    if (upperFilter == StringConstants.kWeek) {
      return weekTasks;
    } else if (upperFilter == StringConstants.kMonth) {
      return monthTasks;
    } else if (upperFilter == StringConstants.kExpired) {
      return expiredTasks;
    } else if (upperFilter == StringConstants.kToday) {
      return todayTasks;
    }

    // Default to ALL
    return [...todayTasks, ...weekTasks, ...monthTasks, ...expiredTasks];
  }
}
