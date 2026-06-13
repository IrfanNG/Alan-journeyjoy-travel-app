import 'package:flutter/material.dart';

import '../../app/theme.dart';

class JJCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const JJCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? JJColors.primaryPurple : context.jj.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? JJColors.primaryPurple : JJColors.primaryPurple.withAlpha(25),
            width: 1.5,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: JJColors.primaryPurple.withAlpha(40),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? Colors.white : JJColors.primaryPurple,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : context.jj.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
