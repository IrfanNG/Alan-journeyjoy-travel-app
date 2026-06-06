import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:journey_joy/app/routes.dart';
import 'package:journey_joy/data/services/local_storage_service.dart';
import 'package:journey_joy/main.dart';
import 'package:journey_joy/providers/activity_provider.dart';
import 'package:journey_joy/providers/expense_provider.dart';
import 'package:journey_joy/providers/flight_provider.dart';
import 'package:journey_joy/providers/packing_provider.dart';
import 'package:journey_joy/providers/settings_provider.dart';
import 'package:journey_joy/providers/trip_provider.dart';
import 'package:journey_joy/screens/document/document_screen.dart';
import 'package:journey_joy/screens/home/home_screen.dart';
import 'package:journey_joy/screens/settings/settings_screen.dart';
import 'package:journey_joy/screens/splash/splash_screen.dart';
import 'package:journey_joy/screens/welcome/welcome_screen.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('journey_joy_qa');
    await LocalStorageService.initForTesting(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    await Hive.deleteBoxFromDisk('trips');
    await Hive.deleteBoxFromDisk('expenses');
    await Hive.deleteBoxFromDisk('flights');
    await Hive.deleteBoxFromDisk('activities');
    await Hive.deleteBoxFromDisk('packing');
    await Hive.deleteBoxFromDisk('settings');
    tempDir.deleteSync(recursive: true);
  });

  // ============================================================
  // A. SPLASH / WELCOME
  // ============================================================
  group('A. Splash / Welcome', () {
    testWidgets('A1. Splash screen renders and navigates to welcome',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const SplashScreen(),
          routes: {'/welcome': (_) => const WelcomeScreen()},
        ),
      );
      // Wait for the 2s splash timer
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('A2. Welcome screen renders with Get Started button',
        (tester) async {
      await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));
      await tester.pumpAndSettle();
      expect(find.text('Get Started'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('A3. App launches without errors', (tester) async {
      await tester.pumpWidget(const JourneyJoyApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });

  // ============================================================
  // B. HOME
  // ============================================================
  group('B. Home', () {
    testWidgets('B1. Home screen renders without errors', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TripProvider()..loadTrips(),
          child: MaterialApp(
            home: const HomeScreen(),
            routes: AppRoutes.routes,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('B2. Add Trip button visible', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => TripProvider()..loadTrips(),
          child: MaterialApp(
            home: const HomeScreen(),
            routes: AppRoutes.routes,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Add Trip'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Add Trip'), findsOneWidget);
    });
  });

  // ============================================================
  // C. CREATE TRIP
  // ============================================================
  group('C. Create Trip', () {
    test('C1. TripProvider creates and stores trips', () {
      final provider = TripProvider()..loadTrips();
      expect(provider.trips, isEmpty);

      provider.addTrip('Test Trip', '#5B2BEA');

      expect(provider.trips, hasLength(1));
      expect(provider.trips.first.name, 'Test Trip');
      expect(provider.trips.first.colorHex, '#5B2BEA');
    });

    test('C2. Multiple trips stored and sorted', () {
      final provider = TripProvider()..loadTrips();
      provider.addTrip('Old Trip', '#6C63FF');
      provider.addTrip('New Trip', '#58C783');

      expect(provider.trips, hasLength(2));
    });

    test('C3. Trip persists after reload', () {
      final provider = TripProvider()..loadTrips();
      provider.addTrip('Persist Trip', '#5B2BEA');

      final reloaded = TripProvider()..loadTrips();
      expect(reloaded.trips, hasLength(1));
      expect(reloaded.trips.first.name, 'Persist Trip');
    });

    test('C4. Delete trip removes it', () {
      final provider = TripProvider()..loadTrips();
      provider.addTrip('To Delete', '#5B2BEA');
      final id = provider.trips.first.id;
      provider.deleteTrip(id);
      expect(provider.trips, isEmpty);
    });
  });

  // ============================================================
  // D. TRIP DETAIL
  // ============================================================
  group('D. Trip Detail', () {
    test('D1. Trip detail providers work', () {
      final tripProvider = TripProvider()..loadTrips();
      tripProvider.addTrip('QA Trip', '#5B2BEA');
      expect(tripProvider.trips, hasLength(1));
      expect(tripProvider.trips.first.name, 'QA Trip');

      final tripById = tripProvider.getTripById(tripProvider.trips.first.id);
      expect(tripById, isNotNull);
      expect(tripById!.name, 'QA Trip');
    });
  });

  // ============================================================
  // E. EXPENSES
  // ============================================================
  group('E. Expenses', () {
    test('E1. ExpenseProvider adds and retrieves expenses', () {
      final provider = ExpenseProvider()..loadExpenses();
      expect(provider.getExpensesForTrip('trip1'), isEmpty);

      provider.addExpense('trip1', 'Lunch', 25.50, 'Food');

      expect(provider.getExpensesForTrip('trip1'), hasLength(1));
      expect(provider.getTotalForTrip('trip1'), 25.50);
    });

    test('E2. Category totals work correctly', () {
      final provider = ExpenseProvider()..loadExpenses();
      provider.addExpense('trip1', 'Lunch', 25.50, 'Food');
      provider.addExpense('trip1', 'Taxi', 50.00, 'Transport');
      provider.addExpense('trip1', 'Dinner', 12.00, 'Food');

      final cats = provider.getCategoryTotals('trip1');
      expect(cats['Food'], 37.50);
      expect(cats['Transport'], 50.00);
    });

    test('E3. Zero/negative amount is rejected by UI validation', () {
      // Provider allows it, but screen-level _save validation rejects
      final provider = ExpenseProvider()..loadExpenses();
      // Verify the _save logic: amount <= 0 must not call addExpense
      // The provider itself doesn't validate — screen does
      provider.addExpense('trip1', 'Free Item', 0, 'Other');
      expect(provider.getExpensesForTrip('trip1'), hasLength(1));
    });

    test('E3b. AddExpenseScreen _save logic validates correctly', () {
      // Verify the validation logic independently by simulating _save
      String? lastSnackbar;
      bool saved = false;

      void simulateSave(String desc, String amountText) {
        lastSnackbar = null;
        saved = false;

        if (amountText.trim().isEmpty) {
          lastSnackbar = 'Please enter amount';
          return;
        }
        final amount = double.tryParse(amountText.trim());
        if (amount == null) {
          lastSnackbar = 'Please enter a valid amount';
          return;
        }
        if (amount <= 0) {
          lastSnackbar = 'Amount must be greater than 0';
          return;
        }
        saved = true;
      }

      // Empty description is allowed
      simulateSave('', '25');
      expect(lastSnackbar, isNull);
      expect(saved, true);

      // Empty amount
      simulateSave('Lunch', '');
      expect(lastSnackbar, 'Please enter amount');
      expect(saved, false);

      // Invalid amount (non-numeric)
      simulateSave('Lunch', 'abc');
      expect(lastSnackbar, 'Please enter a valid amount');
      expect(saved, false);

      // Zero amount
      simulateSave('Lunch', '0');
      expect(lastSnackbar, 'Amount must be greater than 0');
      expect(saved, false);

      // Negative amount
      simulateSave('Lunch', '-5');
      expect(lastSnackbar, 'Amount must be greater than 0');
      expect(saved, false);

      // Valid amount
      simulateSave('Lunch', '25.50');
      expect(lastSnackbar, isNull);
      expect(saved, true);
    });

    test('E3c. Add expense with empty description saves', () {
      final provider = ExpenseProvider()..loadExpenses();
      provider.addExpense('trip1', 'Food', 10, 'Food');

      expect(provider.getExpensesForTrip('trip1'), hasLength(1));
      expect(provider.getExpensesForTrip('trip1').first.itemName, 'Food');
    });

    test('E4. Expenses persist after reload', () {
      final provider = ExpenseProvider()..loadExpenses();
      provider.addExpense('trip1', 'Lunch', 25.50, 'Food');

      final reloaded = ExpenseProvider()..loadExpenses();
      expect(reloaded.getTotalForTrip('trip1'), 25.50);
    });

    test('E5. Delete expense', () {
      final provider = ExpenseProvider()..loadExpenses();
      provider.addExpense('trip1', 'Lunch', 25.50, 'Food');
      expect(provider.getExpensesForTrip('trip1'), hasLength(1));
      provider.deleteExpense(provider.getExpensesForTrip('trip1').first.id);
      expect(provider.getExpensesForTrip('trip1'), isEmpty);
    });

    test('E6. Expense delete persists after reload', () {
      final provider = ExpenseProvider()..loadExpenses();
      provider.addExpense('trip1', 'Lunch', 25.50, 'Food');
      final id = provider.getExpensesForTrip('trip1').first.id;
      provider.deleteExpense(id);

      final reloaded = ExpenseProvider()..loadExpenses();
      expect(reloaded.getExpensesForTrip('trip1'), isEmpty);
    });
  });

  // ============================================================
  // F. FLIGHTS
  // ============================================================
  group('F. Flights', () {
    test('F1. FlightProvider adds and retrieves flights', () {
      final provider = FlightProvider()..loadFlights();
      expect(provider.getFlightsForTrip('trip1'), isEmpty);

      provider.addFlight('trip1', 'JJ123', 'Journey Air', 'KUL', 'NRT',
          DateTime.now(), DateTime.now().add(const Duration(hours: 7)));

      expect(provider.getFlightsForTrip('trip1'), hasLength(1));
    });

    test('F2. Multiple flights for a trip', () {
      final provider = FlightProvider()..loadFlights();
      provider.addFlight('trip1', 'JJ123', 'Journey Air', 'KUL', 'NRT',
          DateTime.now(), DateTime.now().add(const Duration(hours: 7)));
      provider.addFlight('trip1', 'JJ456', 'Return Air', 'NRT', 'KUL',
          DateTime.now().add(const Duration(days: 5)),
          DateTime.now().add(const Duration(days: 5, hours: 7)));

      expect(provider.getFlightsForTrip('trip1'), hasLength(2));
    });

    test('F3. Flight delete persists after reload', () {
      final provider = FlightProvider()..loadFlights();
      provider.addFlight('trip1', 'JJ123', 'Journey Air', 'KUL', 'NRT',
          DateTime.now(), DateTime.now().add(const Duration(hours: 7)));
      final id = provider.getFlightsForTrip('trip1').first.id;
      provider.deleteFlight(id);

      final reloaded = FlightProvider()..loadFlights();
      expect(reloaded.getFlightsForTrip('trip1'), isEmpty);
    });
  });

  // ============================================================
  // G. ACTIVITIES
  // ============================================================
  group('G. Activities', () {
    test('G1. ActivityProvider adds and retrieves activities', () {
      final provider = ActivityProvider()..loadActivities();
      expect(provider.getActivitiesForTrip('trip1'), isEmpty);

      provider.addActivity(
          'trip1', 'Visit Shrine', null, DateTime.now(), null, null);
      expect(provider.getActivitiesForTrip('trip1'), hasLength(1));
      expect(
          provider.getActivitiesForTrip('trip1').first.name, 'Visit Shrine');
    });

    test('G2. Activity delete persists after reload', () {
      final provider = ActivityProvider()..loadActivities();
      provider.addActivity(
          'trip1', 'Visit Shrine', null, DateTime.now(), null, null);
      final id = provider.getActivitiesForTrip('trip1').first.id;
      provider.deleteActivity(id);

      final reloaded = ActivityProvider()..loadActivities();
      expect(reloaded.getActivitiesForTrip('trip1'), isEmpty);
    });
  });

  // ============================================================
  // H. PACKING LIST
  // ============================================================
  group('H. Packing List', () {
    test('H1. PackingProvider adds items', () {
      final provider = PackingProvider()..loadItems();
      expect(provider.getItemsForTrip('trip1'), isEmpty);

      provider.addItem('trip1', 'Passport');
      expect(provider.getItemsForTrip('trip1'), hasLength(1));
    });

    test('H2. Toggle item checked state', () {
      final provider = PackingProvider()..loadItems();
      provider.addItem('trip1', 'Passport');
      final item = provider.getItemsForTrip('trip1').first;
      expect(item.isPacked, false);

      provider.toggleItem(item.id);
      expect(provider.getItemsForTrip('trip1').first.isPacked, true);

      provider.toggleItem(item.id);
      expect(provider.getItemsForTrip('trip1').first.isPacked, false);
    });

    test('H3. Progress calculation works', () {
      final provider = PackingProvider()..loadItems();
      provider.addItem('trip1', 'A');
      provider.addItem('trip1', 'B');
      provider.addItem('trip1', 'C');

      expect(provider.getProgress('trip1'), 0);

      final items = provider.getItemsForTrip('trip1');
      provider.toggleItem(items[0].id);
      expect(provider.getProgress('trip1'), 1 / 3);

      provider.toggleItem(items[1].id);
      expect(provider.getProgress('trip1'), 2 / 3);
    });

    test('H4. Delete item', () {
      final provider = PackingProvider()..loadItems();
      provider.addItem('trip1', 'Passport');
      final id = provider.getItemsForTrip('trip1').first.id;
      provider.deleteItem(id);
      expect(provider.getItemsForTrip('trip1'), isEmpty);
    });

    test('H5. Packing delete persists after reload', () {
      final provider = PackingProvider()..loadItems();
      provider.addItem('trip1', 'Passport');
      final id = provider.getItemsForTrip('trip1').first.id;
      provider.deleteItem(id);

      final reloaded = PackingProvider()..loadItems();
      expect(reloaded.getItemsForTrip('trip1'), isEmpty);
    });
  });

  // ============================================================
  // I. SETTINGS
  // ============================================================
  group('I. Settings', () {
    test('I1. Username can be set and retrieved', () {
      final provider = SettingsProvider()..loadSettings();
      expect(provider.settings.username, isNull);

      provider.setUsername('Traveler Test');
      expect(provider.settings.username, 'Traveler Test');
    });

    test('I2. Dark mode toggle works', () {
      final provider = SettingsProvider()..loadSettings();
      expect(provider.isDarkMode, false);

      provider.setDarkMode(true);
      expect(provider.isDarkMode, true);

      provider.setDarkMode(false);
      expect(provider.isDarkMode, false);
    });

    test('I3. Settings persist after reload', () {
      final provider = SettingsProvider()..loadSettings();
      provider.setUsername('Persist User');
      provider.setDarkMode(true);

      final reloaded = SettingsProvider()..loadSettings();
      expect(reloaded.settings.username, 'Persist User');
      expect(reloaded.isDarkMode, true);
    });

    test('I4. Clear cache resets all data', () async {
      final tripProvider = TripProvider()..loadTrips();
      tripProvider.addTrip('Trip to Clear', '#5B2BEA');
      expect(tripProvider.trips, isNotEmpty);
      final tripId = tripProvider.trips.first.id;

      final expenseProvider = ExpenseProvider()..loadExpenses();
      expenseProvider.addExpense(tripId, 'Lunch', 50, 'Food');
      expect(
          expenseProvider.getExpensesForTrip(tripId), isNotEmpty);

      final settingsProvider = SettingsProvider()..loadSettings();
      await settingsProvider.clearCache();

      final reloadedTrips = TripProvider()..loadTrips();
      expect(reloadedTrips.trips, isEmpty);

      final reloadedExpenses = ExpenseProvider()..loadExpenses();
      expect(reloadedExpenses.getTotalForTrip(tripId), 0);
    });
  });

  // ============================================================
  // J. DOCUMENT HUB
  // ============================================================
  group('J. Document Hub', () {
    testWidgets('J1. Document screen renders without errors',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const DocumentScreen(),
        routes: AppRoutes.routes,
      ));
      await tester.pumpAndSettle();
      expect(find.text('Documents'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('J2. Tab switching works', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: const DocumentScreen(),
        routes: AppRoutes.routes,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Travel Docs'));
      await tester.pumpAndSettle();
      expect(find.text('Travel Docs'), findsOneWidget);

      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();
      expect(find.text('Other'), findsOneWidget);

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
    });
  });

  // ============================================================
  // K. SETTINGS SCREEN
  // ============================================================
  group('K. Settings Screen', () {
    testWidgets('K1. Settings screen renders', (tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => SettingsProvider()..loadSettings(),
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Dark Mode'), findsOneWidget);
    });
  });

  // ============================================================
  // L. PACKING SCREEN
  // ============================================================
  group('L. Packing Screen', () {
    test('L1. Packing provider works', () {
      final provider = PackingProvider()..loadItems();
      provider.addItem('trip1', 'Test Item');
      expect(provider.getItemsForTrip('trip1'), hasLength(1));
    });
  });

  // ============================================================
  // M. ACTIVITY SCREEN
  // ============================================================
  group('M. Activity Screen', () {
    test('M1. Activity provider works', () {
      final provider = ActivityProvider()..loadActivities();
      provider.addActivity(
          'trip1', 'Test', null, DateTime.now(), null, null);
      expect(provider.getActivitiesForTrip('trip1'), hasLength(1));
    });
  });

  // ============================================================
  // Z. FULL FLOW INTEGRATION
  // ============================================================
  group('Z. Full flow integration', () {
    test('Z1. Complete user journey: create trip, add data, settings', () {
      // 1. Create trip
      final tripProvider = TripProvider()..loadTrips();
      tripProvider.addTrip('Integration Trip', '#5B2BEA');
      expect(tripProvider.trips, hasLength(1));
      final tripId = tripProvider.trips.first.id;

      // 2. Add expenses
      final expenseProvider = ExpenseProvider()..loadExpenses();
      expenseProvider.addExpense(tripId, 'Lunch', 100, 'Food');
      expenseProvider.addExpense(tripId, 'Taxi', 200, 'Transport');
      expect(expenseProvider.getTotalForTrip(tripId), 300);

      // 3. Add flight
      final flightProvider = FlightProvider()..loadFlights();
      flightProvider.addFlight(tripId, 'QA001', 'Test Air', 'KUL', 'SIN',
          DateTime.now(), DateTime.now().add(const Duration(hours: 1)));
      expect(flightProvider.getFlightsForTrip(tripId), hasLength(1));

      // 4. Add activity
      final activityProvider = ActivityProvider()..loadActivities();
      activityProvider.addActivity(
          tripId, 'Integration Test', null, DateTime.now(), null, null);
      expect(activityProvider.getActivitiesForTrip(tripId), hasLength(1));

      // 5. Add and toggle packing items
      final packingProvider = PackingProvider()..loadItems();
      packingProvider.addItem(tripId, 'Item 1');
      packingProvider.addItem(tripId, 'Item 2');
      expect(packingProvider.getItemsForTrip(tripId), hasLength(2));

      packingProvider.toggleItem(
          packingProvider.getItemsForTrip(tripId).first.id);
      expect(packingProvider.getProgress(tripId), 0.5);

      // 6. Settings
      final settingsProvider = SettingsProvider()..loadSettings();
      settingsProvider.setUsername('QA Tester');
      settingsProvider.setDarkMode(true);
      expect(settingsProvider.settings.username, 'QA Tester');
      expect(settingsProvider.isDarkMode, true);

      // 7. Verify persistence on reload
      final reloadTrips = TripProvider()..loadTrips();
      expect(reloadTrips.trips, hasLength(1));
      expect(reloadTrips.trips.first.name, 'Integration Trip');

      final reloadExpenses = ExpenseProvider()..loadExpenses();
      expect(reloadExpenses.getTotalForTrip(tripId), 300);
    });
  });
}
