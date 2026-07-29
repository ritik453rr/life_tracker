import 'package:flutter/material.dart';

/// Data class representing a dynamic task form entry.
class TaskFormItem {
  final String id;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  String category;

  TaskFormItem({
    required this.id,
    TextEditingController? titleController,
    TextEditingController? descriptionController,
    this.category = "General",
  })  : titleController = titleController ?? TextEditingController(),
        descriptionController = descriptionController ?? TextEditingController();

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}
