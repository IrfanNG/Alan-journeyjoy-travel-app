import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/packing_item_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';

class PackingProvider extends ChangeNotifier {
  final SyncService? _syncService;
  List<PackingItem> _items = [];

  PackingProvider({SyncService? syncService}) : _syncService = syncService;

  void loadItems() {
    _items = LocalStorageService.getPackingItems();
    notifyListeners();
  }

  List<PackingItem> getItemsForTrip(String tripId) {
    return _items.where((i) => i.tripId == tripId).toList();
  }

  double getProgress(String tripId) {
    final items = getItemsForTrip(tripId);
    if (items.isEmpty) return 0;
    final packed = items.where((i) => i.isPacked).length;
    return packed / items.length;
  }

  void addItem(String tripId, String name) {
    final item = PackingItem(
      id: const Uuid().v4(),
      tripId: tripId,
      name: name,
    );
    _items.add(item);
    LocalStorageService.savePackingItems(_items);
    notifyListeners();
    _syncService?.syncCreate(
      entityType: 'packing',
      tripId: tripId,
      entityId: item.id,
      data: item.toMap(),
    );
  }

  void toggleItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isPacked = !_items[index].isPacked;
      _items[index].updatedAt = DateTime.now();
      LocalStorageService.savePackingItems(_items);
      notifyListeners();
      _syncService?.syncUpdate(
        entityType: 'packing',
        tripId: _items[index].tripId,
        entityId: id,
        data: _items[index].toMap(),
      );
    }
  }

  void updateItem(String id, String name) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    _items[index].name = name;
    _items[index].updatedAt = DateTime.now();
    LocalStorageService.savePackingItems(_items);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'packing',
      tripId: _items[index].tripId,
      entityId: id,
      data: _items[index].toMap(),
    );
  }

  PackingItem? getItemById(String id) {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  void deleteItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) return;
    final tripId = _items[index].tripId;
    _items.removeAt(index);
    LocalStorageService.savePackingItems(_items);
    notifyListeners();
    _syncService?.syncDelete(
      entityType: 'packing',
      tripId: tripId,
      entityId: id,
    );
  }

  void deleteByTripId(String tripId) {
    _items.removeWhere((i) => i.tripId == tripId);
    LocalStorageService.savePackingItems(_items);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    LocalStorageService.savePackingItems(_items);
    notifyListeners();
  }
}
