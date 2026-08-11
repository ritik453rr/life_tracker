import 'package:life_tracker_flutter/feature/create_task/model/create_task_model.dart';

import '../../dashboard/model/dashboard_model.dart';
import 'package:flutter/material.dart';

/// Feature service handling task creation operations.
class CreateTaskService {
  /// Converts task form entries to TaskModel objects.
  List<TaskModel> convertToTaskModels({
    required List<CreateTaskModel> items,
    required DateTime date,
  }) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final formattedDate = "${date.day} ${months[date.month - 1]} ${date.year}";

    return items
        .where((item) {
          final title = item.titleController.text.trim();
          final desc = item.descriptionController.text.trim();
          return title.isNotEmpty || desc.isNotEmpty;
        })
        .map((item) {
          final categoryUpper = item.category.toUpperCase();
          Color categoryColor = const Color(0xFF0066CC);
          if (categoryUpper == "WORK") {
            categoryColor = const Color(0xFF0066CC);
          } else if (categoryUpper == "HEALTH") {
            categoryColor = const Color(0xFF0F9D58);
          } else if (categoryUpper == "PERSONAL") {
            categoryColor = const Color(0xFF9E6D00);
          }

          final rawTitle = item.titleController.text.trim();
          final rawDesc = item.descriptionController.text.trim();
          final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

          return TaskModel(
            id: item.id,
            title: rawTitle,
            category: categoryUpper,
            date: formattedDate,
            dueDate: endOfDay,
            description: rawDesc.isEmpty ? null : rawDesc,
            categoryColor: categoryColor,
            isCompleted: false,
          );
        })
        .toList();
  }
}
