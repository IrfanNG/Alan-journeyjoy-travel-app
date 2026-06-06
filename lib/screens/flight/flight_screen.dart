import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../providers/flight_provider.dart';
import '../../providers/trip_provider.dart';

class FlightScreen extends StatefulWidget {
  const FlightScreen({super.key});

  @override
  State<FlightScreen> createState() => _FlightScreenState();
}

class _FlightScreenState extends State<FlightScreen> {
  final _flightNoController = TextEditingController();
  final _airlineController = TextEditingController();
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  @override
  void dispose() {
    _flightNoController.dispose();
    _airlineController.dispose();
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final tp = context.watch<TripProvider>();
    final tripId = args is String
        ? args
        : (tp.trips.isNotEmpty ? tp.trips.first.id : '');
    final flightProvider = context.watch<FlightProvider>();
    final tripFlights = flightProvider.getFlightsForTrip(tripId);

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
                  Row(children: [const JJBackButton(), const Spacer()]),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Flights',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your flight details',
                              style: TextStyle(
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
                          Icons.flight,
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
              child: tripFlights.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flight_outlined,
                            size: 64,
                            color: JJColors.primaryPurple.withAlpha(80),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No flights added',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: JJColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your flight details below',
                            style: TextStyle(
                              fontSize: 14,
                              color: JJColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: tripFlights.length,
                      itemBuilder: (context, index) {
                        final flight = tripFlights[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
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
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: JJColors.primaryPurple.withAlpha(15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.flight,
                                  color: JJColors.primaryPurple,
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${flight.airline ?? ''} ${flight.flightNumber}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: JJColors.textDark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${flight.fromLocation} → ${flight.toLocation}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: JJColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () =>
                                    _confirmDeleteFlight(context, flight.id),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: JJColors.errorRed,
                                  size: 20,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: tripId.isNotEmpty
            ? () => _openAddFlightSheet(context, tripId)
            : null,
        backgroundColor: JJColors.primaryPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Flight'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.trips,
        onCenterTap: tripId.isNotEmpty
            ? () => _openAddFlightSheet(context, tripId)
            : null,
        onTabTap: (tab) {
          switch (tab) {
            case JJBottomNavTab.home:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case JJBottomNavTab.trips:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                  context,
                  '/trip-detail',
                  arguments: tripId,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create a trip first')),
                );
              }
              break;
            case JJBottomNavTab.expenses:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                  context,
                  '/expenses',
                  arguments: tripId,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create a trip first')),
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

  Future<void> _openAddFlightSheet(BuildContext context, String tripId) async {
    _clearFlightForm();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(sheetContext).padding.bottom + 24,
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
                        'Add Flight',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: JJColors.textDark,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _clearFlightForm();
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: JJColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _flightInput(
                    controller: _flightNoController,
                    hintText: 'Flight Number',
                  ),
                  const SizedBox(height: 12),
                  _flightInput(
                    controller: _airlineController,
                    hintText: 'Airline (optional)',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _flightInput(
                          controller: _fromController,
                          hintText: 'From',
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.flight,
                        color: JJColors.primaryPurple,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _flightInput(
                          controller: _toController,
                          hintText: 'To',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => _saveFlight(sheetContext, tripId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: JJColors.primaryPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Add Flight',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (mounted) _clearFlightForm();
  }

  Widget _flightInput({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: JJColors.textMuted.withAlpha(100)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  void _saveFlight(BuildContext sheetContext, String tripId) {
    final flightNo = _flightNoController.text.trim();
    final airline = _airlineController.text.trim();
    final from = _fromController.text.trim();
    final to = _toController.text.trim();

    if (flightNo.isEmpty || from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill required fields')),
      );
      return;
    }

    context.read<FlightProvider>().addFlight(
      tripId,
      flightNo,
      airline.isEmpty ? null : airline,
      from,
      to,
      DateTime.now(),
      DateTime.now(),
    );
    _clearFlightForm();
    Navigator.pop(sheetContext);
  }

  void _clearFlightForm() {
    _flightNoController.clear();
    _airlineController.clear();
    _fromController.clear();
    _toController.clear();
  }

  Future<void> _confirmDeleteFlight(
    BuildContext context,
    String flightId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<FlightProvider>();
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
      provider.deleteFlight(flightId);
      messenger.showSnackBar(const SnackBar(content: Text('Flight deleted')));
    }
  }
}
