import '../model/create_task_model.dart';
import '../../dashboard/model/dashboard_model.dart';
import 'package:flutter/material.dart';

/// Feature service handling task creation operations.
class CreateTaskService {
  /// Converts task form entries to TaskModel objects.
  List<TaskModel> convertToTaskModels({
    required List<TaskFormItem> items,
    required DateTime date,
  }) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final formattedDate = "${date.day} ${months[date.month - 1]} ${date.year}";

    return items.map((item) {
      final categoryUpper = item.category.toUpperCase();
      Color categoryColor = const Color(0xFF0066CC);
      if (categoryUpper == "WORK") {
        categoryColor = const Color(0xFF0F9D58);
      } else if (categoryUpper == "HEALTH") {
        categoryColor = const Color(0xFF0066CC);
      } else if (categoryUpper == "PERSONAL") {
        categoryColor = const Color(0xFF9E6D00);
      }

      return TaskModel(
        id: item.id,
        title: item.titleController.text.trim().isEmpty
            ? "New Task"
            : item.titleController.text.trim(),
        category: categoryUpper,
        date: formattedDate,
        categoryColor: categoryColor,
        isCompleted: false,
      );
    }).toList();
  }
}
