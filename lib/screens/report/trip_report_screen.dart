import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../data/models/currency_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/packing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/trip_provider.dart';

class TripReportScreen extends StatelessWidget {
  const TripReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final tp = context.watch<TripProvider>();
    final tripId =
        args is String ? args : (tp.trips.isNotEmpty ? tp.trips.first.id : '');
    final trip = tp.getTripById(tripId);
    final expenseProvider = context.watch<ExpenseProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final flightProvider = context.watch<FlightProvider>();
    final packingProvider = context.watch<PackingProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final currency = currencyFromCode(settingsProvider.currencyCode);

    final tripExpenses = expenseProvider.getExpensesForTrip(tripId);
    final totalSpent = expenseProvider.getTotalForTrip(tripId);
    final categoryTotals = expenseProvider.getCategoryTotals(tripId);
    final tripActivities = activityProvider.getActivitiesForTrip(tripId);
    final tripFlights = flightProvider.getFlightsForTrip(tripId);
    final tripItems = packingProvider.getItemsForTrip(tripId);
    final packedCount = tripItems.where((i) => i.isPacked).length;
    final progress = packingProvider.getProgress(tripId);
    final upcomingActivities =
        activityProvider.getUpcomingActivities(tripId);
    final pastActivities = activityProvider.getPastActivities(tripId);

    return Scaffold(
      backgroundColor: JJColors.lightBg,
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
                  Row(children: [const JJBackButton(), const Spacer()]),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trip Report',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip?.name ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          Icons.analytics_outlined,
                          size: 28,
                          color: Colors.white.withAlpha(180),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: trip == null
                  ? const Center(child: Text('No trip selected'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _summaryCard(
                          title: 'Expenses',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currency.format(totalSpent),
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: JJColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${tripExpenses.length} expense${tripExpenses.length == 1 ? '' : 's'} across ${categoryTotals.length} categor${categoryTotals.length == 1 ? 'y' : 'ies'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: JJColors.textMuted,
                                ),
                              ),
                              if (totalSpent > 0 && trip.startDate != null && trip.endDate != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '~${currency.format(totalSpent / (trip.endDate!.difference(trip.startDate!).inDays + 1))}/day avg',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: JJColors.primaryPurple,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                title: 'Activities',
                                child: Column(
                                  children: [
                                    Text(
                                      '${tripActivities.length}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: JJColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${upcomingActivities.length} upcoming',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: JJColors.successGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${pastActivities.length} past',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: JJColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _summaryCard(
                                title: 'Packing',
                                child: Column(
                                  children: [
                                    Text(
                                      '${(progress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: JJColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$packedCount/${tripItems.length} packed',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: JJColors.textMuted,
                                      ),
                                    ),
                                    if (tripItems.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: progress,
                                            backgroundColor:
                                                JJColors.primaryPurple.withAlpha(12),
                                            valueColor:
                                                const AlwaysStoppedAnimation<Color>(
                                                    JJColors.successGreen),
                                            minHeight: 6,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _summaryCard(
                          title: 'Flights',
                          child: Text(
                            '${tripFlights.length} flight${tripFlights.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: JJColors.textDark,
                            ),
                          ),
                        ),
                        if (tripExpenses.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _summaryCard(
                            title: 'Top Categories',
                            child: Column(
                              children: _sortedCategoryWidgets(
                                  currency, categoryTotals),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.trips,
        onCenterTap: () {},
        onTabTap: (tab) {
          switch (tab) {
            case JJBottomNavTab.home:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case JJBottomNavTab.trips:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                    context, '/trip-detail', arguments: tripId);
              }
              break;
            case JJBottomNavTab.expenses:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                    context, '/expenses', arguments: tripId);
              }
              break;
            case JJBottomNavTab.more:
              Navigator.pushReplacementNamed(context, '/settings');
              break;
          }
        },
      ),
    );
  }

  List<Widget> _sortedCategoryWidgets(
    CurrencyOption currency,
    Map<String, double> categoryTotals,
  ) {
    final entries = categoryTotals.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              e.key,
              style: const TextStyle(
                fontSize: 14,
                color: JJColors.textDark,
              ),
            ),
          ),
          Text(
            currency.format(e.value),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: JJColors.textDark,
            ),
          ),
        ],
      ),
    )).toList();
  }

  Widget _summaryCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JJColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: JJColors.primaryPurple.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: JJColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
