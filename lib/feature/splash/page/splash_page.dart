import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/assets.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../controller/splash_controller.dart';

/// Splash screen page displaying LifeTracker branding, logo asset, and animated loading progress.
class SplashPage extends StatelessWidget {
  /// Creates a [SplashPage] instance.
  const SplashPage({super.key});

  /// Builds the splash screen layout featuring the PNG app logo and animated progress indicator.
  @override
  Widget build(BuildContext context) {
    // Ensure SplashController dependency is retrieved via Get.find
    Get.find<SplashController>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),

            // Center Branding Logo and Title
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo PNG Asset
                  Image.asset(
                    Assets.pngAppLogo,
                    width: 170,
                    height: 170,
                    fit: BoxFit.contain,
                  ),
                  36.h,

                  // LifeTracker Title
                  const Text(
                    StringConstants.kLifeTracker,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0052CC),
                      letterSpacing: -0.8,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Footer Section: Animated Progress Bar Pill
            const Padding(
              padding: EdgeInsets.only(bottom: 32.0),
              child: _AnimatedSplashProgressBar(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stateful widget rendering a smooth animated horizontal progress bar pill for splash loading.
class _AnimatedSplashProgressBar extends StatefulWidget {
  /// Creates an [_AnimatedSplashProgressBar] instance.
  const _AnimatedSplashProgressBar();

  @override
  State<_AnimatedSplashProgressBar> createState() => _AnimatedSplashProgressBarState();
}

/// State managing animation controller for [_AnimatedSplashProgressBar].
class _AnimatedSplashProgressBarState extends State<_AnimatedSplashProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Initializes the repeating reverse animation controller (left-to-right & right-to-left).
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat(reverse: true);
  }

  /// Disposes the animation controller when unmounted.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the animated progress bar pill sliding back and forth (left to right and right to left).
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final alignX = -1.0 + (_animation.value * 2.0);
        return Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment(alignX, 0),
            child: Container(
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF0052CC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        );
      },
    );
  }
}
