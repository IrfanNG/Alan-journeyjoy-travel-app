import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../data/models/activity_model.dart';
import '../../data/models/itinerary_day_model.dart';
import '../../data/models/trip_model.dart';
import '../../providers/activity_provider.dart';
import '../../providers/itinerary_provider.dart';
import '../../providers/trip_provider.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final tp = context.watch<TripProvider>();
    final tripId = args is String
        ? args
        : (tp.trips.isNotEmpty ? tp.trips.first.id : '');
    final trip = tp.getTripById(tripId);
    final itineraryProvider = context.watch<ItineraryProvider>();
    final activityProvider = context.watch<ActivityProvider>();
    final tripDays = itineraryProvider.getDaysForTrip(tripId);
    final tripActivities = activityProvider.getActivitiesForTrip(tripId);

    return Scaffold(
      backgroundColor: JJColors.lightBg,
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Itinerary',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              trip?.name ?? '',
                              style: const TextStyle(
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
                          Icons.route,
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
              child: trip != null && trip.startDate != null && trip.endDate != null
                  ? _buildTimeline(
                      trip, tripDays, tripActivities, itineraryProvider, activityProvider)
                  : _buildNoDates(context, trip),
            ),
          ],
        ),
      ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.trips,
        onCenterTap: tripId.isNotEmpty
            ? () => _openDatePicker(context, trip!)
            : null,
        onTabTap: (tab) {
          switch (tab) {
            case JJBottomNavTab.home:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case JJBottomNavTab.trips:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                  context, '/trip-detail', arguments: tripId);
              }
              break;
            case JJBottomNavTab.expenses:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(
                  context, '/expenses', arguments: tripId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create a trip first')));
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

  Widget _buildNoDates(BuildContext context, Trip? trip) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 64,
              color: JJColors.primaryPurple.withAlpha(80),
            ),
            const SizedBox(height: 16),
            const Text(
              'No dates set',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: JJColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set your trip dates to see\nyour day-by-day itinerary',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: JJColors.textMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openDatePicker(context, trip!),
              icon: const Icon(Icons.calendar_today, size: 18),
              label: const Text('Set Dates'),
              style: ElevatedButton.styleFrom(
                backgroundColor: JJColors.primaryPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(
    Trip trip,
    List<ItineraryDay> tripDays,
    List<Activity> tripActivities,
    ItineraryProvider itineraryProvider,
    ActivityProvider activityProvider,
  ) {
    final start = trip.startDate!;
    final end = trip.endDate!;
    final dayCount = end.difference(start).inDays + 1;
    final days = List.generate(dayCount, (i) => start.add(Duration(days: i)));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final date = days[index];
        final dayActivities = tripActivities.where((a) {
          return DateTime(a.date.year, a.date.month, a.date.day) ==
              DateTime(date.year, date.month, date.day);
        }).toList();
        final itineraryDay = tripDays.where((d) {
          return DateTime(d.date.year, d.date.month, d.date.day) ==
              DateTime(date.year, date.month, date.day);
        }).toList();

        return _DayCard(
          dayNumber: index + 1,
          date: date,
          activities: dayActivities,
          itineraryDay: itineraryDay.isNotEmpty ? itineraryDay.first : null,
          tripId: trip.id,
          onNotesSaved: (notes) {
            if (itineraryDay.isNotEmpty) {
              itineraryProvider.updateDayNotes(itineraryDay.first.id, notes);
            } else {
              itineraryProvider.addDay(trip.id, date, notes: notes);
            }
          },
          onAddActivity: () {
            _addActivityForDate(context, trip.id, date, activityProvider);
          },
        );
      },
    );
  }

  void _addActivityForDate(
    BuildContext context,
    String tripId,
    DateTime date,
    ActivityProvider provider,
  ) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Activity for ${DateFormat('MMM dd').format(date)}'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'What are you doing?',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = nameController.text.trim();
              if (text.isEmpty) return;
              provider.addActivity(tripId, text, null, date, null, null);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _openDatePicker(BuildContext context, Trip trip) async {
    final start = trip.startDate ?? DateTime.now();
    final end = trip.endDate ?? DateTime.now().add(const Duration(days: 3));
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDateRange: DateTimeRange(start: start, end: end),
    );
    if (picked != null && context.mounted) {
      context.read<TripProvider>().updateTrip(
            trip.id,
            trip.name,
            trip.colorHex,
            startDate: picked.start,
            endDate: picked.end,
          );
    }
  }
}

class _DayCard extends StatefulWidget {
  final int dayNumber;
  final DateTime date;
  final List<Activity> activities;
  final ItineraryDay? itineraryDay;
  final String tripId;
  final ValueChanged<String?> onNotesSaved;
  final VoidCallback onAddActivity;

  const _DayCard({
    required this.dayNumber,
    required this.date,
    required this.activities,
    this.itineraryDay,
    required this.tripId,
    required this.onNotesSaved,
    required this.onAddActivity,
  });

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  late TextEditingController _notesController;
  bool _editingNotes = false;

  @override
  void initState() {
    super.initState();
    _notesController =
        TextEditingController(text: widget.itineraryDay?.notes ?? '');
  }

  @override
  void didUpdateWidget(_DayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itineraryDay?.notes != oldWidget.itineraryDay?.notes) {
      _notesController.text = widget.itineraryDay?.notes ?? '';
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekday = DateFormat('EEEE').format(widget.date);
    final formatted = DateFormat('MMM dd, yyyy').format(widget.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: JJColors.primaryPurple.withAlpha(16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.dayNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: JJColors.primaryPurple,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Day ${widget.dayNumber}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: JJColors.textDark,
                        ),
                      ),
                      Text(
                        '$weekday · $formatted',
                        style: const TextStyle(
                          fontSize: 12,
                          color: JJColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.activities.isEmpty && widget.itineraryDay == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  'Nothing planned yet',
                  style: TextStyle(
                    fontSize: 13,
                    color: JJColors.textMuted.withAlpha(150),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (widget.activities.isNotEmpty)
              ...widget.activities.map((a) => Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: JJColors.primaryPurple.withAlpha(100)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            a.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: JJColors.textDark,
                            ),
                          ),
                        ),
                        if (a.timeText != null)
                          Text(
                            a.timeText!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: JJColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  )),
            if (_editingNotes || (widget.itineraryDay?.notes?.isNotEmpty ?? false))
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Icon(Icons.notes, size: 14, color: JJColors.textMuted.withAlpha(120)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: _editingNotes
                          ? TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                hintText: 'Add notes for the day...',
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: const TextStyle(fontSize: 13, color: JJColors.textDark),
                              onSubmitted: (v) {
                                widget.onNotesSaved(
                                    v.trim().isEmpty ? null : v.trim());
                                setState(() => _editingNotes = false);
                              },
                            )
                          : GestureDetector(
                              onTap: () => setState(() => _editingNotes = true),
                              child: Text(
                                widget.itineraryDay?.notes ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: JJColors.textDark,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                    ),
                    if (_editingNotes)
                      GestureDetector(
                        onTap: () {
                          widget.onNotesSaved(
                              _notesController.text.trim().isEmpty
                                  ? null
                                  : _notesController.text.trim());
                          setState(() => _editingNotes = false);
                        },
                        child: const Icon(Icons.check, size: 16, color: JJColors.successGreen),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: widget.onAddActivity,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Activity',
                        style: TextStyle(fontSize: 13)),
                    style: TextButton.styleFrom(
                      foregroundColor: JJColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  if (widget.itineraryDay != null && !_editingNotes)
                    TextButton.icon(
                      onPressed: () => setState(() => _editingNotes = true),
                      icon: Icon(Icons.edit_note,
                          size: 16,
                          color: JJColors.textMuted.withAlpha(150)),
                      label: const Text('Notes',
                          style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: JJColors.textMuted,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  if (widget.itineraryDay == null)
                    TextButton.icon(
                      onPressed: () => setState(() => _editingNotes = true),
                      icon: Icon(Icons.edit_note,
                          size: 16,
                          color: JJColors.textMuted.withAlpha(150)),
                      label: const Text('Add Notes',
                          style: TextStyle(fontSize: 13)),
                      style: TextButton.styleFrom(
                        foregroundColor: JJColors.textMuted,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
