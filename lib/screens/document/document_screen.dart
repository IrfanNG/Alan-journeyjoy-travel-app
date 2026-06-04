import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  int _selectedTab = 0;

  final _documents = [
    _DocItem('Passport.pdf', '2.4 MB', Icons.description, 'Travel Docs'),
    _DocItem('E-ticket.pdf', '890 KB', Icons.confirmation_number, 'Travel Docs'),
    _DocItem('Hotel Booking.pdf', '1.2 MB', Icons.hotel, 'Travel Docs'),
    _DocItem('Insurance.pdf', '650 KB', Icons.health_and_safety, 'Travel Docs'),
    _DocItem('Itinerary.pdf', '1.8 MB', Icons.map, 'Travel Docs'),
    _DocItem('Photo ID.jpg', '340 KB', Icons.portrait, 'Other'),
    _DocItem('Visa.pdf', '1.1 MB', Icons.card_membership, 'Other'),
  ];

  List<_DocItem> get _filtered {
    if (_selectedTab == 0) return _documents;
    if (_selectedTab == 1) {
      return _documents.where((d) => d.category == 'Travel Docs').toList();
    }
    return _documents.where((d) => d.category == 'Other').toList();
  }

  @override
  Widget build(BuildContext context) {
    final docs = _filtered;

    return Scaffold(
      backgroundColor: JJColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Documents',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Keep your travel documents organized',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.folder, size: 36, color: Colors.white38),
                    ],
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
                  children: [
                    _tabItem('All', 0),
                    _tabItem('Travel Docs', 1),
                    _tabItem('Other', 2),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: docs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.folder_open,
                            size: 56,
                            color: JJColors.primaryPurple.withAlpha(60),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No documents yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: JJColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Upload your travel documents here',
                            style: TextStyle(
                              fontSize: 13,
                              color: JJColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
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
                                  child: Icon(
                                    doc.icon,
                                    color: JJColors.primaryPurple,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: JJColors.textDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        doc.size,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: JJColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.download,
                                  size: 20,
                                  color: JJColors.textMuted.withAlpha(120),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Document upload coming soon'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.upload_file, size: 22),
                  label: const Text(
                    'Upload Document',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
              currentIndex: 3,
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

class _DocItem {
  final String name;
  final String size;
  final IconData icon;
  final String category;

  const _DocItem(this.name, this.size, this.icon, this.category);
}
