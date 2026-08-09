import 'package:flutter/material.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../../../core/common_widgets/app_drop_down_button.dart';
import '../model/create_task_model.dart';

/// Card widget containing input fields for a single task entry.
class TaskFormCard extends StatelessWidget {
  final int taskIndex;
  final CreateTaskModel item;
  final bool showRemove;
  final VoidCallback onRemove;
  final List<String> categoryOptions;
  final ValueChanged<String?> onCategoryChanged;

  const TaskFormCard({
    super.key,
    required this.taskIndex,
    required this.item,
    required this.showRemove,
    required this.onRemove,
    required this.categoryOptions,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left Blue Accent Strip
              Container(width: 5, color: const Color(0xFF0066CC)),
              // Main Card Form Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: TASK N and Close Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${StringConstants.kTaskUpper} $taskIndex",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0066CC),
                              letterSpacing: 0.8,
                            ),
                          ),
                          if (showRemove)
                            GestureDetector(
                              onTap: onRemove,
                              child: const Icon(
                                Icons.close,
                                size: 20,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                        ],
                      ),
                      16.h,

                      // Task Title Input Field
                      const Text(
                        StringConstants.kTaskTitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.6,
                        ),
                      ),
                      8.h,
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: TextField(
                          controller: item.titleController,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: const InputDecoration(
                            hintText: StringConstants.kWhatNeedsToBeDone,
                            hintStyle: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFCBD5E1),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      16.h,

                      // Description & Notes Input Field
                      const Text(
                        StringConstants.kDescriptionNotes,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.6,
                        ),
                      ),
                      8.h,
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.2,
                          ),
                        ),
                        child: TextField(
                          controller: item.descriptionController,
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: const InputDecoration(
                            hintText: StringConstants.kAddDetails,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFCBD5E1),
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),
                      16.h,

                      // Category Dropdown Field
                      const Text(
                        StringConstants.kCategory,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.6,
                        ),
                      ),
                      8.h,
                      AppDropDownButton<String>(
                        value: item.category,
                        options: categoryOptions,
                        onChanged: onCategoryChanged,
                      ),
                 
                 
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
