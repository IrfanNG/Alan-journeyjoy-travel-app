import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../data/models/trip_model.dart';
import '../../providers/trip_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTripIndex = 0;

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning!';
    if (hour < 17) return 'Good Afternoon!';
    return 'Good Evening!';
  }

  @override
  Widget build(BuildContext context) {
    final pt = MediaQuery.of(context).padding.top;
    const headerHeight = 285.0;
    const cardTop = 190.0;
    const bodyTop = 238.0;
    const gridTop = 420.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, _) {
          final trips = tripProvider.trips;
          List<Trip> displayTrips = trips.toList();
          displayTrips.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          if (_selectedTripIndex >= displayTrips.length) {
            _selectedTripIndex = 0;
          }
          final hasTrips = displayTrips.isNotEmpty;
          final selectedTrip = hasTrips
              ? displayTrips[_selectedTripIndex]
              : null;
          final screenHeight =
              MediaQuery.of(context).size.height -
              MediaQuery.of(context).padding.bottom -
              72;
          final contentHeight = screenHeight < 760 ? 760.0 : screenHeight;

          return SingleChildScrollView(
            child: SizedBox(
              height: contentHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: headerHeight,
                    child: _buildHeaderBg(context, topPadding: pt),
                  ),
                  Positioned.fill(
                    top: bodyTop,
                    child: ClipPath(
                      clipper: const _HomeWhiteBodyClipper(),
                      child: Container(color: const Color(0xFFF8F7FF)),
                    ),
                  ),
                  Positioned(
                    top: pt + 8,
                    left: 24,
                    right: 24,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 116,
                    left: 28,
                    right: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Where to next?',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: cardTop,
                    left: 24,
                    right: 24,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 160,
                          child: PageView.builder(
                            itemCount: hasTrips ? displayTrips.length : 1,
                            onPageChanged: (index) {
                              setState(() => _selectedTripIndex = index);
                            },
                            itemBuilder: (context, index) {
                              final trip = hasTrips
                                  ? displayTrips[index]
                                  : null;
                              return GestureDetector(
                                onTap: () {
                                  if (trip != null) {
                                    Navigator.pushNamed(
                                      context,
                                      '/trip-detail',
                                      arguments: trip.id,
                                    );
                                  }
                                },
                                child: _buildFeaturedCard(
                                  context,
                                  trip,
                                  hasTrips,
                                ),
                              );
                            },
                          ),
                        ),
                        if (hasTrips && displayTrips.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(displayTrips.length, (i) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 3,
                                  ),
                                  width: _selectedTripIndex == i ? 20 : 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _selectedTripIndex == i
                                        ? const Color(0xFF5B2BEA)
                                        : const Color(0xFF5B2BEA).withAlpha(50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              }),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: gridTop,
                    left: 0,
                    right: 0,
                    child: _buildModuleGrid(context, selectedTrip, hasTrips),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.home,
        onCenterTap: () => Navigator.pushNamed(context, '/add-trip'),
        onTabTap: (tab) {
          switch (tab) {
            case JJBottomNavTab.home:
            case JJBottomNavTab.trips:
              break;
            case JJBottomNavTab.expenses:
              final tp = context.read<TripProvider>();
              if (tp.trips.isNotEmpty) {
                Navigator.pushNamed(
                  context,
                  '/expenses',
                  arguments: tp.trips.first.id,
                );
              }
            case JJBottomNavTab.more:
              Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }

  Widget _buildHeaderBg(BuildContext context, {double topPadding = 0}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF32158F), Color(0xFF6A35F4)],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Trip? trip, bool hasTrips) {
    return SizedBox(
      height: 160,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x335B2BEA),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF7A5AF5),
                  Color(0xFF5B2BEA),
                  Color(0xFF32158F),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -10,
                  right: -10,
                  child: CustomPaint(
                    size: const Size(100, 100),
                    painter: _CardDecorPainter(),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Icon(
                    Icons.terrain,
                    size: 40,
                    color: Colors.white.withAlpha(15),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  right: 30,
                  child: Icon(
                    Icons.flight,
                    size: 24,
                    color: Colors.white.withAlpha(20),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white.withAlpha(180),
                      size: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              hasTrips
                                  ? Icons.flight_takeoff
                                  : Icons.add_location_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasTrips
                                      ? trip!.name
                                      : 'Plan Your First Trip',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  hasTrips
                                      ? DateFormat(
                                          'MMM dd, yyyy',
                                        ).format(trip!.createdAt)
                                      : 'Create your adventure',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hasTrips ? '71% Planned' : '0% Planned',
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: Colors.white.withAlpha(150),
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: hasTrips ? 0.71 : 0,
                          backgroundColor: Colors.white.withAlpha(30),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF58C783),
                          ),
                          minHeight: 5,
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
    );
  }

  Widget _buildModuleGrid(
    BuildContext context,
    Trip? selectedTrip,
    bool hasTrips,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _circleModule(
                  context,
                  Icons.add,
                  'Add Trip',
                  () => Navigator.pushNamed(context, '/add-trip'),
                ),
              ),
              Expanded(
                child: _circleModule(
                  context,
                  Icons.account_balance_wallet_outlined,
                  'Expenses',
                  () => _navigateTripModule(context, selectedTrip, 'expenses'),
                ),
              ),
              Expanded(
                child: _circleModule(
                  context,
                  Icons.emoji_events_outlined,
                  'Activities',
                  () =>
                      _navigateTripModule(context, selectedTrip, 'activities'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _circleModule(
                  context,
                  Icons.luggage_outlined,
                  'Packing',
                  () => _navigateTripModule(context, selectedTrip, 'packing'),
                ),
              ),
              Expanded(
                child: _circleModule(
                  context,
                  Icons.flight_outlined,
                  'Flights',
                  () => _navigateTripModule(context, selectedTrip, 'flights'),
                ),
              ),
              Expanded(
                child: _circleModule(
                  context,
                  Icons.description_outlined,
                  'Documents',
                  () => _navigateTripModule(context, selectedTrip, 'documents'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              _circleModule(
                context,
                Icons.settings_outlined,
                'Settings',
                () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleModule(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x155B2BEA),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: const Color(0xFF5B2BEA), size: 28),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF130B3A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateTripModule(
    BuildContext context,
    Trip? selectedTrip,
    String module,
  ) {
    if (selectedTrip == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Create a trip first')));
      return;
    }
    final route = {
      'expenses': '/expenses',
      'activities': '/activities',
      'packing': '/packing',
      'flights': '/flights',
      'documents': '/documents',
    }[module]!;
    Navigator.pushNamed(context, route, arguments: selectedTrip.id);
  }
}

class _CardDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(12);
    final path = Path()
      ..moveTo(size.width * 0.3, 0)
      ..lineTo(size.width, size.height * 0.3)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);

    final paint2 = Paint()..color = Colors.white.withAlpha(8);
    final path2 = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HomeWhiteBodyClipper extends CustomClipper<Path> {
  const _HomeWhiteBodyClipper();

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 34)
      ..quadraticBezierTo(size.width * 0.25, 0, size.width * 0.50, 0)
      ..quadraticBezierTo(size.width * 0.75, 0, size.width, 34)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldDelegate) => false;
}
