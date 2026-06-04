import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../providers/flight_provider.dart';

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
  bool _showAdd = false;

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
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
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
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _showAdd
          ? null
          : FloatingActionButton.extended(
              onPressed: () => setState(() => _showAdd = true),
              backgroundColor: JJColors.primaryPurple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Flight'),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
      bottomSheet: _showAdd
          ? Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
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
                      GestureDetector(
                        onTap: () {
                          setState(() => _showAdd = false);
                          _flightNoController.clear();
                          _airlineController.clear();
                          _fromController.clear();
                          _toController.clear();
                        },
                        child: const Icon(
                          Icons.close,
                          color: JJColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _flightNoController,
                    decoration: InputDecoration(
                      hintText: 'Flight Number',
                      hintStyle: TextStyle(
                        color: JJColors.textMuted.withAlpha(100),
                      ),
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
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _airlineController,
                    decoration: InputDecoration(
                      hintText: 'Airline (optional)',
                      hintStyle: TextStyle(
                        color: JJColors.textMuted.withAlpha(100),
                      ),
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
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _fromController,
                          decoration: InputDecoration(
                            hintText: 'From',
                            hintStyle: TextStyle(
                              color: JJColors.textMuted.withAlpha(100),
                            ),
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
                        child: TextField(
                          controller: _toController,
                          decoration: InputDecoration(
                            hintText: 'To',
                            hintStyle: TextStyle(
                              color: JJColors.textMuted.withAlpha(100),
                            ),
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
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final flightNo = _flightNoController.text.trim();
                        final airline = _airlineController.text.trim();
                        final from = _fromController.text.trim();
                        final to = _toController.text.trim();
                        if (flightNo.isEmpty || from.isEmpty || to.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill required fields'),
                            ),
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
                        _flightNoController.clear();
                        _airlineController.clear();
                        _fromController.clear();
                        _toController.clear();
                        setState(() => _showAdd = false);
                      },
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
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            )
          : null,
    );
  }
}
