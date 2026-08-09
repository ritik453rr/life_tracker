import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../language/string_constants.dart';

/// Utility for displaying standardized application snackbars.
class AppSnackBar {
  /// Displays a success or error snackBar with a trimmed message.
  static void showApiSnackBar({
    bool isSuccess = false,
    required String message,
  }) {
    final displayMessage = message.length > 200
        ? "${message.substring(0, 200)}..."
        : message;

    Get.snackbar(
      isSuccess ? StringConstants.kSuccess.tr : StringConstants.kError.tr,
      displayMessage,
      backgroundColor: isSuccess ? Colors.green.shade600 : Colors.red.shade600,
      colorText: Colors.white,
    );
  }
}
