import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/settings_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: Image.asset(
              'assets/images/welcome-screen.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SettingsProvider>().markWelcomeSeen();
                        Navigator.pushReplacementNamed(context, '/register');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B2BEA),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF7A7395)),
                        children: [
                          const TextSpan(
                              text: 'Already have an account? '),
                          TextSpan(
                            text: 'Login',
                            style: TextStyle(
                              color: const Color(0xFF5B2BEA),
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  const Color(0xFF5B2BEA).withAlpha(80),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
