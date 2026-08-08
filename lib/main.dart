import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:life_tracker_flutter/core/constants/app_theme.dart';
import 'package:life_tracker_flutter/core/routing/app_pages.dart';
import 'package:life_tracker_flutter/core/routing/app_routes.dart';

/// Entry point of the LifeTracker Flutter application.
void main() {
  runApp(const MyApp());
}

/// Root widget configuring GetMaterialApp theme and routing.
class MyApp extends StatelessWidget {
  /// Creates the root [MyApp] widget.
  const MyApp({super.key});

  /// Builds the GetMaterialApp application structure with initial route set to Splash.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
