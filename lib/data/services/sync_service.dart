import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import '../../services/auth_service.dart';
import '../models/activity_model.dart';
import '../models/document_model.dart';
import '../models/expense_model.dart';
import '../models/flight_model.dart';
import '../models/itinerary_day_model.dart';
import '../models/packing_item_model.dart';
import '../models/trip_model.dart';
import 'local_storage_service.dart';
import 'remote_data_source.dart';

enum SyncStatus { idle, syncing, error }

class PendingChange {
  final String entityType;
  final String? tripId;
  final String entityId;
  final String action;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  PendingChange({
    required this.entityType,
    this.tripId,
    required this.entityId,
    required this.action,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'entityType': entityType,
        'tripId': tripId,
        'entityId': entityId,
        'action': action,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };

  factory PendingChange.fromMap(Map<String, dynamic> map) => PendingChange(
        entityType: map['entityType'] as String,
        tripId: map['tripId'] as String?,
        entityId: map['entityId'] as String,
        action: map['action'] as String,
        data: map['data'] as Map<String, dynamic>?,
        timestamp: DateTime.parse(map['timestamp'] as String),
      );
}

class SyncService {
  final RemoteDataSource _remoteDataSource;
  final AuthService _authService;
  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _isOnline = true;
  SyncStatus _status = SyncStatus.idle;

  SyncService({
    RemoteDataSource? remoteDataSource,
    AuthService? authService,
    Connectivity? connectivity,
  })  : _remoteDataSource = remoteDataSource ?? RemoteDataSource(),
        _authService = authService ?? AuthService(),
        _connectivity = connectivity ?? Connectivity() {
    _initConnectivity();
  }

  SyncStatus get status => _status;
  bool get isOnline => _isOnline;

  String? get _uid {
    try {
      return _authService.currentUser?.uid;
    } catch (_) {
      return null;
    }
  }

  bool get canSync {
    try {
      return _isOnline && _authService.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  void _initConnectivity() {
    _connectivity.checkConnectivity().then((result) {
      _isOnline = !result.contains(ConnectivityResult.none);
    });
    _connectivitySub =
        _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = !result.contains(ConnectivityResult.none);
      if (wasOffline && _isOnline) {
        _processPendingChanges();
      }
    });
  }

  Future<void> syncCreate({
    required String entityType,
    String? tripId,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    debugPrint('canSync=$canSync uid=$_uid online=$_isOnline entity=$entityType/$entityId');
    if (!canSync) {
      _addPendingChange('create', entityType, tripId, entityId, data);
      return;
    }
    try {
      final uid = _uid!;
      if (entityType == 'trips') {
        await _remoteDataSource.createTrip(uid, data);
      } else if (entityType == 'settings') {
        await _remoteDataSource.saveSettings(uid, data);
      } else if (tripId != null) {
        await _remoteDataSource.createSubEntity(
            uid, tripId, entityType, data);
      }
      debugPrint('Sync create succeeded: $entityType/$entityId');
    } catch (e, st) {
      debugPrint('Sync create failed: $entityType/$entityId -> $e');
      debugPrintStack(stackTrace: st);
      _addPendingChange('create', entityType, tripId, entityId, data);
    }
  }

  Future<void> syncUpdate({
    required String entityType,
    String? tripId,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    debugPrint('canSync=$canSync uid=$_uid online=$_isOnline entity=$entityType/$entityId');
    if (!canSync) {
      _addPendingChange('update', entityType, tripId, entityId, data);
      return;
    }
    try {
      final uid = _uid!;
      if (entityType == 'trips') {
        await _remoteDataSource.updateTrip(uid, entityId, data);
      } else if (entityType == 'settings') {
        await _remoteDataSource.saveSettings(uid, data);
      } else if (tripId != null) {
        await _remoteDataSource.updateSubEntity(
            uid, tripId, entityType, entityId, data);
      }
      debugPrint('Sync update succeeded: $entityType/$entityId');
    } catch (e, st) {
      debugPrint('Sync update failed: $entityType/$entityId -> $e');
      debugPrintStack(stackTrace: st);
      _addPendingChange('update', entityType, tripId, entityId, data);
    }
  }

  Future<void> syncDelete({
    required String entityType,
    String? tripId,
    required String entityId,
  }) async {
    debugPrint('canSync=$canSync uid=$_uid online=$_isOnline entity=$entityType/$entityId');
    if (!canSync) {
      _addPendingChange('delete', entityType, tripId, entityId, null);
      return;
    }
    try {
      final uid = _uid!;
      if (entityType == 'trips') {
        await _remoteDataSource.deleteTrip(uid, entityId);
      } else if (tripId != null) {
        await _remoteDataSource.deleteSubEntity(
            uid, tripId, entityType, entityId);
      }
      debugPrint('Sync delete succeeded: $entityType/$entityId');
    } catch (e, st) {
      debugPrint('Sync delete failed: $entityType/$entityId -> $e');
      debugPrintStack(stackTrace: st);
      _addPendingChange('delete', entityType, tripId, entityId, null);
    }
  }

  void _addPendingChange(String action, String entityType,
      String? tripId, String entityId, Map<String, dynamic>? data) {
    final change = PendingChange(
      entityType: entityType,
      tripId: tripId,
      entityId: entityId,
      action: action,
      data: data,
    );
    LocalStorageService.addPendingChange(change.toMap());
  }

  Future<void> _processPendingChanges() async {
    if (!canSync) {
      debugPrint('_processPendingChanges: cannot sync');
      return;
    }
    debugPrint('_processPendingChanges: starting');
    _status = SyncStatus.syncing;
    final rawChanges = LocalStorageService.getRawPendingChanges();
    if (rawChanges.isEmpty) {
      debugPrint('_processPendingChanges: no pending changes');
      _status = SyncStatus.idle;
      return;
    }
    debugPrint('_processPendingChanges: ${rawChanges.length} changes found');
    final changes = rawChanges.map(PendingChange.fromMap).toList();
    final uid = _uid!;
    for (final change in changes) {
      try {
        if (change.data != null &&
            (change.action == 'create' || change.action == 'update')) {
          if (change.entityType == 'trips') {
            if (change.action == 'create') {
              await _remoteDataSource.createTrip(uid, change.data!);
            } else {
              await _remoteDataSource.updateTrip(
                  uid, change.entityId, change.data!);
            }
          } else if (change.entityType == 'settings') {
            await _remoteDataSource.saveSettings(uid, change.data!);
          } else if (change.tripId != null) {
            if (change.action == 'create') {
              await _remoteDataSource.createSubEntity(uid, change.tripId!,
                  change.entityType, change.data!);
            } else {
              await _remoteDataSource.updateSubEntity(uid, change.tripId!,
                  change.entityType, change.entityId, change.data!);
            }
          }
        } else if (change.action == 'delete') {
          if (change.entityType == 'trips') {
            await _remoteDataSource.deleteTrip(uid, change.entityId);
          } else if (change.tripId != null) {
            await _remoteDataSource.deleteSubEntity(
                uid, change.tripId!, change.entityType, change.entityId);
          }
        }
        LocalStorageService.removePendingChange(change.entityId);
        debugPrint('_processPendingChanges: resolved ${change.action} ${change.entityType}/${change.entityId}');
      } catch (e, st) {
        debugPrint('_processPendingChanges: failed ${change.action} ${change.entityType}/${change.entityId} -> $e');
        debugPrintStack(stackTrace: st);
      }
    }
    _status = SyncStatus.idle;
    debugPrint('_processPendingChanges: complete');
  }

  Future<void> fetchAndMergeAll() async {
    if (!canSync) {
      debugPrint('fetchAndMergeAll: cannot sync');
      return;
    }
    debugPrint('fetchAndMergeAll: starting');
    _status = SyncStatus.syncing;
    try {
      final uid = _uid!;

      final localTrips = LocalStorageService.getTrips();
      final remoteTrips = await _remoteDataSource.getAllTrips(uid);
      debugPrint('fetchAndMergeAll: ${localTrips.length} local trips, ${remoteTrips.length} remote trips');
      final mergedTrips = _mergeLists<Trip>(
        localTrips.map((t) => t.toMap()).toList(),
        remoteTrips,
        Trip.fromMap,
      );
      LocalStorageService.saveTrips(mergedTrips);

      for (final trip in mergedTrips) {
        final tid = trip.id;
        await _mergeSubEntities<Expense>(
          uid,
          tid,
          'expenses',
          LocalStorageService.getExpenses()
              .where((e) => e.tripId == tid)
              .map((e) => e.toMap())
              .toList(),
          Expense.fromMap,
          (list) => LocalStorageService.saveExpenses(list),
        );
        await _mergeSubEntities<Flight>(
          uid,
          tid,
          'flights',
          LocalStorageService.getFlights()
              .where((f) => f.tripId == tid)
              .map((f) => f.toMap())
              .toList(),
          Flight.fromMap,
          (list) => LocalStorageService.saveFlights(list),
        );
        await _mergeSubEntities<Activity>(
          uid,
          tid,
          'activities',
          LocalStorageService.getActivities()
              .where((a) => a.tripId == tid)
              .map((a) => a.toMap())
              .toList(),
          Activity.fromMap,
          (list) => LocalStorageService.saveActivities(list),
        );
        await _mergeSubEntities<PackingItem>(
          uid,
          tid,
          'packing',
          LocalStorageService.getPackingItems()
              .where((p) => p.tripId == tid)
              .map((p) => p.toMap())
              .toList(),
          PackingItem.fromMap,
          (list) => LocalStorageService.savePackingItems(list),
        );
        await _mergeSubEntities<Document>(
          uid,
          tid,
          'documents',
          LocalStorageService.getDocuments()
              .where((d) => d.tripId == tid)
              .map((d) => d.toMap())
              .toList(),
          Document.fromMap,
          (list) => LocalStorageService.saveDocuments(list),
        );
        await _mergeSubEntities<ItineraryDay>(
          uid,
          tid,
          'itinerary',
          LocalStorageService.getItineraryDays()
              .where((d) => d.tripId == tid)
              .map((d) => d.toMap())
              .toList(),
          ItineraryDay.fromMap,
          (list) => LocalStorageService.saveItineraryDays(list),
        );
      }
      debugPrint('fetchAndMergeAll: complete');
    } catch (e, st) {
      debugPrint('fetchAndMergeAll failed -> $e');
      debugPrintStack(stackTrace: st);
    }
    _status = SyncStatus.idle;
  }

  Future<void> pushLocalSnapshot() async {
    if (!canSync) {
      debugPrint('pushLocalSnapshot: cannot sync');
      return;
    }
    debugPrint('pushLocalSnapshot: starting');
    final uid = _uid!;

    for (final trip in LocalStorageService.getTrips()) {
      await _remoteDataSource.createTrip(uid, trip.toMap());
      final tripId = trip.id;

      for (final expense in LocalStorageService.getExpenses().where((e) => e.tripId == tripId)) {
        await _remoteDataSource.createSubEntity(uid, tripId, 'expenses', expense.toMap());
      }
      for (final flight in LocalStorageService.getFlights().where((f) => f.tripId == tripId)) {
        await _remoteDataSource.createSubEntity(uid, tripId, 'flights', flight.toMap());
      }
      for (final activity in LocalStorageService.getActivities().where((a) => a.tripId == tripId)) {
        await _remoteDataSource.createSubEntity(uid, tripId, 'activities', activity.toMap());
      }
      for (final item in LocalStorageService.getPackingItems().where((p) => p.tripId == tripId)) {
        await _remoteDataSource.createSubEntity(uid, tripId, 'packing', item.toMap());
      }
      for (final day in LocalStorageService.getItineraryDays().where((d) => d.tripId == tripId)) {
        await _remoteDataSource.createSubEntity(uid, tripId, 'itinerary', day.toMap());
      }
    }

    await _remoteDataSource.saveSettings(uid, LocalStorageService.getSettings().toMap());
    debugPrint('pushLocalSnapshot: complete');
  }

  Future<void> syncNow() async {
    debugPrint('syncNow: starting');
    if (!canSync) {
      debugPrint('syncNow: cannot sync');
      return;
    }
    await _processPendingChanges();
    await fetchAndMergeAll();
    debugPrint('syncNow: complete');
  }

  List<T> _mergeLists<T>(
    List<Map<String, dynamic>> local,
    List<Map<String, dynamic>> remote,
    T Function(Map<String, dynamic>) fromMap,
  ) {
    final merged = <String, Map<String, dynamic>>{};
    for (final item in local) {
      merged[item['id'] as String] = Map.from(item);
    }
    for (final item in remote) {
      final id = item['id'] as String;
      if (!merged.containsKey(id)) {
        merged[id] = Map.from(item);
      } else {
        final localUpdated = _parseDateTime(merged[id]!['updatedAt']);
        final remoteUpdated = _parseDateTime(item['updatedAt']);
        if (remoteUpdated.isAfter(localUpdated)) {
          merged[id] = Map.from(item);
        }
      }
    }
    return merged.values.map(fromMap).toList();
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null || value == '') {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  Future<void> _mergeSubEntities<T>(
    String uid,
    String tripId,
    String collection,
    List<Map<String, dynamic>> local,
    T Function(Map<String, dynamic>) fromMap,
    void Function(List<T>) saveFn,
  ) async {
    final remote =
        await _remoteDataSource.getAllSubEntities(uid, tripId, collection);
    if (remote.isEmpty) return;
    final merged = _mergeLists<T>(local, remote, fromMap);
    saveFn(merged);
  }

  void dispose() {
    _connectivitySub?.cancel();
  }
}
