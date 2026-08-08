import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/language/string_constants.dart';
import '../controller/create_task_controller.dart';
import '../widgets/task_form_card.dart';

/// Screen view for creating new task(s).
class CreateTaskPage extends StatelessWidget {
  /// Creates a [CreateTaskPage] instance.
  const CreateTaskPage({super.key});

  /// Builds the task creation screen using StatelessWidget and Get.find controller lookup.
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateTaskController>();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 24,
                      color: Color(0xFF0066CC),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() {
                    return Text(
                      controller.isEditing.value ? "Edit Task" : StringConstants.kCreateTask,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE2E8F0),
            ),

            // Scrollable Content Form Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // DATE Selector Box
                    const Text(
                      StringConstants.kDate,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(() {
                      final date = controller.selectedDate.value;
                      final formattedDate =
                          "${date.day} ${months[date.month - 1]} ${date.year}";

                      return GestureDetector(
                        onTap: () => controller.pickDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF0066CC).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: Color(0xFF0066CC),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 20),

                    // List of Task Form Cards
                    Obx(() {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.taskItems.length,
                        itemBuilder: (context, index) {
                          final item = controller.taskItems[index];
                          return TaskFormCard(
                            taskIndex: index + 1,
                            item: item,
                            showRemove: controller.taskItems.length > 1 && !controller.isEditing.value,
                            onRemove: () => controller.removeTaskForm(index),
                            categoryOptions: controller.categoryOptions,
                            onCategoryChanged: (val) =>
                                controller.updateCategory(index, val),
                          );
                        },
                      );
                    }),

                    // Add Another Task Button (Creation Mode only)
                    Obx(() {
                      if (controller.isEditing.value) {
                        return const SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: controller.addNewTaskForm,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFDBEAFE),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.add,
                                size: 18,
                                color: Color(0xFF0066CC),
                              ),
                              SizedBox(width: 6),
                              Text(
                                StringConstants.kAddAnotherTask,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0066CC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 32),

                    // Create / Update Tasks Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: Obx(() {
                        final isValid = controller.isFormValid.value;
                        return ElevatedButton(
                          onPressed: isValid ? controller.submitTasks : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0052CC),
                            disabledBackgroundColor: const Color(0xFF0052CC).withValues(alpha: 0.12),
                            elevation: isValid ? 2 : 0,
                            shadowColor: const Color(0xFF0052CC).withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(27),
                            ),
                          ),
                          child: Text(
                            controller.isEditing.value ? "Update Task" : StringConstants.kCreateTasks,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isValid
                                  ? Colors.white
                                  : const Color(0xFF0052CC).withValues(alpha: 0.4),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
