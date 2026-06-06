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

  void addExpense(
      String tripId, String itemName, double amount, String category) {
    final expense = Expense(
      id: const Uuid().v4(),
      tripId: tripId,
      itemName: itemName,
      amount: amount,
      category: category,
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
