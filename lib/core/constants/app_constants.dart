import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app_colors.dart';

/// Provides const utility across the application.
class AppConstants {

  /// Hide keyboard method
  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Haptic feedback for the device
  static Future<void> hapticFeedBack() {
    if (GetPlatform.isIOS) {
      return HapticFeedback.lightImpact();
    } else {
      return HapticFeedback.vibrate();
    }
  }

  /// Set safe area color in view
  static void setSafeArea({bool isDark = false}) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: isDark ? AppColors.cBlack : AppColors.cWhite,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        statusBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );
  }
}
