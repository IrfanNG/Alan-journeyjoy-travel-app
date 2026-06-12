import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../providers/trip_provider.dart';

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _nameController = TextEditingController();
  String _selectedColor = '#5B2BEA';
  DateTime? _startDate;
  DateTime? _endDate;

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a trip name')));
      return;
    }
    context
        .read<TripProvider>()
        .addTrip(name, _selectedColor, startDate: _startDate, endDate: _endDate);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final pt = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: JJColors.lightBg,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 150 + pt,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: JJColors.gradientPurple,
                ),
              ),
            ),
          ),
          Positioned.fill(
            top: 80 + pt,
            child: ClipPath(
              clipper: _AddTripWhiteSheetClipper(),
              child: Container(color: JJColors.lightBg),
            ),
          ),
          Positioned(top: pt + 18, left: 24, child: const JJBackButton()),
          Positioned(
            top: pt + 22,
            right: 28,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withAlpha(190),
              size: 18,
            ),
          ),
          Positioned.fill(
            top: 120 + pt,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'New Adventure',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: JJColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Center(
                    child: Text(
                      'Name your trip',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: JJColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                  const Text(
                    'Trip Name',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: JJColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _TripNameField(controller: _nameController),
                  const SizedBox(height: 28),
                  const Text(
                    'Pick a Color',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: JJColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildColorPicker(),
                  const SizedBox(height: 24),
                  const Text(
                    'Trip Dates',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: JJColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _dateButton(
                          label: 'Start',
                          date: _startDate,
                          onTap: () => _pickDate(context, isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _dateButton(
                          label: 'End',
                          date: _endDate,
                          onTap: () => _pickDate(context, isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            JJColors.primaryPurple,
                            JJColors.brightPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: JJColors.primaryPurple.withAlpha(70),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _createTrip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Let's Go!",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPicker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: JJColors.primaryPurple.withAlpha(16)),
        boxShadow: [
          BoxShadow(
            color: JJColors.primaryPurple.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Wrap(
        spacing: 28,
        runSpacing: 18,
        children: _colorOptions.map((hex) {
          final colorHex = hex.replaceFirst('#', '');
          final color = Color(int.parse('FF$colorHex', radix: 16));
          final isSelected = _selectedColor == hex;
          return GestureDetector(
            onTap: () => setState(() => _selectedColor = hex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.white : color.withAlpha(80),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withAlpha(isSelected ? 95 : 45),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: JJColors.primaryPurple.withAlpha(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: date != null
                  ? JJColors.primaryPurple
                  : JJColors.textMuted.withAlpha(120),
            ),
            const SizedBox(width: 6),
            Text(
              date != null ? DateFormat('MMM dd').format(date) : label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: date != null
                    ? JJColors.textDark
                    : JJColors.textMuted.withAlpha(150),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final first = isStart ? null : _startDate;
    final last = isStart ? _endDate : null;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? DateTime.now(),
      firstDate: first ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: last ?? DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }
}

class _TripNameField extends StatelessWidget {
  const _TripNameField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JJColors.primaryPurple.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: JJColors.primaryPurple.withAlpha(10),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Enter trip name',
          hintStyle: TextStyle(
            color: JJColors.textMuted.withAlpha(145),
            fontSize: 14,
          ),
          filled: true,
          fillColor: Colors.white,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        ),
      ),
    );
  }
}

class _AddTripWhiteSheetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 44)
      ..quadraticBezierTo(size.width * 0.5, -40, size.width, 44)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
