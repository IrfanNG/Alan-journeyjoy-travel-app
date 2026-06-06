import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/activity_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';

class ActivityProvider extends ChangeNotifier {
  final SyncService? _syncService;
  List<Activity> _activities = [];

  ActivityProvider({SyncService? syncService}) : _syncService = syncService;

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
    _syncService?.syncCreate(
      entityType: 'activities',
      tripId: tripId,
      entityId: activity.id,
      data: activity.toMap(),
    );
  }

  void deleteActivity(String id) {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) return;
    final tripId = _activities[index].tripId;
    _activities.removeAt(index);
    LocalStorageService.saveActivities(_activities);
    notifyListeners();
    _syncService?.syncDelete(
      entityType: 'activities',
      tripId: tripId,
      entityId: id,
    );
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
