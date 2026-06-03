import 'package:flutter/material.dart';

class JJColors {
  static const Color primaryPurple = Color(0xFF5B2BEA);
  static const Color deepPurple = Color(0xFF32158F);
  static const Color brightPurple = Color(0xFF6A35F4);
  static const Color lightBg = Color(0xFFF8F7FF);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF130B3A);
  static const Color textMuted = Color(0xFF7A7395);
  static const Color successGreen = Color(0xFF58C783);
  static const Color warningOrange = Color(0xFFF59E23);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color lightPurpleBg = Color(0xFFEEEAFF);

  static const List<Color> tripColors = [
    Color(0xFF5B2BEA),
    Color(0xFF58C783),
    Color(0xFFF59E23),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFFEC4899),
    Color(0xFF14B8A6),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> gradientPurple = [deepPurple, brightPurple];
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: JJColors.primaryPurple,
    scaffoldBackgroundColor: JJColors.lightBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: JJColors.primaryPurple,
      brightness: Brightness.light,
      primary: JJColors.primaryPurple,
      secondary: JJColors.successGreen,
      tertiary: JJColors.warningOrange,
      error: JJColors.errorRed,
      surface: JJColors.cardBg,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: JJColors.textDark,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: JJColors.cardBg,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: JJColors.primaryPurple,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: JJColors.primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: JJColors.lightBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: JJColors.primaryPurple.withAlpha(30)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: JJColors.primaryPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: JJColors.textMuted),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEAFF),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: JJColors.textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: JJColors.textDark,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: JJColors.textDark,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: JJColors.textDark,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: JJColors.textDark),
      bodyMedium: TextStyle(fontSize: 14, color: JJColors.textMuted),
      bodySmall: TextStyle(fontSize: 12, color: JJColors.textMuted),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: JJColors.primaryPurple,
      unselectedItemColor: JJColors.textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: JJColors.primaryPurple,
    scaffoldBackgroundColor: const Color(0xFF0D0D1A),
    colorScheme: ColorScheme.fromSeed(
      seedColor: JJColors.primaryPurple,
      brightness: Brightness.dark,
      primary: JJColors.primaryPurple,
      secondary: JJColors.successGreen,
      tertiary: JJColors.warningOrange,
      error: JJColors.errorRed,
      surface: const Color(0xFF1A1A2E),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: const Color(0xFF1A1A2E),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: JJColors.primaryPurple,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: JJColors.primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: JJColors.primaryPurple.withAlpha(50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: JJColors.primaryPurple, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: const TextStyle(color: JJColors.textMuted),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A3E),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white70),
      bodyMedium: TextStyle(fontSize: 14, color: Colors.white54),
      bodySmall: TextStyle(fontSize: 12, color: Colors.white38),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1A1A2E),
      selectedItemColor: JJColors.primaryPurple,
      unselectedItemColor: Colors.white38,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
