import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/language/string_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../../dashboard/widgets/task_item_card.dart';
import '../controller/task_list_controller.dart';
import '../widgets/active_focus_card.dart';

/// Screen view for Today's Tasks screen.
class TaskListPage extends GetView<TaskListController> {
  /// Creates a [TaskListPage] instance.
  const TaskListPage({super.key});

  /// Builds the Today's Tasks screen layout without bottom navigation.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
                  const SizedBox(width: 14),
                  Obx(() {
                    return Text(
                      controller.screenTitle.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    );
                  }),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.search,
                      size: 22,
                      color: Color(0xFF334155),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E293B),
                      image: DecorationImage(
                        image: NetworkImage(
                          "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFE2E8F0),
            ),

            // Scrollable Task List Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  children: [
                    // Active Focus Card
                    Obx(() {
                      final summary = controller.focusSummary.value;
                      if (summary == null) {
                        return const SizedBox.shrink();
                      }
                      return ActiveFocusCard(summary: summary);
                    }),
                    const SizedBox(height: 20),

                    // Task List Items
                    Obx(() {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.tasks.length,
                        itemBuilder: (context, index) {
                          final task = controller.tasks[index];
                          return TaskItemCard(
                            task: task,
                            onToggle: () => controller.toggleTaskCompletion(index),
                          );
                        },
                      );
                    }),
                    const SizedBox(height: 32),

                    // Footer Empty / View Tomorrow Section
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFF1F5F9),
                      ),
                      child: const Icon(
                        Icons.event_available_outlined,
                        size: 28,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      StringConstants.kNoMoreTasksToday,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        StringConstants.kViewTomorrow,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0066CC),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.createTask),
        backgroundColor: const Color(0xFF0066CC),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
