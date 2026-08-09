import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
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
                  14.w,
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
                clipBehavior: Clip.none,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    // Interactive Search Bar Widget
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _SearchBar(controller: controller),
                    ),
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
          ],
        ),
      ),
    );
  }
}

/// Interactive Search Bar widget for searching tasks by title or category.
class _SearchBar extends StatelessWidget {
  final TaskListController controller;

  /// Creates a [_SearchBar] instance with the required [controller].
  const _SearchBar({required this.controller});

  /// Builds the search text input field with clear action.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF64748B).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          10.w,
          Expanded(
            child: TextField(
              controller: controller.searchFieldController,
              onChanged: controller.onSearchChanged,
              decoration: const InputDecoration(
                hintText: StringConstants.kSearchTasks,
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8),
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.0),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.clearSearch();
              },
              child: const Icon(
                Icons.cancel,
                color: Color(0xFF94A3B8),
                size: 18,
              ),
            );
          }),
        ],
      ),
    );
  }
}
