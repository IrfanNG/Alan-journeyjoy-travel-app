import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/settings_provider.dart';
import 'widgets/auth_hero_banner.dart';
import 'widgets/auth_primary_button.dart';
import 'widgets/auth_text_field.dart';
import 'widgets/social_auth_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    context.read<SettingsProvider>().markWelcomeSeen();
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Column(
        children: [
          const AuthHeroBanner(heightFraction: 0.45),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -32),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(36),
                  topRight: Radius.circular(36),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 20,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const Text(
                                  'Welcome Back!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF130B3A),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Login to continue your journey',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7A7395),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          AuthTextField(
                            controller: _emailController,
                            placeholder: 'Enter your email or username',
                            prefixIcon: Icons.person_outline,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AuthTextField(
                                controller: _passwordController,
                                placeholder: 'Enter your password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF5B2BEA),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AuthPrimaryButton(label: 'Login', onPressed: _handleLogin),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              const Expanded(child: Divider(color: Color(0xFFEEEAFF))),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'or continue with',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: const Color(0xFF7A7395).withAlpha(150),
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider(color: Color(0xFFEEEAFF))),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              SocialAuthButton(
                                label: 'Google',
                                icon: Icons.g_mobiledata,
                                iconColor: const Color(0xFFDB4437),
                              ),
                              const SizedBox(width: 16),
                              SocialAuthButton(
                                label: 'Apple',
                                icon: Icons.apple,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pushReplacementNamed(context, '/register'),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(fontSize: 14, color: Color(0xFF7A7395)),
                                  children: [
                                    TextSpan(text: "Don't have an account? "),
                                    TextSpan(
                                      text: 'Sign Up',
                                      style: TextStyle(
                                        color: Color(0xFF5B2BEA),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
