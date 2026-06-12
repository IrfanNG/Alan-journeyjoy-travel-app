import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/itinerary_day_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';

class ItineraryProvider extends ChangeNotifier {
  final SyncService? _syncService;
  List<ItineraryDay> _days = [];

  ItineraryProvider({SyncService? syncService}) : _syncService = syncService;

  List<ItineraryDay> get days => _days;

  List<ItineraryDay> getDaysForTrip(String tripId) =>
      _days.where((d) => d.tripId == tripId).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

  ItineraryDay? getDayForDate(String tripId, DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    try {
      return _days.firstWhere((d) =>
          d.tripId == tripId &&
          DateTime(d.date.year, d.date.month, d.date.day) == normalized);
    } catch (_) {
      return null;
    }
  }

  void loadDays() {
    _days = LocalStorageService.getItineraryDays();
    notifyListeners();
  }

  ItineraryDay addDay(String tripId, DateTime date, {String? notes}) {
    final existing = getDayForDate(tripId, date);
    if (existing != null) return existing;

    final day = ItineraryDay(
      id: const Uuid().v4(),
      tripId: tripId,
      date: DateTime(date.year, date.month, date.day),
      notes: notes,
    );
    _days.add(day);
    LocalStorageService.saveItineraryDays(_days);
    notifyListeners();
    _syncService?.syncCreate(
      entityType: 'itinerary',
      tripId: tripId,
      entityId: day.id,
      data: day.toMap(),
    );
    return day;
  }

  void updateDayNotes(String id, String? notes) {
    final index = _days.indexWhere((d) => d.id == id);
    if (index == -1) return;
    _days[index].notes = notes;
    _days[index].updatedAt = DateTime.now();
    LocalStorageService.saveItineraryDays(_days);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'itinerary',
      tripId: _days[index].tripId,
      entityId: id,
      data: _days[index].toMap(),
    );
  }

  void deleteDay(String id) {
    final day = _days.firstWhere((d) => d.id == id);
    _days.removeWhere((d) => d.id == id);
    LocalStorageService.saveItineraryDays(_days);
    notifyListeners();
    _syncService?.syncDelete(
      entityType: 'itinerary',
      tripId: day.tripId,
      entityId: id,
    );
  }

  void deleteByTripId(String tripId) {
    _days.removeWhere((d) => d.tripId == tripId);
    LocalStorageService.saveItineraryDays(_days);
    notifyListeners();
  }

  void clear() {
    _days.clear();
    LocalStorageService.saveItineraryDays(_days);
    notifyListeners();
  }
}
