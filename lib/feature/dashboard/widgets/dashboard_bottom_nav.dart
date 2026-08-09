import 'package:flutter/material.dart';
import '../../../core/extension/sized_box_extension.dart';
import '../../../core/language/string_constants.dart';

/// Custom bottom navigation bar with active tab pill styling.
class DashboardBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const DashboardBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: StringConstants.kHomeNav),
      _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: StringConstants.kCalendarNav),
      _NavItem(icon: Icons.bar_chart_rounded, activeIcon: Icons.bar_chart, label: StringConstants.kStatsNav),
      _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: StringConstants.kSettingsNav),
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
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 16.0 : 12.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFDBEAFE) // Soft light blue pill
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 22,
                      color: isSelected
                          ? const Color(0xFF0066CC)
                          : const Color(0xFF64748B),
                    ),
                    3.h,
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF0066CC)
                            : const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
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
