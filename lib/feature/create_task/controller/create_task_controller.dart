import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/create_task_model.dart';
import '../service/create_task_service.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../../dashboard/model/dashboard_model.dart';
import '../../task_list/controller/task_list_controller.dart';
import '../../../core/language/string_constants.dart';

/// GetX Controller for managing the Create Task / Edit Task screen state.
class CreateTaskController extends GetxController {
  final CreateTaskService _service = CreateTaskService();

  final RxBool isEditing = false.obs;
  String? editingTaskId;
  final RxBool isFormValid = false.obs;

  // Initial field states for edit tracking
  String? _initialTitle;
  String? _initialDescription;
  String? _initialCategory;
  DateTime? _initialDate;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<CreateTaskModel> taskItems = <CreateTaskModel>[].obs;
  final List<String> categoryOptions = [
    StringConstants.kGeneral,
    StringConstants.kWorkCategory,
    StringConstants.kHealthCategory,
    StringConstants.kPersonalCategory,
  ];

  @override
  void onInit() {
    super.onInit();
    _checkEditingTask();
  }

  DateTime? _parseTaskDate(String dateStr) {
    try {
      final parts = dateStr.trim().split(' ');
      if (parts.length >= 3) {
        final day = int.tryParse(parts[0]);
        final monthStr = parts[1].toLowerCase();
        final year = int.tryParse(parts[2]);

        final monthNames = [
          'january', 'february', 'march', 'april', 'may', 'june',
          'july', 'august', 'september', 'october', 'november', 'december'
        ];
        final shortMonthNames = [
          'jan', 'feb', 'mar', 'apr', 'may', 'jun',
          'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
        ];

        int? month;
        for (int i = 0; i < 12; i++) {
          if (monthNames[i] == monthStr || shortMonthNames[i] == monthStr) {
            month = i + 1;
            break;
          }
        }

        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }

  void _onFormInputChanged() {
    if (isEditing.value && taskItems.isNotEmpty) {
      final item = taskItems.first;
      final currentTitle = item.titleController.text.trim();
      final currentDesc = item.descriptionController.text.trim();
      final currentCategory = item.category;
      final currentDate = selectedDate.value;

      final hasValidInput = currentTitle.isNotEmpty || currentDesc.isNotEmpty;
      final isModified = currentTitle != (_initialTitle ?? '') ||
          currentDesc != (_initialDescription ?? '') ||
          currentCategory != _initialCategory ||
          currentDate.year != _initialDate?.year ||
          currentDate.month != _initialDate?.month ||
          currentDate.day != _initialDate?.day;

      isFormValid.value = hasValidInput && isModified;
      return;
    }

    bool valid = false;
    for (final item in taskItems) {
      if (item.titleController.text.trim().isNotEmpty ||
          item.descriptionController.text.trim().isNotEmpty) {
        valid = true;
        break;
      }
    }
    isFormValid.value = valid;
  }

  void _attachListeners(CreateTaskModel item) {
    item.titleController.addListener(_onFormInputChanged);
    item.descriptionController.addListener(_onFormInputChanged);
  }

  void _checkEditingTask() {
    final args = Get.arguments;
    if (args != null && args is TaskModel) {
      isEditing.value = true;
      editingTaskId = args.id;

      String category = "General";
      for (final option in categoryOptions) {
        if (option.toUpperCase() == args.category.toUpperCase()) {
          category = option;
          break;
        }
      }

      final item = CreateTaskModel(
        id: args.id,
        category: category,
      );
      item.titleController.text = args.title;
      if (args.description != null) {
        item.descriptionController.text = args.description!;
      }

      _initialTitle = args.title;
      _initialDescription = args.description ?? '';
      _initialCategory = category;

      final parsedDate = _parseTaskDate(args.date);
      if (parsedDate != null) {
        selectedDate.value = parsedDate;
      }
      _initialDate = selectedDate.value;

      _attachListeners(item);
      taskItems.assignAll([item]);
    } else {
      isEditing.value = false;
      addNewTaskForm();
    }
    _onFormInputChanged();
  }

  void addNewTaskForm() {
    final newItem = CreateTaskModel(id: DateTime.now().millisecondsSinceEpoch.toString());
    _attachListeners(newItem);
    taskItems.add(newItem);
    _onFormInputChanged();
  }

  void removeTaskForm(int index) {
    if (taskItems.length > 1 && index >= 0 && index < taskItems.length) {
      final item = taskItems.removeAt(index);
      item.dispose();
      _onFormInputChanged();
    }
  }

  void updateCategory(int index, String? newCategory) {
    if (newCategory != null && index >= 0 && index < taskItems.length) {
      taskItems[index].category = newCategory;
      taskItems.refresh();
      _onFormInputChanged();
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
      _onFormInputChanged();
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'WORK':
        return const Color(0xFF0066CC);
      case 'HEALTH':
        return const Color(0xFF0F9D58);
      case 'PERSONAL':
        return const Color(0xFF9E6D00);
      default:
        return const Color(0xFF64748B);
    }
  }

  void submitTasks() {
    if (!isFormValid.value) return;

    if (isEditing.value && editingTaskId != null && taskItems.isNotEmpty) {
      final item = taskItems.first;
      final months = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      final date = selectedDate.value;
      final formattedDate = "${date.day} ${months[date.month - 1]} ${date.year}";

      final rawTitle = item.titleController.text.trim();
      final rawDesc = item.descriptionController.text.trim();

      if (Get.isRegistered<DashboardController>()) {
        final dashboardCtrl = Get.find<DashboardController>();
        final idx = dashboardCtrl.upcomingTasks.indexWhere((t) => t.id == editingTaskId);
        if (idx != -1) {
          final oldTask = dashboardCtrl.upcomingTasks[idx];
          dashboardCtrl.upcomingTasks[idx] = TaskModel(
            id: editingTaskId!,
            title: rawTitle,
            category: item.category.toUpperCase(),
            date: formattedDate,
            description: rawDesc.isEmpty ? null : rawDesc,
            categoryColor: _getCategoryColor(item.category),
            badgeColor: oldTask.badgeColor,
            timeLeft: oldTask.timeLeft,
            isCompleted: oldTask.isCompleted,
          );
          dashboardCtrl.upcomingTasks.refresh();
        }
      }

      if (Get.isRegistered<TaskListController>()) {
        final taskListCtrl = Get.find<TaskListController>();
        final idx = taskListCtrl.tasks.indexWhere((t) => t.id == editingTaskId);
        if (idx != -1) {
          final oldTask = taskListCtrl.tasks[idx];
          taskListCtrl.tasks[idx] = TaskModel(
            id: editingTaskId!,
            title: rawTitle,
            category: item.category.toUpperCase(),
            date: formattedDate,
            description: rawDesc.isEmpty ? null : rawDesc,
            categoryColor: _getCategoryColor(item.category),
            badgeColor: oldTask.badgeColor,
            timeLeft: oldTask.timeLeft,
            isCompleted: oldTask.isCompleted,
          );
          taskListCtrl.tasks.refresh();
        }
      }

      Get.back();
      return;
    }

    final newTasks = _service.convertToTaskModels(
      items: taskItems,
      date: selectedDate.value,
    );

    if (Get.isRegistered<DashboardController>()) {
      final dashboardCtrl = Get.find<DashboardController>();
      dashboardCtrl.upcomingTasks.insertAll(0, newTasks);
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

    if (Get.isRegistered<TaskListController>()) {
      final taskListCtrl = Get.find<TaskListController>();
      taskListCtrl.tasks.insertAll(0, newTasks);
      taskListCtrl.tasks.refresh();
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
