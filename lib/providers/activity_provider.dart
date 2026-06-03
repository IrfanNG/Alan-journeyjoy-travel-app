import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/activity_model.dart';
import '../data/services/local_storage_service.dart';

class ActivityProvider extends ChangeNotifier {
  List<Activity> _activities = [];

  void loadActivities() {
    _activities = LocalStorageService.getActivities();
    notifyListeners();
  }

  List<Activity> getActivitiesForTrip(String tripId) {
    return _activities.where((a) => a.tripId == tripId).toList();
  }

  void addActivity(
    String tripId,
    String name,
    String? details,
    DateTime date,
    String? timeText,
    String? referenceLink,
  ) {
    final activity = Activity(
      id: const Uuid().v4(),
      tripId: tripId,
      name: name,
      details: details,
      date: date,
      timeText: timeText,
      referenceLink: referenceLink,
    );
    _activities.add(activity);
    LocalStorageService.saveActivities(_activities);
    notifyListeners();
  }

  void deleteActivity(String id) {
    _activities.removeWhere((a) => a.id == id);
    LocalStorageService.saveActivities(_activities);
    notifyListeners();
  }

  void deleteByTripId(String tripId) {
    _activities.removeWhere((a) => a.tripId == tripId);
    LocalStorageService.saveActivities(_activities);
    notifyListeners();
  }

  void clear() {
    _activities.clear();
    LocalStorageService.saveActivities(_activities);
    notifyListeners();
  }
}
