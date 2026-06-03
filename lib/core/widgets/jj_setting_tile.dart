import 'package:flutter/material.dart';

import '../../app/theme.dart';

class JJSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const JJSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: JJColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: JJColors.primaryPurple.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? JJColors.primaryPurple).withAlpha(20),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? JJColors.primaryPurple,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: JJColors.textDark,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: JJColors.textMuted),
              )
            : null,
        trailing: trailing ?? (onTap != null
            ? const Icon(Icons.chevron_right, color: JJColors.textMuted)
            : null),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
