import 'package:get/get.dart';
import '../routing/app_routes.dart';
import '../../feature/splash/page/splash_page.dart';
import '../../feature/splash/controller/splash_controller.dart';
import '../../feature/dashboard/page/dashboard_page.dart';
import '../../feature/dashboard/controller/dashboard_controller.dart';
import '../../feature/create_task/page/create_task_page.dart';
import '../../feature/create_task/controller/create_task_controller.dart';
import '../../feature/task_list/page/task_list_page.dart';
import '../../feature/task_list/controller/task_list_controller.dart';

/// Configures all application routes with their corresponding pages and bindings.
class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => SplashController())),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => DashboardController())),
    ),
    GetPage(
      name: AppRoutes.createTask,
      page: () => const CreateTaskPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => CreateTaskController())),
    ),
    GetPage(
      name: AppRoutes.taskList,
      page: () => const TaskListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => TaskListController())),
    ),
  ];
}
