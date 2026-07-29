import 'package:get/get.dart';
import '../../../core/language/string_constants.dart';
import '../model/task_list_model.dart';
import '../service/task_list_service.dart';
import '../../dashboard/model/dashboard_model.dart';

/// GetX Controller managing state for the common Task List screen.
class TaskListController extends GetxController {
  final TaskListService _service = TaskListService();

  /// Observable filter period string (TODAY, WEEK, MONTH, EXPIRED).
  final RxString currentFilter = StringConstants.kToday.obs;

  /// Observable screen title text matching active filter.
  final RxString screenTitle = StringConstants.kTodaysTasks.obs;

  /// Observable focus summary metrics.
  final Rx<FocusSummaryModel?> focusSummary = Rx<FocusSummaryModel?>(null);

  /// Observable list of tasks scheduled for the active filter period.
  final RxList<TaskModel> tasks = <TaskModel>[].obs;

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
    } else {
      screenTitle.value = StringConstants.kTodaysTasks;
    }
  }

  /// Loads focus summary and task list from task list service using active filter.
  Future<void> loadTasksData() async {
    focusSummary.value = await _service.getFocusSummaryByPeriod(currentFilter.value);
    tasks.assignAll(await _service.getTasksByPeriod(currentFilter.value));
  }

  /// Toggles task completion state for the item at [index].
  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < tasks.length) {
      final task = tasks[index];
      task.isCompleted = !task.isCompleted;
      tasks[index] = task;
      tasks.refresh();
    }
  }
}
