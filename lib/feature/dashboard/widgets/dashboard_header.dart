import 'package:flutter/material.dart';

/// Top header widget displaying user avatar, LifeTracker app title, and tracking subtitle.
class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              // Avatar Image / Circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  image: const DecorationImage(
                    image: NetworkImage(
                      "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
                    ),
                    fit: BoxFit.cover,
                  ),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // App Title & Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "LifeTracker",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0052CC),
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "TRACKING SINCE JAN 1, 2024",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.8,
                    ),
                  ),
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
