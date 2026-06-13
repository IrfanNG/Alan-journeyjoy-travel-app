import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../providers/activity_provider.dart';
import '../../providers/trip_provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _controller = TextEditingController();
  bool _showAdd = false;
  String? _editActivityId;
  DateTime _selectedActivityDate = DateTime.now();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  int _selectedTab = 0;
  final _activityColors = [
    const Color(0xFF5B2BEA),
    const Color(0xFF58C783),
    const Color(0xFFF59E23),
    const Color(0xFFEF4444),
    const Color(0xFF3B82F6),
    const Color(0xFFEC4899),
    const Color(0xFF14B8A6),
    const Color(0xFF8B5CF6),
  ];
  final _activityIcons = [
    Icons.explore,
    Icons.flight,
    Icons.restaurant,
    Icons.hotel,
    Icons.directions_walk,
    Icons.camera_alt,
    Icons.beach_access,
    Icons.local_activity,
  ];

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final tp = context.watch<TripProvider>();
    final tripId = args is String
        ? args
        : (tp.trips.isNotEmpty ? tp.trips.first.id : '');
    final activityProvider = context.watch<ActivityProvider>();
    final filtered = _isSearching
        ? activityProvider.searchActivities(tripId, _searchQuery)
        : _selectedTab == 0
            ? activityProvider.getUpcomingActivities(tripId)
            : activityProvider.getPastActivities(tripId);

    return Scaffold(
      backgroundColor: context.jj.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  const JJBackButton(variant: JJBackButtonVariant.purpleOnLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.jj.text,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    }),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: JJColors.primaryPurple.withAlpha(18),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: JJColors.primaryPurple,
                        size: 23,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isSearching)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search activities...',
                    hintStyle: TextStyle(
                      color: context.jj.muted.withAlpha(100),
                    ),
                    filled: true,
                    fillColor: context.jj.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: JJColors.primaryPurple.withAlpha(12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [_tabItem('Upcoming', 0), _tabItem('Done', 1)],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 56,
                            color: JJColors.primaryPurple.withAlpha(60),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No activities yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.jj.text,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final activity = filtered[index];
                        final colorIndex = index % _activityColors.length;
                        final icon =
                            _activityIcons[index % _activityIcons.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          height: 84,
                          decoration: BoxDecoration(
                            color: context.jj.card,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: context.jj.shadow,
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                            child: Row(
                              children: [
                                Container(
                                  width: 72,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        _activityColors[colorIndex],
                                        _activityColors[colorIndex].withAlpha(
                                          150,
                                        ),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  child: Icon(
                                    icon,
                                    color: Colors.white.withAlpha(200),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        activity.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: context.jj.text,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 14,
                                            color: context.jj.muted.withAlpha(
                                              150,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${DateFormat('MMM dd').format(activity.date)}${activity.timeText != null ? ' · ${activity.timeText}' : ''}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: context.jj.muted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: IconButton(
                                    onPressed: () {
                                      _editActivityId = activity.id;
                                      _controller.text = activity.name;
                                      _selectedActivityDate = activity.date;
                                      setState(() => _showAdd = true);
                                    },
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color: context.jj.muted,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => _confirmDeleteActivity(
                                    context,
                                    activity.id,
                                  ),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: JJColors.errorRed,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final trip = context.read<TripProvider>().getTripById(tripId);
                    if (trip?.startDate != null) {
                      final now = DateTime.now();
                      if (trip!.startDate!.isBefore(now) &&
                          trip.endDate != null &&
                          trip.endDate!.isAfter(now.subtract(const Duration(days: 1)))) {
                        _selectedActivityDate = now;
                      } else {
                        _selectedActivityDate = trip.startDate!;
                      }
                    } else {
                      _selectedActivityDate = DateTime.now();
                    }
                    setState(() => _showAdd = true);
                  },
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    'Add Activity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JJColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: JJBottomNav(
        currentTab: JJBottomNavTab.trips,
        onCenterTap: tripId.isNotEmpty
            ? () => setState(() => _showAdd = true)
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
      bottomSheet: _showAdd
          ? Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              decoration: BoxDecoration(
                color: context.jj.card,
                borderRadius: const BorderRadius.only(
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
                      Text(
                        _editActivityId != null
                            ? 'Edit Activity'
                            : 'Add Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: context.jj.text,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAdd = false;
                            _editActivityId = null;
                          });
                          _controller.clear();
                        },
                        child: Icon(
                          Icons.close,
                          color: context.jj.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'What are you planning?',
                      hintStyle: TextStyle(
                        color: context.jj.muted.withAlpha(100),
                      ),
                      filled: true,
                      fillColor: context.jj.card,
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
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final trip = context.read<TripProvider>().getTripById(tripId);
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedActivityDate,
                        firstDate: trip?.startDate ?? DateTime(2020),
                        lastDate: trip?.endDate ?? DateTime(2035),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: Theme.of(context).colorScheme.copyWith(
                                    primary: JJColors.primaryPurple,
                                  ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        setState(() => _selectedActivityDate = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                        decoration: BoxDecoration(
                          color: context.jj.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: context.jj.border,
                          ),
                        ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: JJColors.primaryPurple.withAlpha(150),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedActivityDate),
                            style: TextStyle(
                              fontSize: 15,
                              color: context.jj.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        final text = _controller.text.trim();
                        if (text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter an activity'),
                            ),
                          );
                          return;
                        }
                        if (_editActivityId != null) {
                          context.read<ActivityProvider>().updateActivity(
                            _editActivityId!,
                            text,
                            null,
                            _selectedActivityDate,
                            null,
                            null,
                          );
                        } else {
                          context.read<ActivityProvider>().addActivity(
                            tripId,
                            text,
                            null,
                            _selectedActivityDate,
                            null,
                            null,
                          );
                        }
                        _controller.clear();
                        _editActivityId = null;
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
                      child: Text(
                        _editActivityId != null
                            ? 'Save Changes'
                            : 'Add Activity',
                        style: const TextStyle(
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

  Widget _tabItem(String label, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? JJColors.primaryPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : context.jj.muted,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteActivity(
    BuildContext context,
    String activityId,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<ActivityProvider>();
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
      provider.deleteActivity(activityId);
      messenger.showSnackBar(
        const SnackBar(content: Text('Activity deleted')),
      );
    }
  }
}
