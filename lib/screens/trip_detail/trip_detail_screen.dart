import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/activity_provider.dart';
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
        backgroundColor: JJColors.lightBg,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: JJColors.primaryPurple.withAlpha(80),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Trip not found',
                  style: TextStyle(
                    fontSize: 18,
                    color: JJColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final activityProvider = context.watch<ActivityProvider>();
    final flightProvider = context.watch<FlightProvider>();
    final packingProvider = context.watch<PackingProvider>();

    final tripActivities = activityProvider.getActivitiesForTrip(tripId);
    final tripFlights = flightProvider.getFlightsForTrip(tripId);
    final tripItems = packingProvider.getItemsForTrip(tripId);
    final packedCount = tripItems.where((i) => i.isPacked).length;

    final colorHex = trip.colorHex.replaceFirst('#', '');
    final color = Color(int.parse('FF$colorHex', radix: 16));

    return Scaffold(
      backgroundColor: JJColors.lightBg,
      body: Stack(
        children: [
          SizedBox(
            height: 250,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withAlpha(180), JJColors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: CustomPaint(
                painter: _HeroDecorPainter(color: color),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
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
          Positioned.fill(
            top: 215,
            child: Container(
              decoration: const BoxDecoration(
                color: JJColors.lightBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: JJColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat(
                                    'MMM dd, yyyy',
                                  ).format(trip.createdAt),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: JJColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: JJColors.primaryPurple.withAlpha(20),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.ios_share,
                              color: JJColors.primaryPurple,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildQuickActions(context, trip.id),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "What's Next?",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: JJColors.textDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
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
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Document Hub coming later'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, String tripId) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notes coming later')),
              );
            },
          ),
        ],
      ),
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
  final Color color;

  _HeroDecorPainter({required this.color});

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
  bool shouldRepaint(covariant _HeroDecorPainter oldDelegate) =>
      oldDelegate.color != color;
}
