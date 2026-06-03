import 'package:flutter/material.dart';

import '../screens/activity/activity_screen.dart';
import '../screens/add_trip/add_trip_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/expense/expense_screen.dart';
import '../screens/flight/flight_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/packing/packing_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/trip_detail/trip_detail_screen.dart';
import '../screens/welcome/welcome_screen.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/splash': (_) => const SplashScreen(),
    '/welcome': (_) => const WelcomeScreen(),
    '/register': (_) => const RegisterScreen(),
    '/login': (_) => const LoginScreen(),
    '/home': (_) => const HomeScreen(),
    '/add-trip': (_) => const AddTripScreen(),
    '/trip-detail': (_) => const TripDetailScreen(),
    '/expenses': (_) => const ExpenseScreen(),
    '/flights': (_) => const FlightScreen(),
    '/activities': (_) => const ActivityScreen(),
    '/packing': (_) => const PackingScreen(),
    '/settings': (_) => const SettingsScreen(),
  };

  static String initialRoute = '/splash';
}
