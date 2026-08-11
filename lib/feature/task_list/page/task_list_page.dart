import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widgets/app_search_bar.dart';
import '../../../core/common_widgets/app_top_bar.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/routing/app_routes.dart';
import '../../dashboard/widgets/task_item_card.dart';
import '../controller/task_list_controller.dart';
import '../widgets/active_focus_card.dart';

/// Common Task List Screen view displaying tasks based on route filter arguments.
class TaskListPage extends StatelessWidget {
  /// Creates a [TaskListPage] instance.
  const TaskListPage({super.key});

  /// Builds the Task List screen using StatelessWidget and Get.find controller lookup.
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TaskListController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Scrollable Task List Body (Scrolls BEHIND fixed app bar & search bar)
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 122.0,
                bottom: 40.0,
              ),
              child: Column(
                children: [
                  16.h,
                  // Active Focus Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() {
                      final summary = controller.focusSummary.value;
                      if (summary == null) {
                        return const SizedBox.shrink();
                      }
                      return ActiveFocusCard(summary: summary);
                    }),
                  ),
                  20.h,

                  // Task List Items
                  Obx(() {
                    final filtered = controller.filteredTasks;
                    if (filtered.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        return TaskItemCard(
                          task: task,
                          onToggle: () => controller.toggleTaskCompletion(task),
                          onTap: () => Get.toNamed(AppRoutes.createTask, arguments: task),
                          onDelete: () => controller.deleteTask(task),
                        );
                      },
                    );
                  }),
                  40.h,
                ],
              ),
            ),
          ),

          // Top Header Fixed Layer (App Bar + Search Bar pinned at top)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white.withValues(alpha: 0.96),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(height: MediaQuery.of(context).padding.top),
                  Obx(() {
                    return AppTopBar(title: controller.screenTitle.value);
                  }),
                  8.h,
                  // Interactive Search Bar Widget (Fixed)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() {
                      return AppSearchBar(
                        controller: controller.searchFieldController,
                        onChanged: controller.onSearchChanged,
                        onClear: controller.clearSearch,
                        query: controller.searchQuery.value,
                      );
                    }),
                  ),
                  12.h,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
