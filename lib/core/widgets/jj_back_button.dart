import 'package:flutter/material.dart';

import '../../app/theme.dart';

enum JJBackButtonVariant {
  lightOnDark,
  purpleOnLight,
}

class JJBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final JJBackButtonVariant variant;

  const JJBackButton({
    super.key,
    this.onTap,
    this.variant = JJBackButtonVariant.lightOnDark,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = variant == JJBackButtonVariant.purpleOnLight;

    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isLight
              ? JJColors.primaryPurple.withAlpha(18)
              : Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          Icons.arrow_back,
          color: isLight ? JJColors.primaryPurple : Colors.white,
          size: 23,
        ),
      ),
    );
  }
}
