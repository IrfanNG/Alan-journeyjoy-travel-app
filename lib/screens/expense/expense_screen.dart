import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/expense_provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _itemNameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Food';
  bool _showFullAdd = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final expenseProvider = context.watch<ExpenseProvider>();
    final tripExpenses = expenseProvider.getExpensesForTrip(tripId);
    final totalSpent = expenseProvider.getTotalForTrip(tripId);
    final categoryTotals = expenseProvider.getCategoryTotals(tripId);
    final hasData = totalSpent > 0;

    const categories = ['Food', 'Transport', 'Shopping', 'Accommodation', 'Other'];
    const categoryColors = [
      JJColors.warningOrange,
      Color(0xFF3B82F6),
      Color(0xFFEC4899),
      JJColors.successGreen,
      JJColors.textMuted,
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: JJColors.gradientPurple,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 80,
                        width: 80,
                        child: CustomPaint(
                          size: const Size(80, 80),
                          painter: _DonutChartPainter(
                            categoryTotals: hasData ? categoryTotals : {},
                            total: hasData ? totalSpent : 1,
                            colors: categoryColors,
                            categories: categories,
                            isEmpty: !hasData,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${totalSpent.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Total Spent',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withAlpha(180),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: List.generate(categories.length, (i) {
                      final catTotal = categoryTotals[categories[i]] ?? 0;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: categoryColors[i],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${categories[i]} ${hasData ? '\$${catTotal.toStringAsFixed(0)}' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            Expanded(
              child: tripExpenses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              size: 64,
                              color: JJColors.primaryPurple.withAlpha(80)),
                          const SizedBox(height: 16),
                          const Text(
                            'No expenses yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: JJColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first expense below',
                            style: TextStyle(
                                fontSize: 14, color: JJColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: tripExpenses.length,
                      itemBuilder: (context, index) {
                        final expense = tripExpenses[index];
                        final catIndex =
                            categories.indexOf(expense.category);
                        final catColor = catIndex >= 0
                            ? categoryColors[catIndex]
                            : JJColors.textMuted;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: JJColors.cardBg,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: JJColors.primaryPurple.withAlpha(10),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: catColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _iconForCategory(expense.category),
                                  color: catColor,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      expense.itemName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: JJColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      expense.category,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: JJColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${expense.amount.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: catColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showFullAdd
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _showFullAdd = true),
              backgroundColor: JJColors.primaryPurple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
      bottomSheet: _showFullAdd
          ? Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: const BoxDecoration(
                color: JJColors.cardBg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: JJColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _showFullAdd = false);
                          _itemNameController.clear();
                          _amountController.clear();
                        },
                        child: const Icon(Icons.close,
                            color: JJColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _itemNameController,
                    decoration: InputDecoration(
                      hintText: 'What did you spend on?',
                      hintStyle: TextStyle(
                          color: JJColors.textMuted.withAlpha(100)),
                      filled: true,
                      fillColor: JJColors.lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      prefixText: '\$ ',
                      hintStyle: TextStyle(
                          color: JJColors.textMuted.withAlpha(100)),
                      filled: true,
                      fillColor: JJColors.lightBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: categories.map((cat) {
                        final idx = categories.indexOf(cat);
                        final isSelected = _selectedCategory == cat;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedCategory = cat),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? categoryColors[idx]
                                  : JJColors.lightBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : JJColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final itemName = _itemNameController.text.trim();
                        final amount =
                            double.tryParse(_amountController.text.trim());
                        if (itemName.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter a description')),
                          );
                          return;
                        }
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Please enter a valid amount')),
                          );
                          return;
                        }
                        context
                            .read<ExpenseProvider>()
                            .addExpense(
                                tripId, itemName, amount, _selectedCategory);
                        _itemNameController.clear();
                        _amountController.clear();
                        setState(() => _showFullAdd = false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JJColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add Expense',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 8,
                  ),
                ],
              ),
            )
          : null,
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Accommodation':
        return Icons.hotel;
      default:
        return Icons.receipt_long;
    }
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<String, double> categoryTotals;
  final double total;
  final List<String> categories;
  final List<Color> colors;
  final bool isEmpty;

  _DonutChartPainter({
    required this.categoryTotals,
    required this.total,
    required this.colors,
    required this.categories,
    this.isEmpty = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.6;

    if (isEmpty) {
      final paint = Paint()
        ..color = Colors.white.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;
      canvas.drawCircle(
        center,
        (radius + innerRadius) / 2,
        paint,
      );
      return;
    }

    double startAngle = -pi / 2;

    for (int i = 0; i < categories.length; i++) {
      final catTotal = categoryTotals[categories[i]] ?? 0;
      if (catTotal == 0) continue;
      final sweepAngle = (catTotal / total) * 2 * pi;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        Rect.fromCircle(
            center: center, radius: (radius + innerRadius) / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
