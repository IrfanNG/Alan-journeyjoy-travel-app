import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/flight_model.dart';
import '../data/services/local_storage_service.dart';

class FlightProvider extends ChangeNotifier {
  List<Flight> _flights = [];

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
  }

  void deleteFlight(String id) {
    _flights.removeWhere((f) => f.id == id);
    LocalStorageService.saveFlights(_flights);
    notifyListeners();
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
