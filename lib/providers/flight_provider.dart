import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/flight_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';

class FlightProvider extends ChangeNotifier {
  final SyncService? _syncService;
  List<Flight> _flights = [];

  FlightProvider({SyncService? syncService}) : _syncService = syncService;

  void loadFlights() {
    _flights = LocalStorageService.getFlights();
    notifyListeners();
  }

  List<Flight> getFlightsForTrip(String tripId) {
    return _flights.where((f) => f.tripId == tripId).toList();
  }

  void addFlight(
    String tripId,
    String flightNumber,
    String? airline,
    String fromLocation,
    String toLocation,
    DateTime departureTime,
    DateTime arrivalTime,
  ) {
    final flight = Flight(
      id: const Uuid().v4(),
      tripId: tripId,
      flightNumber: flightNumber,
      airline: airline,
      fromLocation: fromLocation,
      toLocation: toLocation,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
    );
    _flights.add(flight);
    LocalStorageService.saveFlights(_flights);
    notifyListeners();
    _syncService?.syncCreate(
      entityType: 'flights',
      tripId: tripId,
      entityId: flight.id,
      data: flight.toMap(),
    );
  }

  void deleteFlight(String id) {
    final index = _flights.indexWhere((f) => f.id == id);
    if (index == -1) return;
    final tripId = _flights[index].tripId;
    _flights.removeAt(index);
    LocalStorageService.saveFlights(_flights);
    notifyListeners();
    _syncService?.syncDelete(
      entityType: 'flights',
      tripId: tripId,
      entityId: id,
    );
  }

  void updateFlight(
    String id,
    String flightNumber,
    String? airline,
    String fromLocation,
    String toLocation,
    DateTime departureTime,
    DateTime arrivalTime,
  ) {
    final index = _flights.indexWhere((f) => f.id == id);
    if (index == -1) return;
    _flights[index].flightNumber = flightNumber;
    _flights[index].airline = airline;
    _flights[index].fromLocation = fromLocation;
    _flights[index].toLocation = toLocation;
    _flights[index].departureTime = departureTime;
    _flights[index].arrivalTime = arrivalTime;
    _flights[index].updatedAt = DateTime.now();
    LocalStorageService.saveFlights(_flights);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'flights',
      tripId: _flights[index].tripId,
      entityId: id,
      data: _flights[index].toMap(),
    );
  }

  Flight? getFlightById(String id) {
    try {
      return _flights.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  void deleteByTripId(String tripId) {
    _flights.removeWhere((f) => f.tripId == tripId);
    LocalStorageService.saveFlights(_flights);
    notifyListeners();
  }

  void clear() {
    _flights.clear();
    LocalStorageService.saveFlights(_flights);
    notifyListeners();
  }
}
