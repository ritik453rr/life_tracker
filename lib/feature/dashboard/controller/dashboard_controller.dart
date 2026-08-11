import 'package:get/get.dart';
import '../model/dashboard_model.dart';
import '../service/dashboard_service.dart';
import '../../../core/language/string_constants.dart';
import '../../task_list/controller/task_list_controller.dart';
import '../../task_list/model/task_list_model.dart';

/// GetX Controller managing state for the Dashboard feature.
class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();

  final Rx<StatSummaryModel?> summary = Rx<StatSummaryModel?>(null);
  final RxList<PeriodStatModel> periodStats = <PeriodStatModel>[].obs;
  final RxList<TaskModel> upcomingTasks = <TaskModel>[].obs;

  /// First interaction date recorded when the user creates their first task.
  final Rx<DateTime?> firstInteractionDate = Rx<DateTime?>(null);

  /// Records the first interaction date when creating a task.
  void recordFirstInteraction([DateTime? date]) {
    firstInteractionDate.value ??= (date ?? DateTime.now());
  }

  /// Formatted tracking since string representing the user's first interaction in the app, or null if no tasks created.
  String? get trackingSinceText {
    if (firstInteractionDate.value == null) {
      return null;
    }
    final date = firstInteractionDate.value!;
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return "${StringConstants.kTrackingSince} ${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    summary.value = await _service.getStatSummary();
    periodStats.assignAll(await _service.getPeriodStats());
    upcomingTasks.assignAll(await _service.getUpcomingTasks());
  }

  /// Syncs task completion state and updates summary stats and period progress percentages.
  void syncTaskCompletion(TaskModel task) {
    final idx = upcomingTasks.indexWhere((t) => t.id == task.id);
    if (idx != -1) {
      upcomingTasks[idx].isCompleted = task.isCompleted;
      upcomingTasks.refresh();
    }

    if (summary.value != null) {
      final oldSum = summary.value!;
      final doneDelta = task.isCompleted ? 1 : -1;
      final maxCount = oldSum.total > 0 ? oldSum.total : 1000;
      final newDone = (oldSum.done + doneDelta).clamp(0, maxCount);
      final newPending = (oldSum.total - newDone).clamp(0, maxCount);
      final newTotal = oldSum.total;
      final newEfficiency = newTotal > 0 ? ((newDone / newTotal) * 100.0) : 0.0;

      summary.value = StatSummaryModel(
        total: newTotal,
        done: newDone,
        pending: newPending,
        expired: oldSum.expired,
        efficiencyPercentage: newEfficiency,
      );

      final roundedPercent = newEfficiency.round();
      for (int i = 0; i < periodStats.length; i++) {
        final stat = periodStats[i];
        final name = stat.periodName.toUpperCase();
        if (name == "TODAY" || name == "WEEK" || name == "MONTH") {
          periodStats[i] = PeriodStatModel(
            periodName: stat.periodName,
            count: stat.count,
            percentage: roundedPercent,
            themeColor: stat.themeColor,
          );
        }
      }
      periodStats.refresh();
    }
  }

  /// Toggles task completion state, skipping completed expired tasks.
  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < upcomingTasks.length) {
      final task = upcomingTasks[index];
      if (task.isCompleted && task.isExpired) return;
      task.isCompleted = !task.isCompleted;
      upcomingTasks[index] = task;
      upcomingTasks.refresh();
      syncTaskCompletion(task);
    }
  }

  /// Checks if [date] falls on the same calendar day as [now].
  bool isSameDay(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Checks if [date] falls in the same calendar week as [now].
  bool isSameWeek(DateTime date, DateTime now) {
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    return !date.isBefore(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Checks if [date] falls in the same calendar month as [now].
  bool isSameMonth(DateTime date, DateTime now) {
    return date.year == now.year && date.month == now.month;
  }

  /// Removes a task from upcoming tasks list and updates stat summary counters and period stats, skipping completed or expired tasks.
  void deleteTask(TaskModel task) {
    if (task.isExpired || task.isCompleted) return;

    upcomingTasks.removeWhere((t) => t.id == task.id);
    upcomingTasks.refresh();

    if (Get.isRegistered<TaskListController>()) {
      final taskListCtrl = Get.find<TaskListController>();
      taskListCtrl.tasks.removeWhere((t) => t.id == task.id);
      taskListCtrl.tasks.refresh();
      if (taskListCtrl.focusSummary.value != null) {
        final count = taskListCtrl.tasks.length;
        taskListCtrl.focusSummary.value = FocusSummaryModel(
          totalTasks: count,
          periodSubtitle: "$count tasks scheduled for this period",
        );
      }
    }

    if (summary.value != null) {
      final oldSum = summary.value!;
      final newTotal = oldSum.total > 0 ? oldSum.total - 1 : 0;
      final newDone = task.isCompleted ? (oldSum.done > 0 ? oldSum.done - 1 : 0) : oldSum.done;
      final newPending = !task.isCompleted ? (oldSum.pending > 0 ? oldSum.pending - 1 : 0) : oldSum.pending;
      final newExpired = task.isExpired ? (oldSum.expired > 0 ? oldSum.expired - 1 : 0) : oldSum.expired;
      final newEfficiency = newTotal > 0 ? ((newDone / newTotal) * 100.0) : 0.0;

      summary.value = StatSummaryModel(
        total: newTotal,
        done: newDone,
        pending: newPending,
        expired: newExpired,
        efficiencyPercentage: newEfficiency,
      );

      final taskDate = task.targetDueDate;
      final now = DateTime.now();
      final inToday = isSameDay(taskDate, now);
      final inWeek = isSameWeek(taskDate, now);
      final inMonth = isSameMonth(taskDate, now);

      final roundedPercent = newEfficiency.round();
      for (int i = 0; i < periodStats.length; i++) {
        final stat = periodStats[i];
        final name = stat.periodName.toUpperCase();
        bool shouldDecrement = false;
        if (name == "TODAY" && inToday) {
          shouldDecrement = true;
        } else if (name == "WEEK" && inWeek) {
          shouldDecrement = true;
        } else if (name == "MONTH" && inMonth) {
          shouldDecrement = true;
        }

        if (name == "TODAY" || name == "WEEK" || name == "MONTH") {
          periodStats[i] = PeriodStatModel(
            periodName: stat.periodName,
            count: shouldDecrement && stat.count > 0 ? stat.count - 1 : stat.count,
            percentage: roundedPercent,
            themeColor: stat.themeColor,
          );
        }
      }
      periodStats.refresh();
    }
  }

  /// Updates stats and upcoming tasks list when an expired task is recreated.
  void onTaskRecreated(TaskModel oldTask, TaskModel newTask) {
    final idx = upcomingTasks.indexWhere((t) => t.id == oldTask.id);
    if (idx != -1) {
      upcomingTasks[idx] = newTask;
    } else {
      upcomingTasks.insert(0, newTask);
    }
    upcomingTasks.refresh();

    if (summary.value != null) {
      final oldSum = summary.value!;
      final newExpired = oldSum.expired > 0 ? oldSum.expired - 1 : 0;
      final newPending = oldSum.pending + 1;
      final newEfficiency = oldSum.total > 0 ? ((oldSum.done / oldSum.total) * 100.0) : 0.0;
      final roundedPercent = newEfficiency.round();

      summary.value = StatSummaryModel(
        total: oldSum.total,
        done: oldSum.done,
        pending: newPending,
        expired: newExpired,
        efficiencyPercentage: newEfficiency,
      );

      final taskDate = newTask.targetDueDate;
      final now = DateTime.now();
      final inToday = isSameDay(taskDate, now);
      final inWeek = isSameWeek(taskDate, now);
      final inMonth = isSameMonth(taskDate, now);

      for (int i = 0; i < periodStats.length; i++) {
        final stat = periodStats[i];
        final name = stat.periodName.toUpperCase();
        if (name == "EXPIRED") {
          periodStats[i] = PeriodStatModel(
            periodName: stat.periodName,
            count: stat.count > 0 ? stat.count - 1 : 0,
            percentage: stat.percentage,
            themeColor: stat.themeColor,
          );
        } else if (name == "TODAY" || name == "WEEK" || name == "MONTH") {
          bool shouldIncrement = false;
          if (name == "TODAY" && inToday) shouldIncrement = true;
          if (name == "WEEK" && inWeek) shouldIncrement = true;
          if (name == "MONTH" && inMonth) shouldIncrement = true;

          periodStats[i] = PeriodStatModel(
            periodName: stat.periodName,
            count: shouldIncrement ? stat.count + 1 : stat.count,
            percentage: roundedPercent,
            themeColor: stat.themeColor,
          );
        }
      }
      periodStats.refresh();
    }
  }
}
