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

  List<Activity> getUpcomingActivities(String tripId) {
    final now = DateTime.now();
    return getActivitiesForTrip(tripId)
        .where((a) => a.date.isAfter(now.subtract(const Duration(days: 1))))
        .toList();
  }

  List<Activity> getPastActivities(String tripId) {
    return getActivitiesForTrip(tripId)
        .where((a) => a.date.isBefore(DateTime.now()))
        .toList();
  }

  List<Activity> searchActivities(String tripId, String query) {
    if (query.isEmpty) return getActivitiesForTrip(tripId);
    final lower = query.toLowerCase();
    return getActivitiesForTrip(tripId)
        .where((a) => a.name.toLowerCase().contains(lower))
        .toList();
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

  void updateActivity(
    String id,
    String name,
    String? details,
    DateTime date,
    String? timeText,
    String? referenceLink,
  ) {
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) return;
    _activities[index].name = name;
    _activities[index].details = details;
    _activities[index].date = date;
    _activities[index].timeText = timeText;
    _activities[index].referenceLink = referenceLink;
    _activities[index].updatedAt = DateTime.now();
    LocalStorageService.saveActivities(_activities);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'activities',
      tripId: _activities[index].tripId,
      entityId: id,
      data: _activities[index].toMap(),
    );
  }

  Activity? getActivityById(String id) {
    try {
      return _activities.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
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
