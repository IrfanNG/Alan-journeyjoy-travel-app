import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/trip_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';
import '../services/notification_service.dart';

class TripProvider extends ChangeNotifier {
  final SyncService? _syncService;
  List<Trip> _trips = [];

  TripProvider({SyncService? syncService}) : _syncService = syncService;

  List<Trip> get trips => _trips;

  void loadTrips() {
    _trips = LocalStorageService.getTrips();
    notifyListeners();
  }

  Trip addTrip(String name, String colorHex,
      {DateTime? startDate, DateTime? endDate}) {
    final trip = Trip(
      id: const Uuid().v4(),
      name: name,
      colorHex: colorHex,
      startDate: startDate,
      endDate: endDate,
    );
    _trips.add(trip);
    LocalStorageService.saveTrips(_trips);
    notifyListeners();
    _syncService?.syncCreate(
      entityType: 'trips',
      entityId: trip.id,
      data: trip.toMap(),
    );
    if (trip.startDate != null &&
        LocalStorageService.getSettings().notificationsEnabled) {
      NotificationService.scheduleTripReminder(
          trip.id, trip.name, trip.startDate!);
    }
    return trip;
  }

  void deleteTrip(String id) {
    NotificationService.cancelTripReminder(id);
    _trips.removeWhere((t) => t.id == id);
    LocalStorageService.saveTrips(_trips);
    notifyListeners();
    _syncService?.syncDelete(
      entityType: 'trips',
      entityId: id,
    );
  }

  void updateTrip(String id, String name, String colorHex,
      {DateTime? startDate, DateTime? endDate}) {
    final index = _trips.indexWhere((t) => t.id == id);
    if (index == -1) return;
    _trips[index].name = name;
    _trips[index].colorHex = colorHex;
    _trips[index].startDate = startDate;
    _trips[index].endDate = endDate;
    _trips[index].updatedAt = DateTime.now();
    LocalStorageService.saveTrips(_trips);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'trips',
      entityId: id,
      data: _trips[index].toMap(),
    );
    if (startDate != null &&
        LocalStorageService.getSettings().notificationsEnabled) {
      NotificationService.scheduleTripReminder(
          id, _trips[index].name, startDate);
    } else if (startDate == null) {
      NotificationService.cancelTripReminder(id);
    }
  }

  Trip? getTripById(String id) {
    try {
      return _trips.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    _trips.clear();
    LocalStorageService.saveTrips(_trips);
    notifyListeners();
  }
}
