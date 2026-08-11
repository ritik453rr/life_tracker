import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';
import '../controller/dashboard_controller.dart';

/// Top header widget displaying user avatar, LifeTracker app title, and tracking subtitle.
class DashboardHeader extends StatelessWidget {
  /// Creates a [DashboardHeader] instance.
  const DashboardHeader({super.key});

  /// Builds the top app bar header displaying profile avatar and app title.
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : null;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              children: [
                // App Title & Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      StringConstants.kLifeTracker,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0052CC),
                        letterSpacing: -0.3,
                      ),
                    ),
                    2.h,
                    Obx(() {
                      final subtitleText = controller?.trackingSinceText;
                      if (subtitleText == null) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        subtitleText,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        const Divider(
          height: 1,
          thickness: 1,
          color: Color(0xFFE2E8F0),
        ),
      ],
    ),
    );
  }
}
