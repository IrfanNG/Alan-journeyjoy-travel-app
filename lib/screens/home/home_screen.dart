import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../data/models/currency_model.dart';
import '../../data/models/trip_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/flight_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/trip_provider.dart';

Color _parseTripColor(String hex) {
  final cleaned = hex.trim().replaceFirst('#', '');
  final c = cleaned.length == 6 ? int.tryParse('0xFF$cleaned') : null;
  if (c == null) return JJColors.primaryPurple;
  return Color(c);
}

List<Color> _featuredCardGradient(String colorHex) {
  final base = _parseTripColor(colorHex);
  final dark = Color.lerp(base, Colors.black, 0.35)!;
  final light = Color.lerp(base, Colors.white, 0.18)!;
  return [light, base, dark];
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTripIndex = 0;
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          if (_searchQuery.isNotEmpty) {
            final lower = _searchQuery.toLowerCase();
            displayTrips =
                displayTrips.where((t) => t.name.toLowerCase().contains(lower)).toList();
          }
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
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              if (!_isSearching) {
                                _searchController.clear();
                                _searchQuery = '';
                              }
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isSearching
                                  ? Icons.close
                                  : Icons.search,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 96,
                    left: 28,
                    right: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isSearching) ...[
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
                          if (!hasTrips) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Plan smarter. Travel lighter.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha(150),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ] else
                          TextField(
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Search trips...',
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(150),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white.withAlpha(20),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
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
                              return _PressScale(
                                onTap: () {
                                  if (trip != null) {
                                    Navigator.pushNamed(
                                      context,
                                      '/trip-detail',
                                      arguments: trip.id,
                                    );
                                  } else {
                                    Navigator.pushNamed(
                                      context,
                                      '/add-trip',
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
              break;
            case JJBottomNavTab.trips:
              final trip = _selectedTripFrom(context.read<TripProvider>());
              if (trip == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create a trip first')),
                );
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  '/trip-detail',
                  arguments: trip.id,
                );
              }
              break;
            case JJBottomNavTab.expenses:
              final trip = _selectedTripFrom(context.read<TripProvider>());
              if (trip == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create a trip first')),
                );
              } else {
                Navigator.pushReplacementNamed(
                  context,
                  '/expenses',
                  arguments: trip.id,
                );
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

  Widget _buildHeaderBg(BuildContext context, {double topPadding = 0}) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF32158F), Color(0xFF6A35F4)],
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _HeaderDecorPainter(),
          ),
        ),
      ],
    );
  }

  Trip? _selectedTripFrom(TripProvider tripProvider) {
    final displayTrips = tripProvider.trips.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (displayTrips.isEmpty) return null;
    final index = _selectedTripIndex >= displayTrips.length
        ? 0
        : _selectedTripIndex;
    return displayTrips[index];
  }

  Widget _buildFeaturedCard(BuildContext context, Trip? trip, bool hasTrips) {
    if (hasTrips && trip != null) {
      return _buildTripCard(trip);
    }
    return _buildEmptyTripCard();
  }

  Widget _buildTripCard(Trip trip) {
    final gradientColors = _featuredCardGradient(trip.colorHex);

    String dateText;
    if (trip.startDate != null && trip.endDate != null) {
      final days = trip.endDate!.difference(trip.startDate!).inDays + 1;
      dateText =
          '${DateFormat('MMM dd').format(trip.startDate!)} - ${DateFormat('MMM dd').format(trip.endDate!)} • $days days';
    } else {
      dateText = DateFormat('MMM dd, yyyy').format(trip.createdAt);
    }

    final expenseProvider = context.read<ExpenseProvider>();
    final flightProvider = context.read<FlightProvider>();
    final activityProvider = context.read<ActivityProvider>();
    final settingsProvider = context.read<SettingsProvider>();
    final currency = currencyFromCode(settingsProvider.currencyCode);

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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
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
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(28),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.flight_takeoff,
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
                                  trip.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateText,
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
                        children: [
                          _statChip(
                            Icons.account_balance_wallet_outlined,
                            currency.format(expenseProvider.getTotalForTrip(trip.id)),
                          ),
                          const SizedBox(width: 12),
                          _statChip(
                            Icons.flight_outlined,
                            '${flightProvider.getFlightsForTrip(trip.id).length} flight${flightProvider.getFlightsForTrip(trip.id).length == 1 ? '' : 's'}',
                          ),
                          const SizedBox(width: 12),
                          _statChip(
                            Icons.emoji_events_outlined,
                            '${activityProvider.getActivitiesForTrip(trip.id).length} activit${activityProvider.getActivitiesForTrip(trip.id).length == 1 ? 'y' : 'ies'}',
                          ),
                        ],
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

  Widget _buildEmptyTripCard() {
    return SizedBox(
      height: 160,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x405B2BEA),
              blurRadius: 16,
              offset: Offset(0, 6),
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
                Positioned.fill(
                  child: CustomPaint(
                    painter: _EmptyCardDecorPainter(),
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
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(28),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.add_location_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Plan Your First Trip',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Build itinerary, budget, flights & packing in one place',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(180),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Color(0xFF5B2BEA),
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Start planning',
                              style: TextStyle(
                                color: Color(0xFF5B2BEA),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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

  Widget _statChip(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white.withAlpha(210), size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
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
              Expanded(
                child: _circleModule(
                  context,
                  Icons.settings_outlined,
                  'Settings',
                  () => Navigator.pushNamed(context, '/settings'),
                ),
              ),
              const Expanded(child: SizedBox.shrink()),
              const Expanded(child: SizedBox.shrink()),
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
    return _PressScale(
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

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}

class _HeaderDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = Colors.white.withAlpha(18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final routePath = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.3,
        size.width * 0.5, size.height * 0.55,
      )
      ..quadraticBezierTo(
        size.width * 0.7, size.height * 0.8,
        size.width, size.height * 0.4,
      );
    canvas.drawPath(routePath, routePaint);

    final dotPaint = Paint()..color = Colors.white.withAlpha(25);
    canvas.drawCircle(Offset(0, size.height * 0.6), 4, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.55), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.8), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.4), 3.5, dotPaint);

    canvas.save();
    canvas.translate(size.width * 0.5, size.height * 0.55);
    canvas.rotate(0.5);
    final planePaint = Paint()..color = Colors.white.withAlpha(25);
    final planePath = Path()
      ..moveTo(0, -6)
      ..lineTo(2.5, -1.5)
      ..lineTo(5, -1.5)
      ..lineTo(3.5, 0)
      ..lineTo(1.5, 0)
      ..lineTo(1, 3)
      ..lineTo(-1, 3)
      ..lineTo(-1.5, 0)
      ..lineTo(-3.5, 0)
      ..lineTo(-5, -1.5)
      ..lineTo(-2.5, -1.5)
      ..close();
    canvas.drawPath(planePath, planePaint);
    canvas.restore();

    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 0.8,
        colors: [
          Colors.white.withAlpha(8),
          Colors.white.withAlpha(4),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmptyCardDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final whitePaint = Paint()..color = Colors.white.withAlpha(15);
    final dashPaint = Paint()
      ..color = Colors.white.withAlpha(30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final mapPath = Path()
      ..moveTo(size.width * 0.6, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.05, size.width * 0.85, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.35, size.width * 0.85, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.6, size.width * 0.65, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.65, size.width * 0.35, size.height * 0.55)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.25, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.2, size.width * 0.45, size.height * 0.15)
      ..close();
    canvas.drawPath(mapPath, whitePaint);

    final routePath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.4, size.width * 0.5, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.55, size.width * 0.75, size.height * 0.3);
    canvas.drawPath(routePath, dashPaint);

    final pinPaint = Paint()..color = Colors.white.withAlpha(40);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.3), 4, pinPaint);
    final pinStem = Path()
      ..moveTo(size.width * 0.75 - 2, size.height * 0.3 + 2)
      ..lineTo(size.width * 0.75, size.height * 0.3 + 7)
      ..lineTo(size.width * 0.75 + 2, size.height * 0.3 + 2);
    canvas.drawPath(pinStem, pinPaint);

    canvas.save();
    canvas.translate(size.width * 0.4, size.height * 0.48);
    canvas.rotate(-0.3);
    final planePaint = Paint()..color = Colors.white.withAlpha(35);
    final planePath = Path()
      ..moveTo(0, -7)
      ..lineTo(3, -2)
      ..lineTo(6, -2)
      ..lineTo(4, 0)
      ..lineTo(2, 0)
      ..lineTo(1, 4)
      ..lineTo(-1, 4)
      ..lineTo(-2, 0)
      ..lineTo(-4, 0)
      ..lineTo(-6, -2)
      ..lineTo(-3, -2)
      ..close();
    canvas.drawPath(planePath, planePaint);
    canvas.restore();

    final ticketPaint = Paint()..color = Colors.white.withAlpha(12);
    final ticketRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.55, size.height * 0.6, 30, 20),
      const Radius.circular(3),
    );
    canvas.drawRRect(ticketRect, ticketPaint);

    final cutoutPaint = Paint()..color = Colors.white.withAlpha(8);
    canvas.drawCircle(Offset(size.width * 0.55, size.height * 0.7), 3, cutoutPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
