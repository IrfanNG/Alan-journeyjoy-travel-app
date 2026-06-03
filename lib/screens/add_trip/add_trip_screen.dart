import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/trip_provider.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _nameController = TextEditingController();
  String _selectedColor = '#5B2BEA';

  final List<String> _colorOptions = [
    '#5B2BEA',
    '#EC4899',
    '#3B82F6',
    '#10B981',
    '#F59E0B',
    '#EF4444',
    '#14B8A6',
    '#8B5CF6',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createTrip() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a trip name')),
      );
      return;
    }
    context.read<TripProvider>().addTrip(name, _selectedColor);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
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
                  Row(
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
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Transform.translate(
                  offset: const Offset(0, -32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: JJColors.cardBg,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: JJColors.primaryPurple.withAlpha(12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Center(
                              child: Text(
                                'New Adventure',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: JJColors.textDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Give your trip a name',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: JJColors.textMuted.withAlpha(180),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Trip Name',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: JJColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: 'e.g. Summer in Paris',
                                hintStyle: TextStyle(
                                    color: JJColors.textMuted.withAlpha(100)),
                                filled: true,
                                fillColor: JJColors.lightBg,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Trip Color',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: JJColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: _colorOptions.map((hex) {
                                final colorHex = hex.replaceFirst('#', '');
                                final color = Color(
                                    int.parse('FF$colorHex', radix: 16));
                                final isSelected = _selectedColor == hex;
                                return GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedColor = hex),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            )
                                          : null,
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: color.withAlpha(80),
                                                blurRadius: 8,
                                              )
                                            ]
                                          : null,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _createTrip,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: JJColors.primaryPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Let's Go!",
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
            ),
          ],
        ),
      ),
    );
  }
}
