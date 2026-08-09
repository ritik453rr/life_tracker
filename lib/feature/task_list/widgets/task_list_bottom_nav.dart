import 'package:flutter/material.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';

/// Bottom Navigation Bar matching design screenshot (Home, Tasks, Growth, Profile).
class TaskListBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const TaskListBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(icon: Icons.grid_view_rounded, activeIcon: Icons.grid_view_rounded, label: StringConstants.kHome),
      _NavItem(icon: Icons.checklist_rtl_rounded, activeIcon: Icons.checklist_rtl_rounded, label: StringConstants.kTasks),
      _NavItem(icon: Icons.trending_up_rounded, activeIcon: Icons.trending_up_rounded, label: StringConstants.kGrowth),
      _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: StringConstants.kProfile),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(navItems.length, (index) {
            final isSelected = selectedIndex == index;
            final item = navItems[index];

            return InkWell(
              onTap: () => onItemTapped(index),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 18.0 : 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB) // Solid vibrant blue pill as in design
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 20,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    if (isSelected) ...[
                      6.w,
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ] else ...[
                      2.h,
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
