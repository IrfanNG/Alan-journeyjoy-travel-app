import 'package:flutter/material.dart';

import '../../app/theme.dart';

class JJBottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int)? onTap;

  const JJBottomNav({
    super.key,
    this.currentIndex = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: JJColors.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: JJColors.primaryPurple.withAlpha(15),
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
              _navItem(Icons.home_rounded, 'Home', 0),
              _navItem(Icons.flight_takeoff, 'Trips', 1),
              _centerPlusButton(2),
              _navItem(Icons.monetization_on_outlined, 'Expenses', 3),
              _navItem(Icons.settings_outlined, 'More', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _centerPlusButton(int index) {
    return GestureDetector(
      onTap: () => onTap?.call(index),
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

  Widget _navItem(IconData icon, String label, int index) {
    final selected = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap?.call(index),
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
              color: selected ? JJColors.primaryPurple : JJColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? JJColors.primaryPurple : JJColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
