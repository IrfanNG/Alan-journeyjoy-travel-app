import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../providers/activity_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/packing_provider.dart';
import '../../providers/trip_provider.dart';

class TripDetailScreen extends StatelessWidget {
  const TripDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final tripId = args is String ? args : null;

    final tripProvider = context.watch<TripProvider>();
    if (tripProvider.trips.isEmpty) {
      tripProvider.loadTrips();
    }

    final trip = tripId != null
        ? tripProvider.getTripById(tripId)
        : (tripProvider.trips.isNotEmpty ? tripProvider.trips.first : null);

    debugPrint('TripDetail args: $args');
    debugPrint('TripDetail tripId: $tripId');
    debugPrint('TripDetail trips count: ${tripProvider.trips.length}');
    debugPrint('TripDetail trip: ${trip?.name}');

    if (trip == null) {
      return Scaffold(
        backgroundColor: JJColors.lightBg,
        body: SafeArea(
          child: Center(
            child: Text(
              'Trip not found',
              style: TextStyle(
                color: Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    final activityProvider = context.watch<ActivityProvider>();
    final flightProvider = context.watch<FlightProvider>();
    final packingProvider = context.watch<PackingProvider>();

    final tripActivities = activityProvider.getActivitiesForTrip(trip.id);
    final tripFlights = flightProvider.getFlightsForTrip(trip.id);
    final tripItems = packingProvider.getItemsForTrip(trip.id);
    final packedCount = tripItems.where((i) => i.isPacked).length;

    return Scaffold(
      backgroundColor: JJColors.lightBg,
      body: Column(
        children: [
          SizedBox(
            height: 245,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
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
                    child: const CustomPaint(
                      painter: _HeroDecorPainter(),
                      child: SizedBox.expand(),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const JJBackButton(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: JJColors.lightBg,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.name,
                        style: const TextStyle(
                          color: JJColors.textDark,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMM dd, yyyy').format(trip.createdAt),
                        style: const TextStyle(
                          color: JJColors.textMuted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildQuickActions(context, trip.id),
                      const SizedBox(height: 24),
                      const Text(
                        "What's Next?",
                        style: TextStyle(
                          color: JJColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: JJColors.primaryPurple.withAlpha(12),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildListRow(
                              context,
                              icon: Icons.flight_outlined,
                              label: 'Flights',
                              trailing:
                                  '${tripFlights.length} flight${tripFlights.length == 1 ? '' : 's'}',
                              onTap: tripFlights.isNotEmpty
                                  ? () => Navigator.pushNamed(
                                      context,
                                      '/flights',
                                      arguments: trip.id,
                                    )
                                  : null,
                            ),
                            const Divider(height: 1, indent: 60),
                            _buildListRow(
                              context,
                              icon: Icons.calendar_month_outlined,
                              label: 'Activities',
                              trailing:
                                  '${tripActivities.length} activity${tripActivities.length == 1 ? '' : 'ies'}',
                              onTap: tripActivities.isNotEmpty
                                  ? () => Navigator.pushNamed(
                                      context,
                                      '/activities',
                                      arguments: trip.id,
                                    )
                                  : null,
                            ),
                            const Divider(height: 1, indent: 60),
                            _buildListRow(
                              context,
                              icon: Icons.checklist_outlined,
                              label: 'Packing List',
                              trailing: tripItems.isNotEmpty
                                  ? '$packedCount/${tripItems.length}'
                                  : '0',
                              onTap: tripItems.isNotEmpty
                                  ? () => Navigator.pushNamed(
                                      context,
                                      '/packing',
                                      arguments: trip.id,
                                    )
                                  : null,
                            ),
                            const Divider(height: 1, indent: 60),
                            _buildListRow(
                              context,
                              icon: Icons.description_outlined,
                              label: 'Documents',
                              trailing: null,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/documents',
                                arguments: trip.id,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.trips,
        onCenterTap: () =>
            Navigator.pushNamed(context, '/add-trip'),
        onTabTap: (tab) {
          switch (tab) {
            case JJBottomNavTab.home:
            case JJBottomNavTab.trips:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (_) => false,
              );
            case JJBottomNavTab.expenses:
              Navigator.pushNamed(
                context,
                '/expenses',
                arguments: trip.id,
              );
            case JJBottomNavTab.more:
              Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String tripId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionChip(
          context,
          icon: Icons.explore_outlined,
          label: 'Plan',
          isActive: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plan feature coming soon')),
            );
          },
        ),
        _actionChip(
          context,
          icon: Icons.route_outlined,
          label: 'Itinerary',
          isActive: false,
          onTap: () =>
              Navigator.pushNamed(context, '/activities', arguments: tripId),
        ),
        _actionChip(
          context,
          icon: Icons.account_balance_wallet_outlined,
          label: 'Expenses',
          isActive: false,
          onTap: () =>
              Navigator.pushNamed(context, '/expenses', arguments: tripId),
        ),
        _actionChip(
          context,
          icon: Icons.note_alt_outlined,
          label: 'Notes',
          isActive: false,
          onTap: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Notes coming later')));
          },
        ),
      ],
    );
  }

  Widget _actionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? JJColors.primaryPurple
                  : JJColors.primaryPurple.withAlpha(16),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: isActive ? Colors.white : JJColors.primaryPurple,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? JJColors.primaryPurple : JJColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: JJColors.primaryPurple.withAlpha(16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: JJColors.primaryPurple, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: JJColors.textDark,
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  trailing,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: JJColors.primaryPurple,
                  ),
                ),
              ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: JJColors.primaryPurple.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: JJColors.primaryPurple.withAlpha(120),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroDecorPainter extends CustomPainter {
  const _HeroDecorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(10)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.72)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.58,
        size.width * 0.28,
        size.height * 0.52,
      )
      ..quadraticBezierTo(
        size.width * 0.38,
        size.height * 0.46,
        size.width * 0.42,
        size.height * 0.50,
      )
      ..lineTo(size.width * 0.42, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final path2 = Path()
      ..moveTo(size.width * 0.15, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.35,
        size.height * 0.62,
        size.width * 0.50,
        size.height * 0.56,
      )
      ..quadraticBezierTo(
        size.width * 0.65,
        size.height * 0.48,
        size.width * 0.78,
        size.height * 0.54,
      )
      ..quadraticBezierTo(
        size.width * 0.90,
        size.height * 0.58,
        size.width,
        size.height * 0.50,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.15, size.height)
      ..close();
    canvas.drawPath(path2, paint);

    final paint3 = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.fill;

    final sunPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.78, size.height * 0.35),
          radius: 28,
        ),
      );
    canvas.drawPath(sunPath, paint3);

    final paint4 = Paint()
      ..color = Colors.white.withAlpha(8)
      ..style = PaintingStyle.fill;

    final cloudPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.42)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.36,
        size.width * 0.25,
        size.height * 0.38,
      )
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.32,
        size.width * 0.35,
        size.height * 0.35,
      )
      ..quadraticBezierTo(
        size.width * 0.40,
        size.height * 0.30,
        size.width * 0.45,
        size.height * 0.34,
      )
      ..lineTo(size.width * 0.45, size.height * 0.45)
      ..lineTo(size.width * 0.15, size.height * 0.45)
      ..close();
    canvas.drawPath(cloudPath, paint4);
  }

  @override
  bool shouldRepaint(covariant _HeroDecorPainter oldDelegate) => false;
}
