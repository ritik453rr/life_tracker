import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Custom pull-to-refresh wrapper widget.
class AppRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const AppRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.cBlue,
      backgroundColor: AppColors.cFFFFFF,
      child: child,
    );
  }
}
