import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BusinessNotificationsScreen extends StatefulWidget {
  const BusinessNotificationsScreen({super.key});

  @override
  State<BusinessNotificationsScreen> createState() => _BusinessNotificationsScreenState();
}

class _BusinessNotificationsScreenState extends State<BusinessNotificationsScreen> {
  // Interactive local state
  final List<Map<String, dynamic>> _alerts = [
    {'id': '1', 'icon': Icons.inventory, 'title': 'Low Stock Alert', 'desc': 'You only have 2 Caesar Salad Packs remaining.', 'time': 'Just now', 'isRead': false, 'color': AppTheme.cOrange},
    {'id': '2', 'icon': Icons.star, 'title': 'New 5-Star Review', 'desc': 'Aizat B. left a new review for Pizza Combo.', 'time': '1h ago', 'isRead': false, 'color': const Color(0xFFFF6B9D)},
    {'id': '3', 'icon': Icons.campaign, 'title': 'Deal Expiring Soon', 'desc': 'Bread Bundle discount automatically ends in 30 minutes.', 'time': '2h ago', 'isRead': true, 'color': AppTheme.bAccentTeal},
    {'id': '4', 'icon': Icons.payments, 'title': 'Payout Processed', 'desc': '₸210,000 has been successfully transferred to your bank.', 'time': 'Yesterday', 'isRead': true, 'color': AppTheme.bAccentPurple},
  ];

  void _markAllRead() {
    setState(() {
      for (var alert in _alerts) {
        alert['isRead'] = true;
      }
    });
  }

  void _removeAlert(int index) {
    setState(() {
      _alerts.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bBg,
      appBar: AppBar(
        backgroundColor: AppTheme.bSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.bTextMain),
        title: Text('Alerts', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontWeight: FontWeight.w700, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: AppTheme.bAccentPurple, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _alerts.isEmpty
          ? const Center(child: Text('All caught up! 🎉', style: TextStyle(color: AppTheme.bTextSec, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];

                return Dismissible(
                  key: Key(alert['id']),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) => _removeAlert(index),
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(color: Colors.redAccent.withAlpha(50), borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.redAccent),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (!alert['isRead']) {
                        setState(() => alert['isRead'] = true);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: alert['isRead'] ? AppTheme.bSurface : AppTheme.bCard,
                        border: Border.all(color: alert['isRead'] ? AppTheme.bBorder.withAlpha(100) : AppTheme.bBorder),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: alert['isRead'] ? [] : [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: alert['color'].withAlpha(30), borderRadius: BorderRadius.circular(10)),
                            child: Icon(alert['icon'], color: alert['color'], size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert['title'], style: TextStyle(color: alert['isRead'] ? AppTheme.bTextSec : AppTheme.bTextMain, fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(alert['desc'], style: TextStyle(color: AppTheme.bTextSec, fontSize: 12, height: 1.4)),
                                const SizedBox(height: 6),
                                Text(alert['time'], style: TextStyle(color: AppTheme.bTextSec.withAlpha(150), fontSize: 11)),
                              ],
                            ),
                          ),
                          if (!alert['isRead'])
                            Container(
                              width: 8, height: 8,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: const BoxDecoration(color: AppTheme.cOrange, shape: BoxShape.circle),
                            )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}