import 'package:get/get.dart';
import '../model/dashboard_model.dart';
import '../service/dashboard_service.dart';

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
}
