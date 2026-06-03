import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../providers/packing_provider.dart';

class PackingScreen extends StatefulWidget {
  const PackingScreen({super.key});

  @override
  State<PackingScreen> createState() => _PackingScreenState();
}

class _PackingScreenState extends State<PackingScreen> {
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
    final packingProvider = context.watch<PackingProvider>();
    final tripItems = packingProvider.getItemsForTrip(tripId);
    final total = tripItems.length;
    final packed = tripItems.where((i) => i.isPacked).length;
    final progress = packingProvider.getProgress(tripId);

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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pack Smart!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Don\'t forget a thing',
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
                        child: Icon(Icons.checklist,
                            size: 28, color: Colors.white.withAlpha(180)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (total > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$packed/$total packed',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withAlpha(180),
                              ),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white.withAlpha(30),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                JJColors.successGreen),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: tripItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.checklist,
                              size: 64, color: JJColors.primaryPurple.withAlpha(80)),
                          const SizedBox(height: 16),
                          const Text(
                            'Nothing packed yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: JJColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add items to your packing list',
                            style: TextStyle(fontSize: 14, color: JJColors.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: tripItems.length,
                      itemBuilder: (context, index) {
                        final item = tripItems[index];
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
                              GestureDetector(
                                onTap: () => context
                                    .read<PackingProvider>()
                                    .toggleItem(item.id),
                                child: Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: item.isPacked
                                        ? JJColors.successGreen
                                        : JJColors.lightBg,
                                    borderRadius: BorderRadius.circular(8),
                                    border: item.isPacked
                                        ? null
                                        : Border.all(
                                            color: JJColors.textMuted
                                                .withAlpha(60),
                                            width: 1.5),
                                  ),
                                  child: item.isPacked
                                      ? const Icon(Icons.check,
                                          size: 18, color: Colors.white)
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: item.isPacked
                                        ? JJColors.textMuted
                                        : JJColors.textDark,
                                    decoration: item.isPacked
                                        ? TextDecoration.lineThrough
                                        : null,
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
              label: const Text('Add Item'),
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
                        'Add Item',
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
                    decoration: InputDecoration(
                      hintText: 'What do you need?',
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
                                content: Text('Please enter an item name')),
                          );
                          return;
                        }
                        context.read<PackingProvider>().addItem(tripId, text);
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
                        'Add Item',
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
