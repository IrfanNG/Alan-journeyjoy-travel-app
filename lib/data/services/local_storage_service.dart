import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/activity_model.dart';
import '../models/app_settings_model.dart';
import '../models/expense_model.dart';
import '../models/flight_model.dart';
import '../models/packing_item_model.dart';
import '../models/trip_model.dart';

class LocalStorageService {
  static late Box _tripBox;
  static late Box _expenseBox;
  static late Box _flightBox;
  static late Box _activityBox;
  static late Box _packingBox;
  static late Box _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    await _openBoxes();
  }

  static Future<void> initForTesting(String path) async {
    Hive.init(path);
    await _openBoxes();
  }

  static Future<void> _openBoxes() async {
    _tripBox = await Hive.openBox('trips');
    _expenseBox = await Hive.openBox('expenses');
    _flightBox = await Hive.openBox('flights');
    _activityBox = await Hive.openBox('activities');
    _packingBox = await Hive.openBox('packing');
    _settingsBox = await Hive.openBox('settings');
  }

  static List<Trip> getTrips() {
    final data = _tripBox.get('trips');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => Trip.fromMap(e as Map<String, dynamic>)).toList();
  }

  static void saveTrips(List<Trip> trips) {
    _tripBox.put(
        'trips', jsonEncode(trips.map((t) => t.toMap()).toList()));
  }

  static List<Expense> getExpenses() {
    final data = _expenseBox.get('expenses');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => Expense.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static void saveExpenses(List<Expense> expenses) {
    _expenseBox.put(
        'expenses', jsonEncode(expenses.map((e) => e.toMap()).toList()));
  }

  static List<Flight> getFlights() {
    final data = _flightBox.get('flights');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => Flight.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static void saveFlights(List<Flight> flights) {
    _flightBox.put(
        'flights', jsonEncode(flights.map((f) => f.toMap()).toList()));
  }

  static List<Activity> getActivities() {
    final data = _activityBox.get('activities');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => Activity.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static void saveActivities(List<Activity> activities) {
    _activityBox.put('activities',
        jsonEncode(activities.map((a) => a.toMap()).toList()));
  }

  static List<PackingItem> getPackingItems() {
    final data = _packingBox.get('packing');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => PackingItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static void savePackingItems(List<PackingItem> items) {
    _packingBox.put(
        'packing', jsonEncode(items.map((i) => i.toMap()).toList()));
  }

  static AppSettings getSettings() {
    final data = _settingsBox.get('settings');
    if (data == null) return AppSettings();
    return AppSettings.fromMap(jsonDecode(data) as Map<String, dynamic>);
  }

  static void saveSettings(AppSettings settings) {
    _settingsBox.put('settings', jsonEncode(settings.toMap()));
  }

  static Future<void> clearAll() async {
    await _tripBox.clear();
    await _expenseBox.clear();
    await _flightBox.clear();
    await _activityBox.clear();
    await _packingBox.clear();
    await _settingsBox.clear();
  }
}
