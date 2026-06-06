import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/trip_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';

class TripProvider extends ChangeNotifier {
  final SyncService? _syncService;
  List<Trip> _trips = [];

  TripProvider({SyncService? syncService}) : _syncService = syncService;

  List<Trip> get trips => _trips;

  void loadTrips() {
    _trips = LocalStorageService.getTrips();
    notifyListeners();
  }

  Trip addTrip(String name, String colorHex) {
    final trip = Trip(
      id: const Uuid().v4(),
      name: name,
      colorHex: colorHex,
    );
    _trips.add(trip);
    LocalStorageService.saveTrips(_trips);
    notifyListeners();
    _syncService?.syncCreate(
      entityType: 'trips',
      entityId: trip.id,
      data: trip.toMap(),
    );
    return trip;
  }

  void deleteTrip(String id) {
    _trips.removeWhere((t) => t.id == id);
    LocalStorageService.saveTrips(_trips);
    notifyListeners();
    _syncService?.syncDelete(
      entityType: 'trips',
      entityId: id,
    );
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
