import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum JJBottomNavTab { home, trips, expenses, more }

class JJBottomNav extends StatelessWidget {
  final JJBottomNavTab currentTab;
  final void Function(JJBottomNavTab)? onTabTap;
  final VoidCallback? onCenterTap;

  const JJBottomNav({
    super.key,
    this.currentTab = JJBottomNavTab.home,
    this.onTabTap,
    this.onCenterTap,
  });

  int get _currentIndex {
    switch (currentTab) {
      case JJBottomNavTab.home:
        return 0;
      case JJBottomNavTab.trips:
        return 1;
      case JJBottomNavTab.expenses:
        return 3;
      case JJBottomNavTab.more:
        return 4;
    }
  }

  void _handleTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        onTabTap?.call(JJBottomNavTab.home);
      case 1:
        onTabTap?.call(JJBottomNavTab.trips);
      case 2:
        onCenterTap?.call();
      case 3:
        onTabTap?.call(JJBottomNavTab.expenses);
      case 4:
        onTabTap?.call(JJBottomNavTab.more);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.jj.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: context.jj.shadow,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.home_rounded, 'Home', 0),
              _navItem(context, Icons.flight_takeoff, 'Trips', 1),
              _centerPlusButton(context, 2),
              _navItem(context, Icons.monetization_on_outlined, 'Expenses', 3),
              _navItem(context, Icons.settings_outlined, 'More', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerPlusButton(BuildContext context, int index) {
    return GestureDetector(
      onTap: () => _handleTap(context, index),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: JJColors.gradientPurple,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: JJColors.primaryPurple.withAlpha(50),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int index) {
    final selected = index == _currentIndex;
    return GestureDetector(
      onTap: () => _handleTap(context, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? JJColors.primaryPurple.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? JJColors.primaryPurple : context.jj.muted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? JJColors.primaryPurple : context.jj.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
