import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../core/widgets/jj_back_button.dart';
import '../../core/widgets/jj_bottom_nav.dart';
import '../../data/models/document_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/document_provider.dart';
import '../../providers/trip_provider.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  int _selectedTab = 0;

  String _resolveTripId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) return args;
    final tp = context.read<TripProvider>();
    return tp.trips.isNotEmpty ? tp.trips.first.id : '';
  }

  List<Document> _filtered(List<Document> docs) {
    if (_selectedTab == 0) return docs;
    if (_selectedTab == 1) {
      return docs.where((d) => d.category == 'Travel Docs').toList();
    }
    return docs.where((d) => d.category == 'Other').toList();
  }

  @override
  Widget build(BuildContext context) {
    final tripId = _resolveTripId(context);
    final docProvider = context.watch<DocumentProvider>();
    final allDocs = docProvider.getDocumentsForTrip(tripId);
    final docs = _filtered(allDocs);

    return Scaffold(
      backgroundColor: context.jj.background,
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
                  Row(
                      children: [const JJBackButton(), const Spacer()]),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Documents',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(height: 4),
                            Text('Keep your travel documents organized',
                                style: TextStyle(
                                    fontSize: 13, color: Colors.white70)),
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
                          Icon(Icons.folder_open,
                              size: 56,
                              color: JJColors.primaryPurple.withAlpha(60)),
                          const SizedBox(height: 12),
                          Text('No documents yet',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: context.jj.text)),
                          const SizedBox(height: 4),
                          Text('Upload your travel documents here',
                              style: TextStyle(
                                  fontSize: 13, color: context.jj.muted)),
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
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: context.jj.card,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                    color: context.jj.shadow,
                                    blurRadius: 8,
                                    offset: const Offset(0, 2)),
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
                                  child: Icon(_iconForDoc(doc.name),
                                      color: JJColors.primaryPurple,
                                      size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(doc.name,
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: context.jj.text),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text(doc.sizeFormatted,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: context.jj.muted)),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Icon(Icons.more_vert,
                                      size: 20,
                                      color: context.jj.muted.withAlpha(120)),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _confirmDelete(context, doc);
                                    }
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline,
                                              size: 18, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
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
                  onPressed: () => _handleUpload(context, tripId),
                  icon: const Icon(Icons.upload_file, size: 22),
                  label: const Text('Upload Document',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JJColors.primaryPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
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
        onCenterTap: () => _handleUpload(context, tripId),
        onTabTap: (tab) {
          switch (tab) {
            case JJBottomNavTab.home:
              Navigator.pushReplacementNamed(context, '/home');
            case JJBottomNavTab.trips:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(context, '/trip-detail',
                    arguments: tripId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create a trip first')));
              }
            case JJBottomNavTab.expenses:
              if (tripId.isNotEmpty) {
                Navigator.pushReplacementNamed(context, '/expenses',
                    arguments: tripId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Create a trip first')));
              }
            case JJBottomNavTab.more:
              Navigator.pushReplacementNamed(context, '/settings');
          }
        },
      ),
    );
  }

  IconData _iconForDoc(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif')) {
      return Icons.image;
    }
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return Icons.description;
    }
    if (lower.endsWith('.xls') || lower.endsWith('.xlsx')) {
      return Icons.table_chart;
    }
    return Icons.insert_drive_file;
  }

  Future<void> _handleUpload(BuildContext context, String tripId) async {
    if (tripId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Create a trip first')));
      return;
    }
    String? userId;
    try {
      userId = context.read<AuthProvider>().user?.uid;
    } catch (_) {}
    final provider = context.read<DocumentProvider>();
    await provider.pickAndUpload(tripId, userId);
  }

  void _confirmDelete(BuildContext context, Document doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Delete "${doc.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DocumentProvider>().deleteDocument(doc.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
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
              color: selected ? Colors.white : context.jj.muted,
            ),
          ),
        ),
      ),
    );
  }
}
