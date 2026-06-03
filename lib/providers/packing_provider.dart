import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/packing_item_model.dart';
import '../data/services/local_storage_service.dart';

class PackingProvider extends ChangeNotifier {
  List<PackingItem> _items = [];

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
  }

  void toggleItem(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      _items[index].isPacked = !_items[index].isPacked;
      LocalStorageService.savePackingItems(_items);
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    _items.removeWhere((i) => i.id == id);
    LocalStorageService.savePackingItems(_items);
    notifyListeners();
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
