import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/activity_model.dart';
import '../models/app_settings_model.dart';
import '../models/document_model.dart';
import '../models/expense_model.dart';
import '../models/flight_model.dart';
import '../models/itinerary_day_model.dart';
import '../models/packing_item_model.dart';
import '../models/trip_model.dart';

class LocalStorageService {
  static late Box _tripBox;
  static late Box _expenseBox;
  static late Box _flightBox;
  static late Box _activityBox;
  static late Box _packingBox;
  static late Box _settingsBox;
  static late Box _pendingBox;
  static late Box _documentBox;
  static late Box _itineraryBox;

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
    _pendingBox = await Hive.openBox('pending');
    _documentBox = await Hive.openBox('documents');
    _itineraryBox = await Hive.openBox('itinerary');
  }

  static List<Map<String, dynamic>> _getPendingList() {
    final data = _pendingBox.get('changes');
    if (data == null) return [];
    return (jsonDecode(data) as List).cast<Map<String, dynamic>>();
  }

  static void addPendingChange(Map<String, dynamic> change) {
    final changes = _getPendingList();
    changes.add(change);
    _pendingBox.put('changes', jsonEncode(changes));
  }

  static List<Map<String, dynamic>> getRawPendingChanges() {
    return _getPendingList();
  }

  static void removePendingChange(String entityId) {
    final changes = _getPendingList();
    changes.removeWhere((c) => c['entityId'] == entityId);
    _pendingBox.put('changes', jsonEncode(changes));
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

  static String? getActiveUserId() {
    return _settingsBox.get('activeUserId') as String?;
  }

  static Future<void> saveActiveUserId(String uid) async {
    await _settingsBox.put('activeUserId', uid);
  }

  static List<Document> getDocuments() {
    final data = _documentBox.get('documents');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => Document.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static void saveDocuments(List<Document> documents) {
    _documentBox.put(
        'documents', jsonEncode(documents.map((d) => d.toMap()).toList()));
  }

  static List<ItineraryDay> getItineraryDays() {
    final data = _itineraryBox.get('itinerary');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((e) => ItineraryDay.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static void saveItineraryDays(List<ItineraryDay> days) {
    _itineraryBox.put(
        'itinerary', jsonEncode(days.map((d) => d.toMap()).toList()));
  }

  static Future<void> clearUserTravelData() async {
    await _tripBox.clear();
    await _expenseBox.clear();
    await _flightBox.clear();
    await _activityBox.clear();
    await _packingBox.clear();
    await _pendingBox.clear();
    await _documentBox.clear();
    await _itineraryBox.clear();
  }

  static Future<void> clearAll() async {
    await _tripBox.clear();
    await _expenseBox.clear();
    await _flightBox.clear();
    await _activityBox.clear();
    await _packingBox.clear();
    await _settingsBox.clear();
    await _pendingBox.clear();
    await _documentBox.clear();
    await _itineraryBox.clear();
  }
}
