import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/trip_model.dart';
import '../data/services/local_storage_service.dart';

class TripProvider extends ChangeNotifier {
  List<Trip> _trips = [];

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
    return trip;
  }

  void deleteTrip(String id) {
    _trips.removeWhere((t) => t.id == id);
    LocalStorageService.saveTrips(_trips);
    notifyListeners();
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
