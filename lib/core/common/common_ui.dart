import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/assets.dart';
import '../language/string_constants.dart';

/// Utility class providing reusable common UI widgets and helpers across the app.
class CommonUI {
  /// Returns a customizable circular loading indicator with optional color and stroke width.
  static Widget circularIndicator({
    Color color = AppColors.cBlue,
    double strokeWidth = 3,
  }) {
    return CircularProgressIndicator(color: color, strokeWidth: strokeWidth);
  }

  /// Method to return load more indicator.
  static Widget loadMoreIndicator({
    double? strokeWidth,
    Color? backgroundColor,
  }) {
    return SizedBox(
      height: 40,
      width: 40,
      child: CircularProgressIndicator(
        color: AppColors.cBlue,
        strokeWidth: strokeWidth ?? 3.0,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Wraps the given widget with a pull-to-refresh indicator that triggers the provided refresh callback.
  static Widget refreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
  }) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.cBlue,
      backgroundColor: AppColors.cFFFFFF,
      child: child,
    );
  }

  /// Wrapper around SafeArea that applies platform-aware bottom padding and configurable top inset.
  static Widget safeArea({required Widget child, bool top = true}) {
    return SafeArea(bottom: !GetPlatform.isIOS, top: top, child: child);
  }

  /// Method to set network image
  static Widget setNetworkImg({
    String imgUrl = "",
    double height = 125,
    double width = 125,
    double borderRadius = 12,
    BoxFit fit = BoxFit.cover,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: imgUrl,
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Container(height: height, width: width, color: Colors.white),
          );
        },
        errorWidget: (context, url, error) {
          return Image.asset(
            Assets.pngTriangleInsetHey,
            height: height,
            width: width,
            fit: fit,
          );
        },
      ),
    );
  }

  /// Builds a customizable TextButton with left alignment, optional styling, and built-in haptic feedback and keyboard dismissal.
  static Widget customTextBtn({
    required String title,
    void Function()? onPressed,
    EdgeInsetsGeometry padding = EdgeInsets.zero,
    TextStyle? style,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        alignment: Alignment.centerLeft,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        overlayColor: Colors.grey,
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: padding,
        minimumSize: const Size(0, 0),
      ),
      onPressed: () {
        AppConstants.hapticFeedBack();
        AppConstants.hideKeyboard();
        onPressed?.call();
      },
      child: Text(title, style: style),
    );
  }

  /// Displays a success or error snackBar with a trimmed message based on API response.
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
