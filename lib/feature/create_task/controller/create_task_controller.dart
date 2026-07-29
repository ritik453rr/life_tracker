import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/create_task_model.dart';
import '../service/create_task_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../dashboard/model/dashboard_model.dart';

/// GetX Controller for managing the Create Task screen state.
class CreateTaskController extends GetxController {
  final CreateTaskService _service = CreateTaskService();

  final Rx<DateTime> selectedDate = DateTime(2026, 7, 14).obs;
  final RxList<TaskFormItem> taskItems = <TaskFormItem>[].obs;
  final List<String> categoryOptions = ["General", "Work", "Health", "Personal"];

  @override
  void onInit() {
    super.onInit();
    addNewTaskForm();
  }

  void addNewTaskForm() {
    final newItem = TaskFormItem(id: DateTime.now().millisecondsSinceEpoch.toString());
    taskItems.add(newItem);
  }

  void removeTaskForm(int index) {
    if (taskItems.length > 1 && index >= 0 && index < taskItems.length) {
      final item = taskItems.removeAt(index);
      item.dispose();
    }
  }

  void updateCategory(int index, String? newCategory) {
    if (newCategory != null && index >= 0 && index < taskItems.length) {
      taskItems[index].category = newCategory;
      taskItems.refresh();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066CC),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  void submitTasks() {
    final newTasks = _service.convertToTaskModels(
      items: taskItems,
      date: selectedDate.value,
    );

    if (Get.isRegistered<DashboardController>()) {
      final dashboardCtrl = Get.find<DashboardController>();
      dashboardCtrl.upcomingTasks.insertAll(0, newTasks);
      // Optionally update total count in summary
      if (dashboardCtrl.summary.value != null) {
        final oldSum = dashboardCtrl.summary.value!;
        dashboardCtrl.summary.value = StatSummaryModel(
          total: oldSum.total + newTasks.length,
          done: oldSum.done,
          pending: oldSum.pending + newTasks.length,
          expired: oldSum.expired,
          efficiencyPercentage: oldSum.efficiencyPercentage,
        );
      }
    }

    Get.back();
  }

  @override
  void onClose() {
    for (var item in taskItems) {
      item.dispose();
    }
    super.onClose();
  }
}
