import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../data/models/currency_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/trip_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _itemNameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();
  final _noteController = TextEditingController();
  String? _editExpenseId;
  bool _initialized = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initialize() {
    if (_initialized) return;
    _initialized = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    String? tripId;
    if (args is String) {
      tripId = args;
    } else if (args is Map<String, dynamic>) {
      _editExpenseId = args['expenseId'] as String?;
      final expense = _editExpenseId != null
          ? context.read<ExpenseProvider>().getExpenseById(_editExpenseId!)
          : null;
      if (expense != null) {
        _itemNameController.text = expense.itemName;
        _amountController.text = expense.amount.toString();
        _selectedCategory = expense.category;
        _selectedDate = expense.createdAt;
        return;
      }
      tripId = args['tripId'] as String?;
    }
    if (tripId != null && tripId.isNotEmpty) {
      final trip = context.read<TripProvider>().getTripById(tripId);
      if (trip?.startDate != null && trip?.endDate != null) {
        final now = DateTime.now();
        if (now.isAfter(trip!.startDate!) && now.isBefore(trip.endDate!.add(const Duration(days: 1)))) {
          _selectedDate = now;
        } else {
          _selectedDate = trip.startDate!;
        }
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: JJColors.primaryPurple),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save(String tripId) {
    final description = _itemNameController.text.trim();
    final itemName = description.isEmpty ? _selectedCategory : description;
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter amount')),
      );
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than 0')),
      );
      return;
    }
    final provider = context.read<ExpenseProvider>();
    if (_editExpenseId != null) {
      provider.updateExpense(_editExpenseId!, itemName, amount, _selectedCategory,
          createdAt: _selectedDate);
    } else {
      provider.addExpense(tripId, itemName, amount, _selectedCategory,
          createdAt: _selectedDate);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _initialize();
    final args = ModalRoute.of(context)!.settings.arguments;
    final tripId = args is String ? args : (args as Map<String, dynamic>)['tripId'] as String;
    final currency = currencyFromCode(context.watch<SettingsProvider>().currencyCode);
    final isEditing = _editExpenseId != null;
    return Scaffold(
      backgroundColor: context.jj.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  const JJBackButton(variant: JJBackButtonVariant.purpleOnLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing ? 'Edit Expense' : 'Add Expense',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.jj.text,
                      ),
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: JJColors.primaryPurple.withAlpha(18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: JJColors.primaryPurple,
                      size: 23,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.jj.text,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _categoryTile('Food', Icons.restaurant),
                        _categoryTile('Transport', Icons.directions_car),
                        _categoryTile('Shopping', Icons.shopping_bag),
                        _categoryTile('Accommodation', Icons.hotel),
                        _categoryTile('Other', Icons.category),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.jj.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.jj.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.jj.border,
                        ),
                      ),
                      child: TextField(
                        controller: _itemNameController,
                        decoration: InputDecoration(
                          hintText: 'Optional note',
                          hintStyle: TextStyle(
                            color: context.jj.muted.withAlpha(80),
                          ),
                          filled: true,
                          fillColor: context.jj.card,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.jj.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: context.jj.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.jj.border,
                        ),
                      ),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '${currency.symbol} 0${currency.hasDecimals ? '.00' : ''}' ,
                          hintStyle: TextStyle(
                            color: context.jj.muted.withAlpha(80),
                          ),
                          filled: true,
                          fillColor: context.jj.card,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.jj.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                          decoration: BoxDecoration(
                            color: context.jj.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: context.jj.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  DateFormat(
                                    'MMMM dd, yyyy',
                                  ).format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: context.jj.text,
                                  ),
                                ),
                              ),
                            Icon(
                              Icons.calendar_today,
                              color: JJColors.primaryPurple.withAlpha(120),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Note (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.jj.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.jj.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.jj.border,
                        ),
                      ),
                      child: TextField(
                        controller: _noteController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add a note...',
                          hintStyle: TextStyle(
                            color: context.jj.muted.withAlpha(80),
                          ),
                          filled: true,
                          fillColor: context.jj.card,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _save(tripId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JJColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryTile(String label, IconData icon) {
    final selected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: selected ? JJColors.primaryPurple : context.jj.card,
              borderRadius: BorderRadius.circular(18),
              border: selected
                  ? null
                  : Border.all(color: JJColors.primaryPurple.withAlpha(15)),
            ),
            child: Icon(
              icon,
              color: selected ? Colors.white : JJColors.primaryPurple,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? JJColors.primaryPurple : context.jj.muted,
            ),
          ),
        ],
      ),
    );
  }
}
