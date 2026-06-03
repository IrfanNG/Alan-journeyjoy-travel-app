import 'package:flutter/material.dart';

class SocialAuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;

  const SocialAuthButton({
    super.key,
    required this.label,
    required this.icon,
    this.iconColor = const Color(0xFF130B3A),
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEEAFF)),
          color: Colors.white,
        ),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF130B3A),
            shadowColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF130B3A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
