import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_trip_card.dart';
import '../../providers/activity_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/packing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/trip_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<TripProvider>(
                builder: (context, tripProvider, child) {
                  final trips = tripProvider.trips;
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trips.isNotEmpty)
                          _buildFeaturedTrip(context, trips.first)
                        else
                          _buildMockFeaturedTrip(context),
                        _buildCircularModules(context),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Trips',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: JJColors.textDark,
                                ),
                              ),
                              GestureDetector(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/add-trip'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: JJColors.primaryPurple.withAlpha(15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add,
                                          size: 16,
                                          color: JJColors.primaryPurple),
                                      SizedBox(width: 4),
                                      Text(
                                        'Add Trip',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: JJColors.primaryPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (trips.isEmpty)
                          const SizedBox.shrink()
                        else
                          ...trips.map((trip) => JJTripCard(
                                trip: trip,
                                onTap: () => Navigator.pushNamed(
                                    context, '/trip-detail',
                                    arguments: trip.id),
                                onDelete: () =>
                                    _confirmDelete(context, trip.id, trip.name),
                              )),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final username = context.watch<SettingsProvider>().settings.username;
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu, color: Colors.white, size: 20),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _greeting(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              username != null ? 'Welcome, $username' : 'Where to next?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTrip(BuildContext context, trip) {
    final colorHex = trip.colorHex.replaceFirst('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));
    final packingProvider = context.read<PackingProvider>();
    final progress = packingProvider.getProgress(trip.id);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withAlpha(150), JJColors.primaryPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flight_takeoff,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('MMM dd, yyyy').format(trip.createdAt),
                        style: TextStyle(
                            color: Colors.white.withAlpha(180), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withAlpha(30),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(JJColors.successGreen),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMockFeaturedTrip(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            JJColors.primaryPurple,
            Color(0xFF7A5AF5),
            JJColors.brightPurple,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: JJColors.primaryPurple.withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Your Journey',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tap to create your first trip',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0,
                backgroundColor: Colors.white.withAlpha(30),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Colors.white38),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularModules(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: JJColors.textMuted.withAlpha(150),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleModule(context, Icons.card_travel, 'Add Trip',
                  () => Navigator.pushNamed(context, '/add-trip'), JJColors.primaryPurple),
              _circleModule(context, Icons.monetization_on_outlined, 'Expenses',
                  null, JJColors.successGreen),
              _circleModule(context, Icons.explore_outlined, 'Activities',
                  null, JJColors.warningOrange),
              _circleModule(context, Icons.checklist_outlined, 'Packing',
                  null, const Color(0xFFEC4899)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _circleModule(context, Icons.flight_outlined, 'Flights',
                  null, const Color(0xFF3B82F6)),
              _circleModule(context, Icons.description_outlined, 'Documents',
                  null, JJColors.textMuted, enabled: false),
              _circleModule(context, Icons.settings_outlined, 'Settings',
                  () => Navigator.pushNamed(context, '/settings'), JJColors.textMuted),
              const SizedBox(width: 72),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleModule(BuildContext context, IconData icon, String label,
      VoidCallback? onTap, Color color,
      {bool enabled = true}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: JJColors.cardBg,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: JJColors.primaryPurple.withAlpha(15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon,
                  color: enabled ? color : JJColors.textMuted, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: enabled ? JJColors.textDark : JJColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String tripId, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Trip'),
        content: Text(
            'Are you sure you want to delete "$name"?\nAll related expenses, flights, activities, and packing items will also be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ExpenseProvider>().deleteByTripId(tripId);
              context.read<FlightProvider>().deleteByTripId(tripId);
              context.read<ActivityProvider>().deleteByTripId(tripId);
              context.read<PackingProvider>().deleteByTripId(tripId);
              context.read<TripProvider>().deleteTrip(tripId);
              Navigator.pop(ctx);
            },
            child:
                const Text('Delete', style: TextStyle(color: JJColors.errorRed)),
          ),
        ],
      ),
    );
  }
}
