import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../providers/activity_provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _controller = TextEditingController();
  bool _showAdd = false;
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final activityProvider = context.watch<ActivityProvider>();
    final allActivities = activityProvider.getActivitiesForTrip(tripId);
    final filtered = _selectedTab == 0
        ? allActivities
        : allActivities.where((a) => false).toList();

    return Scaffold(
      backgroundColor: JJColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Row(
                children: [
                  const JJBackButton(variant: JJBackButtonVariant.purpleOnLight),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Activities',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: JJColors.textDark,
                      ),
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: JJColors.primaryPurple.withAlpha(18),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: JJColors.primaryPurple,
                      size: 23,
                    ),
                  ),
                ],
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
                          const Text(
                            'No activities yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: JJColors.textDark,
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: JJColors.primaryPurple.withAlpha(10),
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: JJColors.textDark,
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
                                            color: JJColors.textMuted.withAlpha(
                                              150,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${DateFormat('MMM dd').format(activity.date)}${activity.timeText != null ? ' · ${activity.timeText}' : ''}',
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
                                Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: Icon(
                                    Icons.more_horiz,
                                    color: JJColors.textMuted.withAlpha(120),
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
                  onPressed: () => setState(() => _showAdd = true),
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
            const SizedBox(height: 8),
            JJBottomNav(
              currentIndex: 1,
              onTap: (i) {
                if (i == 0) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (_) => false,
                  );
                } else if (i == 4) {
                  Navigator.pushNamed(context, '/settings');
                }
              },
            ),
          ],
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
                        'Add Activity',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: JJColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _showAdd = false);
                          _controller.clear();
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
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'What are you planning?',
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
                        context.read<ActivityProvider>().addActivity(
                          tripId,
                          text,
                          null,
                          DateTime.now(),
                          null,
                          null,
                        );
                        _controller.clear();
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
                        'Add Activity',
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
              color: selected ? Colors.white : JJColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
