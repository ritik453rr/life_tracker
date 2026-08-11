import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/common_widgets/empty_state_widget.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/period_stat_card.dart';
import '../widgets/task_item_card.dart';
import '../widgets/yearly_progress_card.dart';

/// Main Dashboard View Screen displaying progress, statistics, and upcoming tasks.
class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.find<DashboardController>();

  /// Builds the main Dashboard page structure using StatelessWidget and Get.find controller lookup.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.createTask),
        backgroundColor: const Color(0xFF0066CC),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(top: 38, bottom: 38.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Yearly Progress Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() {
                        final summaryData = controller.summary.value;
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: summaryData == null
                              ? const Center(
                                  key: ValueKey("loading"),
                                  child: CircularProgressIndicator(),
                                )
                              : YearlyProgressCard(
                                  key: const ValueKey("summary_card"),
                                  summary: summaryData,
                                ),
                        );
                      }),
                    ),
                    16.h,

                    // Period Stats Grid (TODAY, WEEK, MONTH, EXPIRED)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.periodStats.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 1.8,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemBuilder: (context, index) {
                            final stat = controller.periodStats[index];
                            return GestureDetector(
                              onTap: () => Get.toNamed(
                                AppRoutes.taskList,
                                arguments: stat.periodName,
                              ),
                              child: PeriodStatCard(stat: stat),
                            );
                          },
                        );
                      }),
                    ),
                    24.h,

                    // Upcoming Tasks Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Obx(() {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              StringConstants.kUpcomingTasks,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (controller.upcomingTasks.length > 10)
                              TextButton(
                                onPressed: () => Get.toNamed(
                                  AppRoutes.taskList,
                                  arguments: StringConstants.kAll,
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  StringConstants.kViewAll,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0066CC),
                                  ),
                                ),
                              ),
                          ],
                        );
                      }),
                    ),
                    14.h,

                    // Task Items List (Max 10) or Empty State Widget
                    Obx(() {
                      if (controller.upcomingTasks.isEmpty) {
                        return const EmptyStateWidget(
                          icon: Icons.task_alt_rounded,
                          title: StringConstants.kNoUpcomingTasks,
                          description: StringConstants.kNoTasksDescription,
                        );
                      }
                      final tasksToShow = controller.upcomingTasks
                          .take(10)
                          .toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: tasksToShow.length,
                        itemBuilder: (context, index) {
                          final task = tasksToShow[index];
                          return TaskItemCard(
                            task: task,
                            onToggle: () =>
                                controller.toggleTaskCompletion(index),
                            onTap: () => Get.toNamed(
                              AppRoutes.createTask,
                              arguments: task,
                            ),
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
