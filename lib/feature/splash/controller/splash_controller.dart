import 'dart:async';
import 'package:get/get.dart';
import '../../../core/routing/app_routes.dart';

/// GetX Controller managing initialization and navigation for the Splash screen.
class SplashController extends GetxController {
  /// Timer reference for splash delay navigation.
  Timer? _timer;

  /// Initializes the controller and starts the navigation delay timer.
  @override
  void onInit() {
    super.onInit();
    _startNavigationTimer();
  }

  /// Starts a 2.5-second timer before redirecting to the main Dashboard screen.
  void _startNavigationTimer() {
    _timer = Timer(const Duration(milliseconds: 2500), () {
      Get.offNamed(AppRoutes.dashboard);
    });
  }

  /// Cancels the navigation timer when the controller is disposed.
  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
