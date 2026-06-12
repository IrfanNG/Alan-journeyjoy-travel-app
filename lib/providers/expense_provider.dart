import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/models/expense_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/sync_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final SyncService? _syncService;
  List<Expense> _expenses = [];

  ExpenseProvider({SyncService? syncService}) : _syncService = syncService;

  void loadExpenses() {
    _expenses = LocalStorageService.getExpenses();
    notifyListeners();
  }

  List<Expense> getExpensesForTrip(String tripId) {
    return _expenses.where((e) => e.tripId == tripId).toList();
  }

  double getTotalForTrip(String tripId) {
    return getExpensesForTrip(tripId).fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> getCategoryTotals(String tripId) {
    final tripExpenses = getExpensesForTrip(tripId);
    final totals = <String, double>{};
    for (final e in tripExpenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  List<Expense> getExpensesByDateRange(
      String tripId, DateTime start, DateTime end) {
    return getExpensesForTrip(tripId).where((e) {
      final d = e.createdAt;
      return d.isAfter(start.subtract(const Duration(days: 1))) &&
          d.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Expense> searchExpenses(String tripId, String query) {
    if (query.isEmpty) return getExpensesForTrip(tripId);
    final lower = query.toLowerCase();
    return getExpensesForTrip(tripId)
        .where((e) => e.itemName.toLowerCase().contains(lower))
        .toList();
  }

  void addExpense(
      String tripId, String itemName, double amount, String category,
      {DateTime? createdAt}) {
    final expense = Expense(
      id: const Uuid().v4(),
      tripId: tripId,
      itemName: itemName,
      amount: amount,
      category: category,
      createdAt: createdAt,
    );
    _expenses.add(expense);
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
    _syncService?.syncCreate(
      entityType: 'expenses',
      tripId: tripId,
      entityId: expense.id,
      data: expense.toMap(),
    );
  }

  void deleteExpense(String id) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return;
    final tripId = _expenses[index].tripId;
    _expenses.removeAt(index);
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
    _syncService?.syncDelete(
      entityType: 'expenses',
      tripId: tripId,
      entityId: id,
    );
  }

  void updateExpense(
      String id, String itemName, double amount, String category,
      {DateTime? createdAt}) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _expenses[index].itemName = itemName;
    _expenses[index].amount = amount;
    _expenses[index].category = category;
    if (createdAt != null) _expenses[index].createdAt = createdAt;
    _expenses[index].updatedAt = DateTime.now();
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
    _syncService?.syncUpdate(
      entityType: 'expenses',
      tripId: _expenses[index].tripId,
      entityId: id,
      data: _expenses[index].toMap(),
    );
  }

  Expense? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  void deleteByTripId(String tripId) {
    _expenses.removeWhere((e) => e.tripId == tripId);
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }

  void clear() {
    _expenses.clear();
    LocalStorageService.saveExpenses(_expenses);
    notifyListeners();
  }
}
