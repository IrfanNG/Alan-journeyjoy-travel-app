import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/activity_provider.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  final _controller = TextEditingController();
  bool _showAdd = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripId = ModalRoute.of(context)!.settings.arguments as String;
    final activityProvider = context.watch<ActivityProvider>();
    final tripActivities = activityProvider.getActivitiesForTrip(tripId);

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
                      Text(
                        'Activities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _statBox(Icons.schedule, '${tripActivities.length}', 'Total', JJColors.warningOrange),
                      const SizedBox(width: 16),
                      _statBox(Icons.check_circle_outline, '0', 'Done', JJColors.successGreen),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: tripActivities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.explore_outlined,
                              size: 64, color: JJColors.primaryPurple.withAlpha(80)),
                          const SizedBox(height: 16),
                          const Text(
                            'No activities planned',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: JJColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add your first activity below',
                            style: TextStyle(fontSize: 14, color: JJColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: tripActivities.length,
                      itemBuilder: (context, index) {
                        final activity = tripActivities[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: JJColors.primaryPurple.withAlpha(15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.explore_outlined,
                                    color: JJColors.primaryPurple, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  activity.name,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: JJColors.textDark,
                                  ),
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
              label: const Text('Add Activity'),
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
                        child: const Icon(Icons.close, color: JJColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _controller,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'What are you planning?',
                      hintStyle:
                          TextStyle(color: JJColors.textMuted.withAlpha(100)),
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
                                content: Text('Please enter an activity')),
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

  Widget _statBox(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(180),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
