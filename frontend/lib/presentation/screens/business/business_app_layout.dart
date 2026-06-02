import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'business_dashboard_screen.dart';
import 'business_analytics_screen.dart';
import 'business_coupons_screen.dart';
import 'business_profile_screen.dart';

class BusinessAppLayout extends StatefulWidget {
  const BusinessAppLayout({super.key});

  @override
  State<BusinessAppLayout> createState() => _BusinessAppLayoutState();
}

class _BusinessAppLayoutState extends State<BusinessAppLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const BusinessDashboardScreen(),
    const BusinessAnalyticsScreen(),
    const Scaffold(), // Placeholder for center FAB slot
    const BusinessCouponsScreen(),
    const BusinessProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.businessTheme,
      child: Scaffold(
        backgroundColor: AppTheme.bBg,
        body: IndexedStack(index: _currentIndex, children: _screens),
        bottomNavigationBar: Container(
          height: 72,
          decoration: const BoxDecoration(color: AppTheme.bSurface, border: Border(top: BorderSide(color: AppTheme.bBorder, width: 1))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.pie_chart, 'Dashboard', 0),
              _buildNavItem(Icons.bar_chart, 'Analytics', 1),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/biz-add-food'),
                child: Transform.translate(
                  offset: const Offset(0, -12),
                  child: Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.bAccentPurple, Color(0xFF9C67F5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppTheme.bAccentPurple.withAlpha(90), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 24),
                  ),
                ),
              ),
              _buildNavItem(Icons.local_offer, 'Coupons', 3),
              _buildNavItem(Icons.store, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isActive = _currentIndex == index;
    final color = isActive ? AppTheme.bAccentPurple : AppTheme.bTextSec;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        color: Colors.transparent, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22), const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}