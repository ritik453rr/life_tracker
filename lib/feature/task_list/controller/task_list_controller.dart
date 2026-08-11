import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/language/string_constants.dart';
import '../model/task_list_model.dart';
import '../../dashboard/model/dashboard_model.dart';

import '../../dashboard/controller/dashboard_controller.dart';

/// GetX Controller managing state for the common Task List screen.
class TaskListController extends GetxController {

  /// Observable filter period string (ALL, TODAY, WEEK, MONTH, EXPIRED).
  final RxString currentFilter = StringConstants.kAll.obs;

  /// Observable screen title text matching active filter.
  final RxString screenTitle = StringConstants.kAllTasks.obs;

  /// Observable focus summary metrics.
  final Rx<FocusSummaryModel?> focusSummary = Rx<FocusSummaryModel?>(null);

  /// Observable list of tasks scheduled for the active filter period.
  final RxList<TaskModel> tasks = <TaskModel>[].obs;

  /// Observable search query string.
  final RxString searchQuery = ''.obs;

  /// Text editing controller for search input field.
  final TextEditingController searchFieldController = TextEditingController();

  /// Computed list of tasks filtered by active search query and period filter.
  List<TaskModel> get filteredTasks {
    List<TaskModel> baseList = tasks;
    if (currentFilter.value.toUpperCase() == StringConstants.kExpired) {
      baseList = tasks.where((t) => !t.isCompleted).toList();
    }
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return baseList;
    }
    return baseList.where((task) {
      final titleMatch = task.displayTitle.toLowerCase().contains(query) ||
          task.title.toLowerCase().contains(query);
      final descMatch = task.description?.toLowerCase().contains(query) ?? false;
      final categoryMatch = task.category.toLowerCase().contains(query);
      return titleMatch || descMatch || categoryMatch;
    }).toList();
  }

  /// Updates search query string.
  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  /// Clears active search query and resets text field.
  void clearSearch() {
    searchFieldController.clear();
    searchQuery.value = '';
  }

  @override
  void onClose() {
    searchFieldController.dispose();
    super.onClose();
  }

  /// Initializes controller, extracts route arguments filter, and loads data.
  @override
  void onInit() {
    super.onInit();
    _extractRouteFilter();
    loadTasksData();
  }

  /// Extracts filter argument passed via Get.toNamed arguments map or string.
  void _extractRouteFilter() {
    final args = Get.arguments;
    if (args != null) {
      if (args is Map && args.containsKey('filter')) {
        currentFilter.value = args['filter'].toString();
      } else if (args is String) {
        currentFilter.value = args;
      }
    } else {
      currentFilter.value = StringConstants.kAll;
    }
    _updateScreenTitle();
  }

  /// Updates screen title text according to active filter period.
  void _updateScreenTitle() {
    final upper = currentFilter.value.toUpperCase();
    if (upper == StringConstants.kWeek) {
      screenTitle.value = StringConstants.kThisWeeksTasks;
    } else if (upper == StringConstants.kMonth) {
      screenTitle.value = StringConstants.kThisMonthsTasks;
    } else if (upper == StringConstants.kExpired) {
      screenTitle.value = StringConstants.kExpiredTasks;
    } else if (upper == StringConstants.kToday) {
      screenTitle.value = StringConstants.kTodaysTasks;
    } else {
      screenTitle.value = StringConstants.kAllTasks;
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

  /// Loads focus summary and task list from DashboardController or TaskListService using active filter.
  Future<void> loadTasksData() async {
    List<TaskModel> sourceList = [];
    if (Get.isRegistered<DashboardController>()) {
      sourceList = Get.find<DashboardController>().upcomingTasks.toList();
    }

    final upper = currentFilter.value.toUpperCase();
    final now = DateTime.now();

    List<TaskModel> filtered = [];
    if (upper == StringConstants.kToday) {
      filtered = sourceList.where((t) => isSameDay(t.targetDueDate, now)).toList();
    } else if (upper == StringConstants.kWeek) {
      filtered = sourceList.where((t) => isSameWeek(t.targetDueDate, now)).toList();
    } else if (upper == StringConstants.kMonth) {
      filtered = sourceList.where((t) => isSameMonth(t.targetDueDate, now)).toList();
    } else if (upper == StringConstants.kExpired) {
      filtered = sourceList.where((t) => t.isExpired && !t.isCompleted).toList();
    } else {
      filtered = List.from(sourceList);
    }

    tasks.assignAll(filtered);

    final taskCount = tasks.length;
    if (upper == StringConstants.kExpired) {
      focusSummary.value = FocusSummaryModel(
        totalTasks: taskCount,
        periodSubtitle: "$taskCount ${StringConstants.kTasksExpiredPendingReview}",
      );
    } else {
      focusSummary.value = FocusSummaryModel(
        totalTasks: taskCount,
        periodSubtitle: "$taskCount ${StringConstants.kTasksScheduledForPeriod}",
      );
    }
  }

  /// Toggles task completion state for the given [task], skipping completed expired tasks.
  void toggleTaskCompletion(TaskModel task) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      if (tasks[index].isCompleted && tasks[index].isExpired) return;
      tasks[index].isCompleted = !tasks[index].isCompleted;
      tasks.refresh();
      if (currentFilter.value.toUpperCase() == StringConstants.kExpired && focusSummary.value != null) {
        final uncompletedCount = tasks.where((t) => !t.isCompleted).length;
        focusSummary.value = FocusSummaryModel(
          totalTasks: uncompletedCount,
          periodSubtitle: "$uncompletedCount ${StringConstants.kTasksExpiredPendingReview}",
        );
      }
      if (Get.isRegistered<DashboardController>()) {
        Get.find<DashboardController>().syncTaskCompletion(tasks[index]);
      }
    }
  }

  /// Removes task from tasks list and syncs with DashboardController if present, skipping completed or expired tasks.
  void deleteTask(TaskModel task) {
    if (task.isExpired || task.isCompleted) return;
    tasks.removeWhere((t) => t.id == task.id);
    tasks.refresh();
    if (focusSummary.value != null) {
      final count = tasks.length;
      focusSummary.value = FocusSummaryModel(
        totalTasks: count,
        periodSubtitle: "$count ${StringConstants.kTasksScheduledForPeriod}",
      );
    }
    if (Get.isRegistered<DashboardController>()) {
      Get.find<DashboardController>().deleteTask(task);
    }
  }

  /// Removes or updates task in active list when an expired task is recreated.
  void onTaskRecreated(TaskModel oldTask, TaskModel newTask) {
    if (currentFilter.value.toUpperCase() == StringConstants.kExpired) {
      tasks.removeWhere((t) => t.id == oldTask.id);
      tasks.refresh();
      if (focusSummary.value != null) {
        final oldSum = focusSummary.value!;
        final newCount = oldSum.totalTasks > 0 ? oldSum.totalTasks - 1 : 0;
        focusSummary.value = FocusSummaryModel(
          totalTasks: newCount,
          periodSubtitle: "$newCount ${StringConstants.kTasksExpiredPendingReview}",
        );
      }
    } else {
      final idx = tasks.indexWhere((t) => t.id == oldTask.id);
      if (idx != -1) {
        tasks[idx] = newTask;
      } else {
        tasks.insert(0, newTask);
      }
      tasks.refresh();
    }
  }
}
