import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/activity_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/packing_provider.dart';
import '../../providers/trip_provider.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final tripProvider = context.watch<TripProvider>();
    tripProvider.loadTrips();
    final trip = tripProvider.trips.where((t) => t.id == tripId).firstOrNull;

    if (trip == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off,
                    size: 64, color: JJColors.primaryPurple.withAlpha(80)),
                const SizedBox(height: 16),
                const Text('Trip not found',
                    style: TextStyle(
                        fontSize: 18,
                        color: JJColors.textDark,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
    }

    final expenseProvider = context.watch<ExpenseProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final flightProvider = context.watch<FlightProvider>();
    final packingProvider = context.watch<PackingProvider>();

    final totalSpent = expenseProvider.getTotalForTrip(tripId);
    final tripActivities = activityProvider.getActivitiesForTrip(tripId);
    final tripFlights = flightProvider.getFlightsForTrip(tripId);
    final tripItems = packingProvider.getItemsForTrip(tripId);
    final packedCount = tripItems.where((i) => i.isPacked).length;

    final colorHex = trip.colorHex.replaceFirst('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: 220,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            color,
                            color.withAlpha(180),
                            JJColors.deepPurple,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 60,
                            left: 30,
                            child: Icon(Icons.terrain,
                                size: 40,
                                color: Colors.white.withAlpha(30)),
                          ),
                          Positioned(
                            top: 80,
                            right: 40,
                            child: Icon(Icons.flight,
                                size: 32,
                                color: Colors.white.withAlpha(50)),
                          ),
                          Positioned(
                            top: 100,
                            left: 80,
                            child: Icon(Icons.wb_sunny,
                                size: 28,
                                color: Colors.white.withAlpha(35)),
                          ),
                          Positioned(
                            bottom: 50,
                            right: 60,
                            child: Icon(Icons.location_city,
                                size: 36,
                                color: Colors.white.withAlpha(25)),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                            child: Row(
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.more_horiz,
                                      color: Colors.white, size: 20),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -44,
                      left: 24,
                      right: 24,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: JJColors.cardBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: color.withAlpha(25),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.flight_takeoff,
                                  color: color, size: 26),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    trip.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: JJColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy')
                                        .format(trip.createdAt),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: JJColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statBox(
                        Icons.monetization_on_outlined,
                        '\$${totalSpent.toStringAsFixed(0)}',
                        'Spent',
                        JJColors.warningOrange),
                    _statBox(Icons.explore_outlined, '${tripActivities.length}',
                        'Activities', JJColors.successGreen),
                    _statBox(
                        Icons.checklist_outlined,
                        '$packedCount/${tripItems.length}',
                        'Packed',
                        JJColors.primaryPurple),
                    _statBox(Icons.flight_outlined, '${tripFlights.length}',
                        'Flights', const Color(0xFF3B82F6)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What's Next?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: JJColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _quickActionTile(
                              context,
                              'Expense',
                              Icons.monetization_on_outlined,
                              JJColors.warningOrange,
                              '/expenses',
                              trip.id),
                          const SizedBox(width: 12),
                          _quickActionTile(
                              context,
                              'Flight',
                              Icons.flight_outlined,
                              const Color(0xFF3B82F6),
                              '/flights',
                              trip.id),
                          const SizedBox(width: 12),
                          _quickActionTile(
                              context,
                              'Activity',
                              Icons.explore_outlined,
                              JJColors.successGreen,
                              '/activities',
                              trip.id),
                          const SizedBox(width: 12),
                          _quickActionTile(
                              context,
                              'Packing',
                              Icons.checklist_outlined,
                              JJColors.primaryPurple,
                              '/packing',
                              trip.id),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statBox(IconData icon, String value, String label, Color color) {
    return Container(
      width: 74,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: JJColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: JJColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionTile(BuildContext context, String label, IconData icon,
      Color color, String route, String tripId) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route, arguments: tripId),
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: JJColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: JJColors.primaryPurple.withAlpha(12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: JJColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
