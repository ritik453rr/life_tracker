import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Platform-aware SafeArea wrapper widget.
class AppSafeArea extends StatelessWidget {
  final Widget child;
  final bool top;

  const AppSafeArea({
    super.key,
    required this.child,
    this.top = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: !GetPlatform.isIOS,
      top: top,
      child: child,
    );
  }
}
