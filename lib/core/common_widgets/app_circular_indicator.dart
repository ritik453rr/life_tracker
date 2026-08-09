import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Custom circular loading indicator widget.
class AppCircularIndicator extends StatelessWidget {
  final Color color;
  final double strokeWidth;

  const AppCircularIndicator({
    super.key,
    this.color = AppColors.cBlue,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      color: color,
      strokeWidth: strokeWidth,
    );
  }
}
