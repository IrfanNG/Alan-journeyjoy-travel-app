import 'package:flutter/material.dart';

class AuthHeroBanner extends StatelessWidget {
  final Widget? backButton;
  final double heightFraction;

  const AuthHeroBanner({
    super.key,
    this.backButton,
    this.heightFraction = 0.4,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * heightFraction;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            'assets/images/splash-screen.png',
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.85),
          ),
          if (backButton != null) Positioned(top: 60, left: 20, child: backButton!),
        ],
      ),
    );
  }
}
