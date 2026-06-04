import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../providers/expense_provider.dart';
import '../../providers/trip_provider.dart';
import 'add_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
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
    final expenseProvider = context.watch<ExpenseProvider>();
    final tripExpenses = expenseProvider.getExpensesForTrip(tripId);
    final totalSpent = expenseProvider.getTotalForTrip(tripId);
    final categoryTotals = expenseProvider.getCategoryTotals(tripId);
    final hasData = totalSpent > 0;
    final pt = MediaQuery.of(context).padding.top;

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
                            Text(
                              'Total Spent',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${totalSpent.toStringAsFixed(2)}',
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
                                                '\$${catTotal.toStringAsFixed(0)}',
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
                  const SizedBox(height: 24),
                  ...List.generate(categories.length, (index) {
                    final catTotal = categoryTotals[categories[index]] ?? 0;
                    final catColor = categoryColors[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        onTap: tripExpenses.isNotEmpty
                            ? () {
                                final filtered = tripExpenses
                                    .where(
                                      (e) => e.category == categories[index],
                                    )
                                    .toList();
                                if (filtered.isNotEmpty) {
                                  _showExpenseItems(
                                    context,
                                    filtered,
                                    categories[index],
                                  );
                                }
                              }
                            : null,
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
                                  _iconForCategory(categories[index]),
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
                                '\$${catTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: JJColors.textDark,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
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
                            ],
                          ),
                        ),
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

  void _showExpenseItems(
    BuildContext context,
    List<dynamic> expenses,
    String category,
  ) {
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
              Text(
                category,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: JJColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ...expenses.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          e.itemName,
                          style: const TextStyle(
                            fontSize: 14,
                            color: JJColors.textDark,
                          ),
                        ),
                      ),
                      Text(
                        '\$${e.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: JJColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
