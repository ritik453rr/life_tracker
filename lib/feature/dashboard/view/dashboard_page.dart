import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/language/string_constants.dart';
import '../../../core/routing/app_routes.dart';
import '../controller/dashboard_controller.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/period_stat_card.dart';
import '../widgets/task_item_card.dart';
import '../widgets/yearly_progress_card.dart';

/// Main Dashboard View Screen displaying progress, statistics, and upcoming tasks.
class DashboardPage extends StatelessWidget {
  /// Creates a [DashboardPage] instance.
  const DashboardPage({super.key});

  /// Builds the main Dashboard page structure using StatelessWidget and Get.find controller lookup.
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const DashboardHeader(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Yearly Progress Card
                    Obx(() {
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
                    const SizedBox(height: 16),

                    // Period Stats Grid (TODAY, WEEK, MONTH, EXPIRED)
                    Obx(() {
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
                    const SizedBox(height: 24),

                    // Upcoming Tasks Header
                    Row(
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
                        TextButton(
                          onPressed: () => Get.toNamed(AppRoutes.taskList),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                    ),
                    const SizedBox(height: 14),

                    // Task Items List
                    Obx(() {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.upcomingTasks.length,
                        itemBuilder: (context, index) {
                          final task = controller.upcomingTasks[index];
                          return TaskItemCard(
                            task: task,
                            onToggle: () => controller.toggleTaskCompletion(index),
                          );
                        },
                      );
                    }),
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
