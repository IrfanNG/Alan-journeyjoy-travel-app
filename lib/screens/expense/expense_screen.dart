import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../data/models/currency_model.dart';
import '../../providers/expense_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/trip_provider.dart';
import 'add_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  DateTimeRange? _dateFilter;
  bool _hasInitializedRange = false;
  final Set<String> _expandedCategories = {};

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String tripId;
    if (args is String) {
      tripId = args;
    } else {
      final tp = context.read<TripProvider>();
      tripId = tp.trips.isNotEmpty ? tp.trips.first.id : '';
    }

    if (!_hasInitializedRange && tripId.isNotEmpty) {
      final trip = context.read<TripProvider>().getTripById(tripId);
      if (trip?.startDate != null && trip?.endDate != null) {
        _dateFilter = DateTimeRange(
          start: trip!.startDate!,
          end: trip.endDate!,
        );
      }
      _hasInitializedRange = true;
    }

    final expenseProvider = context.watch<ExpenseProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final allTripExpenses = expenseProvider.getExpensesForTrip(tripId);
    final tripExpenses = _dateFilter != null
        ? expenseProvider.getExpensesByDateRange(
            tripId, _dateFilter!.start, _dateFilter!.end)
        : allTripExpenses;
    final totalSpent = tripExpenses.fold(0.0, (s, e) => s + e.amount);
    final categoryTotals = <String, double>{};
    for (final e in tripExpenses) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
    final hasData = totalSpent > 0;
    final pt = MediaQuery.of(context).padding.top;
    final currency = currencyFromCode(settingsProvider.currencyCode);

    const categories = [
      'Food',
      'Transport',
      'Shopping',
      'Accommodation',
      'Other',
    ];
    const displayLabels = ['Food', 'Transport', 'Shopping', 'Stays', 'Others'];
    const categoryColors = [
      JJColors.warningOrange,
      Color(0xFF14B8A6),
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFF58C783),
    ];

    return Scaffold(
      backgroundColor: JJColors.lightBg,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180 + pt,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF32158F),
                    Color(0xFF5B2BEA),
                    Color(0xFF6A35F4),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 120,
            child: ClipPath(
              clipper: const _ExpenseWhiteBodyClipper(),
              child: Container(color: JJColors.lightBg),
            ),
          ),
          Positioned(top: pt + 18, left: 24, child: const JJBackButton()),
          Positioned.fill(
            top: 132,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
              child: Column(
                children: [
                  Container(
                    height: 262,
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF32158F),
                          Color(0xFF5B2BEA),
                          Color(0xFF6A35F4),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: JJColors.primaryPurple.withAlpha(60),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -10,
                          right: -6,
                          child: CustomPaint(
                            size: const Size(90, 90),
                            painter: _CardDecorArcPainter(),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Total Spent',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withAlpha(200),
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showCurrencySelector(context, settingsProvider),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(25),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '${currency.code} ${currency.symbol}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_drop_down,
                                          size: 16,
                                          color: Colors.white.withAlpha(180),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              currency.format(totalSpent),
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: CustomPaint(
                                    size: const Size(100, 100),
                                    painter: _DonutChartPainter(
                                      categoryTotals: hasData
                                          ? categoryTotals
                                          : {},
                                      total: hasData ? totalSpent : 1,
                                      colors: categoryColors,
                                      categories: categories,
                                      isEmpty: !hasData,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      displayLabels.length,
                                      (i) {
                                        final catTotal =
                                            categoryTotals[categories[i]] ?? 0;
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: categoryColors[i],
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  displayLabels[i],
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white
                                                        .withAlpha(210),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                currency.format(catTotal),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _dateFilterChip(
                          label: _dateFilterLabel(),
                          onTap: () => _pickDateFilter(context),
                        ),
                      ),
                      if (_dateFilter != null)
                        GestureDetector(
                          onTap: () => setState(() => _dateFilter = null),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: JJColors.textMuted.withAlpha(150),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(categories.length, (index) {
                    final cat = categories[index];
                    final catTotal = categoryTotals[cat] ?? 0;
                    final catColor = categoryColors[index];
                    final isExpanded = _expandedCategories.contains(cat);
                    final catExpenses = tripExpenses
                        .where((e) => e.category == cat)
                        .toList();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _expandedCategories.remove(cat);
                                } else {
                                  _expandedCategories.add(cat);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: JJColors.primaryPurple.withAlpha(10),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: catColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _iconForCategory(cat),
                                      color: catColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      displayLabels[index],
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: JJColors.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    currency.format(catTotal),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: JJColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.25 : 0,
                                    duration: const Duration(milliseconds: 200),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: JJColors.primaryPurple.withAlpha(16),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.chevron_right,
                                        color: JJColors.primaryPurple.withAlpha(120),
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (isExpanded)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: JJColors.lightBg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: JJColors.primaryPurple.withAlpha(8),
                                ),
                              ),
                              child: catExpenses.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'No expenses in this range',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: JJColors.textMuted,
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: catExpenses.map((e) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.itemName,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: JJColors.textDark,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      DateFormat('MMM dd').format(e.createdAt),
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: JJColors.textMuted,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: Text(
                                                  currency.format(e.amount),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: JJColors.textDark,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () => Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => const AddExpenseScreen(),
                                                    settings: RouteSettings(
                                                      arguments: <String, dynamic>{
                                                        'tripId': tripId,
                                                        'expenseId': e.id,
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                icon: const Icon(
                                                  Icons.edit_outlined,
                                                  color: JJColors.textMuted,
                                                  size: 16,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              ),
                                              IconButton(
                                                onPressed: () => _confirmDeleteExpense(context, e.id),
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: JJColors.errorRed,
                                                  size: 18,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.expenses,
        onCenterTap: tripId.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddExpenseScreen(),
                    settings: RouteSettings(arguments: tripId),
                  ),
                );
              }
            : null,
        onTabTap: (tab) {
          switch (tab) {
            case JJBottomNavTab.home:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case JJBottomNavTab.trips:
              Navigator.pushReplacementNamed(
                context,
                '/trip-detail',
                arguments: tripId,
              );
              break;
            case JJBottomNavTab.expenses:
              break;
            case JJBottomNavTab.more:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
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

  Future<void> _confirmDeleteExpense(
    BuildContext context,
    String expenseId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ExpenseProvider>();
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete item?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: JJColors.errorRed),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true && mounted) {
      provider.deleteExpense(expenseId);
      messenger.showSnackBar(
        const SnackBar(content: Text('Expense deleted')),
      );
    }
  }

  void _showCurrencySelector(BuildContext context, SettingsProvider settingsProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Currency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: JJColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ...supportedCurrencies.map((c) => ListTile(
                leading: Text(
                  c.symbol,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: JJColors.textDark,
                  ),
                ),
                title: Text(
                  '${c.code} - ${c.name}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: JJColors.textDark,
                  ),
                ),
                subtitle: Text(
                  c.country,
                  style: const TextStyle(fontSize: 12, color: JJColors.textMuted),
                ),
                trailing: settingsProvider.currencyCode == c.code
                    ? const Icon(Icons.check, color: JJColors.primaryPurple)
                    : null,
                onTap: () {
                  settingsProvider.setCurrency(c.code);
                  Navigator.pop(sheetContext);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  String _dateFilterLabel() {
    if (_dateFilter == null) return 'All Time';
    final startLabel = DateFormat('MMM dd').format(_dateFilter!.start);
    final endLabel = DateFormat('MMM dd').format(_dateFilter!.end);
    if (DateUtils.isSameDay(_dateFilter!.start, _dateFilter!.end)) {
      return startLabel;
    }
    return '$startLabel - $endLabel';
  }

  Widget _dateFilterChip({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: JJColors.primaryPurple.withAlpha(12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: JJColors.primaryPurple.withAlpha(30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.date_range,
              size: 16,
              color: JJColors.primaryPurple.withAlpha(180),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: JJColors.primaryPurple,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: JJColors.primaryPurple.withAlpha(150),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateFilter(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _dateFilter ??
          DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
    );
    if (picked != null) {
      setState(() => _dateFilter = picked);
    }
  }
}

class _ExpenseWhiteBodyClipper extends CustomClipper<Path> {
  const _ExpenseWhiteBodyClipper();

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 44);
    path.quadraticBezierTo(size.width * 0.50, -28, size.width, 44);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldDelegate) => false;
}

class _CardDecorArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF58C783).withAlpha(40)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.2,
        size.width,
        size.height * 0.1,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()
      ..color = const Color(0xFFF59E0B).withAlpha(35)
      ..style = PaintingStyle.fill;

    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.3,
        size.width,
        size.height * 0.15,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.3, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
    final innerRadius = radius * 0.58;

    if (isEmpty) {
      final paint = Paint()
        ..color = Colors.white.withAlpha(40)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius - innerRadius
        ..strokeCap = StrokeCap.butt;
      canvas.drawCircle(center, (radius + innerRadius) / 2, paint);
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
        Rect.fromCircle(center: center, radius: (radius + innerRadius) / 2),
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
