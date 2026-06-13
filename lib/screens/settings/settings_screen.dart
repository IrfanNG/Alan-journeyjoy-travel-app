import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../data/models/app_settings_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/trip_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: context.jj.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 24,
              right: 24,
              bottom: 32,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: JJColors.gradientPurple,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                  Row(children: [const JJBackButton(), const Spacer()]),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          bottom: 0,
                          left: -10,
                          right: -10,
                          child: CustomPaint(
                            size: const Size(300, 40),
                            painter: _HillPainter(
                              color: Colors.white.withAlpha(15),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          left: 40,
                          child: Icon(
                            Icons.nights_stay,
                            size: 22,
                            color: Colors.white.withAlpha(60),
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 50,
                          child: Icon(
                            Icons.star,
                            size: 10,
                            color: Colors.white.withAlpha(50),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 70,
                          child: Icon(
                            Icons.star,
                            size: 6,
                            color: Colors.white.withAlpha(35),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 60,
                          child: Icon(
                            Icons.terrain,
                            size: 28,
                            color: Colors.white.withAlpha(30),
                          ),
                        ),
                        Positioned(
                          bottom: 22,
                          right: 30,
                          child: Icon(
                            Icons.local_fire_department,
                            size: 20,
                            color: Colors.white.withAlpha(40),
                          ),
                        ),
                        Positioned(
                          top: 15,
                          left: 70,
                          child: Icon(
                            Icons.flight,
                            size: 18,
                            color: Colors.white.withAlpha(45),
                          ),
                        ),
                        Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.white.withAlpha(60),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _displayName(context, settingsProvider.settings),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Customize your experience',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                children: [
                    _sectionHeader(context, 'Profile'),
                    const SizedBox(height: 8),
                    _settingTile(context,
                      icon: Icons.person_outline,
                    title: 'Username',
                    subtitle:
                        settingsProvider.settings.username ?? 'Set your name',
                    onTap: () => _showUsernameDialog(context),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(context, 'Preferences'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => settingsProvider.setDarkMode(
                      !settingsProvider.isDarkMode,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: context.jj.card,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: context.jj.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: JJColors.warningOrange.withAlpha(20),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.dark_mode_outlined,
                              color: JJColors.warningOrange,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: context.jj.text,
                              ),
                            ),
                          ),
                          Switch(
                            value: settingsProvider.isDarkMode,
                            onChanged: (v) => settingsProvider.setDarkMode(v),
                            activeThumbColor: JJColors.primaryPurple,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: context.jj.card,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: context.jj.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: JJColors.primaryPurple.withAlpha(20),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: JJColors.primaryPurple,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Push Notification',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: context.jj.text,
                                ),
                              ),
                              Text(
                                'Trip and activity reminders',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: context.jj.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: settingsProvider.notificationsEnabled,
                          onChanged: (v) =>
                              settingsProvider.setNotificationsEnabled(v),
                          activeThumbColor: JJColors.primaryPurple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _settingTile(context,
                    icon: Icons.info_outline,
                    title: 'About Journey Joy',
                    subtitle: 'Version 1.0.0',
                    onTap: () => _showAboutJourneyJoy(context),
                  ),
                  const SizedBox(height: 24),
                  _sectionHeader(context, 'Data'),
                  const SizedBox(height: 8),
                  _settingTile(context,
                    icon: Icons.delete_outline,
                    title: 'Clear All Data',
                    subtitle: 'Remove all trips and data',
                    iconColor: JJColors.errorRed,
                    onTap: () => _confirmClear(context),
                  ),
                  _settingTile(context,
                    icon: Icons.logout,
                    title: 'Sign Out',
                    subtitle: 'Sign out of your account',
                    iconColor: JJColors.errorRed,
                    onTap: () => _confirmLogout(context),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.more,
        onCenterTap: () => Navigator.pushNamed(context, '/add-trip'),
        onTabTap: (tab) {
          final tp = context.read<TripProvider>();
          final tripId = tp.trips.isNotEmpty ? tp.trips.first.id : '';
          switch (tab) {
            case JJBottomNavTab.home:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case JJBottomNavTab.trips:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                  context,
                  '/trip-detail',
                  arguments: tripId,
                );
              } else {
                Navigator.pushReplacementNamed(context, '/home');
              }
              break;
            case JJBottomNavTab.expenses:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                  context,
                  '/expenses',
                  arguments: tripId,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create a trip first')),
                );
              }
              break;
            case JJBottomNavTab.more:
              break;
          }
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.jj.muted.withAlpha(150),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _settingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.jj.card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: context.jj.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? JJColors.primaryPurple).withAlpha(20),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor ?? JJColors.primaryPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: context.jj.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.jj.muted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.jj.muted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showUsernameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: context.read<SettingsProvider>().settings.username ?? '',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Set Username'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: context.jj.muted.withAlpha(100)),
            filled: true,
            fillColor: context.jj.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<SettingsProvider>().setUsername(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text(
              'Save',
              style: TextStyle(color: JJColors.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: JJColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutJourneyJoy(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Journey Joy',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.travel_explore, size: 48),
      children: const [
        Text(
          'Journey Joy is an offline-first travel planner for trips, expenses, flights, activities, packing, and itinerary planning.',
        ),
      ],
    );
  }

  String _displayName(BuildContext context, AppSettings settings) {
    final localName = settings.username?.trim();
    if (localName != null && localName.isNotEmpty) return localName;
    final auth = context.read<AuthProvider>();
    final fbName = auth.user?.displayName?.trim();
    if (fbName != null && fbName.isNotEmpty) return fbName;
    final email = auth.user?.email;
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Traveler';
  }

  void _confirmClear(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear All Data'),
        content: const Text(
          'This will remove all your trips, expenses, flights, activities, and packing items. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsProvider>().clearCache();
              Navigator.pop(ctx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/welcome',
                (route) => false,
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: JJColors.errorRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _HillPainter extends CustomPainter {
  final Color color;
  _HillPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width * 0.25, size.height * 0.3)
      ..lineTo(size.width * 0.5, size.height * 0.6)
      ..lineTo(size.width * 0.75, size.height * 0.2)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
