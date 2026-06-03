import 'package:flutter/material.dart';

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isConfirmPassword;
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.placeholder,
    required this.prefixIcon,
    this.isPassword = false,
    this.isConfirmPassword = false,
    this.keyboardType,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B2BEA).withAlpha(8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscured : false,
        keyboardType: widget.keyboardType,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF130B3A),
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF8F7FF),
          hintText: widget.placeholder,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: Color(0xFF7A7395),
          ),
          prefixIcon: Icon(
            widget.prefixIcon,
            size: 20,
            color: const Color(0xFF7A7395),
          ),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 20,
                    color: const Color(0xFF7A7395),
                  ),
                  onPressed: () => setState(() => _obscured = !_obscured),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: const Color(0xFF5B2BEA).withAlpha(25)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF5B2BEA), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}
