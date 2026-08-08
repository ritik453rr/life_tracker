import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/language/string_constants.dart';
import '../model/task_list_model.dart';
import '../service/task_list_service.dart';
import '../../dashboard/model/dashboard_model.dart';

/// GetX Controller managing state for the common Task List screen.
class TaskListController extends GetxController {
  final TaskListService _service = TaskListService();

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

  /// Computed list of tasks filtered by active search query.
  List<TaskModel> get filteredTasks {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return tasks;
    }
    return tasks.where((task) {
      final titleMatch = task.title.toLowerCase().contains(query);
      final categoryMatch = task.category.toLowerCase().contains(query);
      return titleMatch || categoryMatch;
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

  /// Loads focus summary and task list from task list service using active filter.
  Future<void> loadTasksData() async {
    focusSummary.value = await _service.getFocusSummaryByPeriod(currentFilter.value);
    tasks.assignAll(await _service.getTasksByPeriod(currentFilter.value));
  }

  /// Toggles task completion state for the given [task].
  void toggleTaskCompletion(TaskModel task) {
    final index = tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      tasks[index].isCompleted = !tasks[index].isCompleted;
      tasks.refresh();
    }
  }
}
