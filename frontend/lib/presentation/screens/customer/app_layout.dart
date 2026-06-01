import 'package:flutter/material.dart';
import '../customer_feed_screen.dart';
import 'customer_profile_screen.dart';

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0;

  // The active views available inside your persistent bottom menu
  final List<Widget> _screens = [
    const CustomerFeedScreen(),
    const Center(child: Text('Explore Screen Coming Soon')), // Placeholder stub
    const Center(child: Text('Rewards Screen Coming Soon')), // Placeholder stub
    const CustomerProfileScreen(),
  ];

  // Theme Palette matching prototype
  final Color _orange = const Color(0xFFFF8A00);
  final Color _textSec = const Color(0xFF64748B);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_filled, 'Home', 0),
            _buildNavItem(Icons.explore_outlined, 'Explore', 1),
            
            // Central prominent action button matching your gorgeous layout template
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/cart'),
              child: Transform.translate(
                offset: const Offset(0, -12),
                child: Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFFF6B00)]),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: _orange.withAlpha(90), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
                ),
              ),
            ),
            
            _buildNavItem(Icons.card_giftcard_outlined, 'Rewards', 2),
            _buildNavItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    final color = isActive ? _orange : _textSec.withAlpha(150);
    
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        color: Colors.transparent, // 🔴 FIXED: Changed 'background' to 'color'
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}