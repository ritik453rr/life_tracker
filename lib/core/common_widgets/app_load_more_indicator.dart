import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Custom load more indicator widget.
class AppLoadMoreIndicator extends StatelessWidget {
  final double strokeWidth;
  final Color? backgroundColor;

  const AppLoadMoreIndicator({
    super.key,
    this.strokeWidth = 3.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 40,
      child: CircularProgressIndicator(
        color: AppColors.cBlue,
        strokeWidth: strokeWidth,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
