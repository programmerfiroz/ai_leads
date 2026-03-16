import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for history
    final List<Map<String, dynamic>> history = [
      {'title': 'Lead Synced', 'sub': 'The Hazelnut Factory', 'time': '2 mins ago', 'icon': Icons.sync, 'color': Colors.green},
      {'title': 'Status Changed', 'sub': 'Mood Bakers -> Contacted', 'time': '1 hour ago', 'icon': Icons.edit_note, 'color': Colors.blue},
      {'title': 'Scrape Run Completed', 'sub': 'Bakery in Lucknow (12 leads)', 'time': '3 hours ago', 'icon': Icons.check_circle_outline, 'color': Colors.purple},
      {'title': 'Lead Synced', 'sub': 'Cake Walkers', 'time': '5 hours ago', 'icon': Icons.sync, 'color': Colors.green},
      {'title': 'Profile Updated', 'sub': 'Changed business category', 'time': '1 day ago', 'icon': Icons.person_outline, 'color': Colors.orange},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: history.length,
        separatorBuilder: (context, index) => const SizedBox(height: 15),
        itemBuilder: (context, index) {
          final item = history[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item['icon'], color: item['color'], size: 24),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(item['sub'], style: const TextStyle(fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ),
                Text(item['time'], style: const TextStyle(fontSize: 11, color: Colors.white38)),
              ],
            ),
          );
        },
      ),
    );
  }
}
