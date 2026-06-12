import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/routes.dart';
import 'app/theme.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/sync_service.dart';
import 'firebase_options.dart';
import 'providers/activity_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/document_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/flight_provider.dart';
import 'providers/itinerary_provider.dart';
import 'providers/packing_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/trip_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await LocalStorageService.init();
  await NotificationService.init();
  runApp(const JourneyJoyApp());
}

class JourneyJoyApp extends StatefulWidget {
  const JourneyJoyApp({super.key});

  @override
  State<JourneyJoyApp> createState() => _JourneyJoyAppState();
}

class _JourneyJoyAppState extends State<JourneyJoyApp> {
  late final SyncService _syncService;
  late final AuthProvider _authProvider;
  late final TripProvider _tripProvider;
  late final ExpenseProvider _expenseProvider;
  late final FlightProvider _flightProvider;
  late final ActivityProvider _activityProvider;
  late final PackingProvider _packingProvider;
  late final DocumentProvider _documentProvider;
  late final ItineraryProvider _itineraryProvider;
  late final SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _syncService = SyncService();
    _authProvider = AuthProvider(
      syncService: _syncService,
      onAfterSync: _syncAndReload,
    );
    _tripProvider = TripProvider(syncService: _syncService)..loadTrips();
    _expenseProvider = ExpenseProvider(syncService: _syncService)
      ..loadExpenses();
    _flightProvider = FlightProvider(syncService: _syncService)
      ..loadFlights();
    _activityProvider = ActivityProvider(syncService: _syncService)
      ..loadActivities();
    _packingProvider = PackingProvider(syncService: _syncService)
      ..loadItems();
    _documentProvider = DocumentProvider(syncService: _syncService)
      ..loadDocuments();
    _itineraryProvider = ItineraryProvider(syncService: _syncService)
      ..loadDays();
    _settingsProvider = SettingsProvider(syncService: _syncService)
      ..loadSettings();
  }

  Future<void> _syncAndReload() async {
    _tripProvider.loadTrips();
    _expenseProvider.loadExpenses();
    _flightProvider.loadFlights();
    _activityProvider.loadActivities();
    _packingProvider.loadItems();
    _documentProvider.loadDocuments();
    _itineraryProvider.loadDays();
    _settingsProvider.loadSettings();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final builder = AppRoutes.routes[settings.name];
    if (builder == null) return null;

    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 200),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, secondaryAnimation, tertiaryAnimation) =>
          builder(context),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _tripProvider),
        ChangeNotifierProvider.value(value: _expenseProvider),
        ChangeNotifierProvider.value(value: _flightProvider),
        ChangeNotifierProvider.value(value: _activityProvider),
        ChangeNotifierProvider.value(value: _packingProvider),
        ChangeNotifierProvider.value(value: _documentProvider),
        ChangeNotifierProvider.value(value: _itineraryProvider),
        ChangeNotifierProvider.value(value: _settingsProvider),
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
            onGenerateRoute: _onGenerateRoute,
          );
        },
      ),
    );
  }
}
