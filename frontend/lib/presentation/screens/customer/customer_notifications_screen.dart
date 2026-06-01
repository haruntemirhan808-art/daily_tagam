import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class CustomerNotificationsScreen extends StatefulWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  State<CustomerNotificationsScreen> createState() => _CustomerNotificationsScreenState();
}

class _CustomerNotificationsScreenState extends State<CustomerNotificationsScreen> {
  // 🔴 INTERACTIVE: Local state to track which notifications are unread
  final Set<String> _readNotifications = {};

  void _markAsRead(String id) {
    if (!_readNotifications.contains(id)) {
      setState(() {
        _readNotifications.add(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppTheme.cBg, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.chevron_left, size: 18, color: AppTheme.cTextMain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Notifications', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text('TODAY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.cTextSec, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  
                  // Passing a unique ID to track read state
                  _buildNotifItem('notif_1', '⚡', 'Flash Deal! 70% off Pizza', 'Napoli Pizza has a limited combo deal — only 5 left!', '2 min ago', AppTheme.cOrangePale, true),
                  _buildNotifItem('notif_2', '🌱', 'You saved 0.4 kg today!', 'Your bakery purchase helped save food waste. Keep it up!', '1h ago', AppTheme.cGreenPale, true),
                  _buildNotifItem('notif_3', '🎟️', 'Coupon SAVE10 applied', 'Your 10% coupon was used on your last order.', '3h ago', AppTheme.cOrangePale, true),
                  
                  const SizedBox(height: 16),
                  const Text('EARLIER', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.cTextSec, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  
                  _buildNotifItem('notif_4', '📦', 'Order Ready for Pickup', 'Your Bakery Morning Pack from Golden Crust is ready — pick up by 9 PM.', 'Yesterday, 7:30 PM', const Color(0xFFEFF6FF), false),
                  _buildNotifItem('notif_5', '⭐', '+120 Bonus Points Earned', 'You earned points on your Pizza Combo order!', 'Yesterday, 6:15 PM', AppTheme.cGreenPale, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifItem(String id, String emoji, String title, String desc, String time, Color bgColor, bool initiallyUnread) {
    // Determine if the orange dot should show based on state
    bool isUnread = initiallyUnread && !_readNotifications.contains(id);

    return GestureDetector(
      // 🔴 INTERACTIVE: Marks notification as read when tapped
      onTap: () {
        _markAsRead(id);
        if (title.contains('Pizza')) {
          Navigator.pushNamed(context, '/all-deals'); // Route to deals for flash sales
        } else if (title.contains('saved')) {
          Navigator.pushNamed(context, '/eco-impact'); // Route to eco screen
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : AppTheme.cBg, // Slightly dims if read
          borderRadius: BorderRadius.circular(12),
          border: isUnread ? null : Border.all(color: AppTheme.cBorder.withAlpha(100)),
          boxShadow: isUnread ? [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))] : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isUnread ? AppTheme.cTextMain : AppTheme.cTextSec)),
                  const SizedBox(height: 2),
                  Text(desc, style: TextStyle(fontSize: 12, color: AppTheme.cTextSec, height: 1.4)),
                  const SizedBox(height: 4),
                  Text(time, style: const TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(color: AppTheme.cOrange, shape: BoxShape.circle),
              )
          ],
        ),
      ),
    );
  }
}