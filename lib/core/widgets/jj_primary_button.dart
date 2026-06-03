import 'package:flutter/material.dart';

import '../../app/theme.dart';

class JJPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final double height;

  const JJPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.fullWidth = true,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: JJColors.primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
