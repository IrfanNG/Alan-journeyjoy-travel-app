import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'data/services/local_storage_service.dart';
import 'providers/activity_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/flight_provider.dart';
import 'providers/packing_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/trip_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(const JourneyJoyApp());
}

class JourneyJoyApp extends StatelessWidget {
  const JourneyJoyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()..loadTrips()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()..loadExpenses()),
        ChangeNotifierProvider(create: (_) => FlightProvider()..loadFlights()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()..loadActivities()),
        ChangeNotifierProvider(create: (_) => PackingProvider()..loadItems()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Journey Joy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: AppRoutes.initialRoute,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
