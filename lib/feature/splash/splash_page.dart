import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/assets.dart';
import '../../core/language/string_constants.dart';
import 'splash_controller.dart';

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
      backgroundColor: Colors.white,
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
                  const SizedBox(height: 36),

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

            // Footer Section: "Powered by Design Ops" and Animated Progress Bar Pill
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'Roboto',
                      ),
                      children: [
                        TextSpan(
                          text: StringConstants.kPoweredBy,
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: StringConstants.kDesignOps,
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Animated Horizontal Progress Bar Pill
                  const _AnimatedSplashProgressBar(),
                ],
              ),
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

  /// Initializes the 2.3-second smooth progress animation controller starting from 0.0.
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _controller.forward(from: 0.0);
  }

  /// Disposes the animation controller when unmounted.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the animated progress bar pill with smooth width transition.
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _animation.value.clamp(0.05, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0052CC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
