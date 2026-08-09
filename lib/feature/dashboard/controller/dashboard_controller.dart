import 'package:get/get.dart';
import '../model/dashboard_model.dart';
import '../service/dashboard_service.dart';

import '../../task_list/controller/task_list_controller.dart';

/// GetX Controller managing state for the Dashboard feature.
class DashboardController extends GetxController {
  final DashboardService _service = DashboardService();

  final Rx<StatSummaryModel?> summary = Rx<StatSummaryModel?>(null);
  final RxList<PeriodStatModel> periodStats = <PeriodStatModel>[].obs;
  final RxList<TaskModel> upcomingTasks = <TaskModel>[].obs;

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

  void toggleTaskCompletion(int index) {
    if (index >= 0 && index < upcomingTasks.length) {
      final task = upcomingTasks[index];
      task.isCompleted = !task.isCompleted;
      upcomingTasks[index] = task;
      upcomingTasks.refresh();
    }
  }

  /// Removes a task from upcoming tasks list and updates stat summary counters.
  void deleteTask(TaskModel task) {
    upcomingTasks.removeWhere((t) => t.id == task.id);
    if (Get.isRegistered<TaskListController>()) {
      Get.find<TaskListController>().tasks.removeWhere((t) => t.id == task.id);
    }
    if (summary.value != null) {
      final oldSum = summary.value!;
      summary.value = StatSummaryModel(
        total: oldSum.total > 0 ? oldSum.total - 1 : 0,
        done: task.isCompleted ? (oldSum.done > 0 ? oldSum.done - 1 : 0) : oldSum.done,
        pending: !task.isCompleted ? (oldSum.pending > 0 ? oldSum.pending - 1 : 0) : oldSum.pending,
        expired: task.isExpired ? (oldSum.expired > 0 ? oldSum.expired - 1 : 0) : oldSum.expired,
        efficiencyPercentage: oldSum.efficiencyPercentage,
      );
    }
  }
}
