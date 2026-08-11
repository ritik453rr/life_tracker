import '../model/task_list_model.dart';
import '../../dashboard/model/dashboard_model.dart';

/// Feature service providing task list and focus summary data filtered by period.
class TaskListService {
  /// Fetches focus summary metrics corresponding to the specified [filter] period.
  Future<FocusSummaryModel> getFocusSummaryByPeriod(String filter) async {
    return FocusSummaryModel(
      totalTasks: 0,
      periodSubtitle: "0 tasks scheduled for this period",
    );
  }

  /// Fetches task models corresponding to the specified [filter] period.
  Future<List<TaskModel>> getTasksByPeriod(String filter) async {
    return [];
  }
}
