import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BusinessAnalyticsScreen extends StatelessWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('Analytics 📊', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.bAccentPurple, Color(0xFF9C67F5)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Revenue (This Month)', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('₸1,240,500', style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStat('Orders', '842'),
                              _buildStat('Waste Saved', '340kg'),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Weekly Performance', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.bCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bBorder)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildBar('Mon', 0.4),
                          _buildBar('Tue', 0.6),
                          _buildBar('Wed', 0.5),
                          _buildBar('Thu', 0.8),
                          _buildBar('Fri', 1.0, isHighlight: true),
                          _buildBar('Sat', 0.9),
                          _buildBar('Sun', 0.7),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Top Selling Items', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                    const SizedBox(height: 12),
                    _buildTopItem('🍕', 'Pizza Combo Box', '312 sold', '₸327,600'),
                    _buildTopItem('🥗', 'Caesar Salad Pack', '145 sold', '₸130,500'),
                    _buildTopItem('🥐', 'Morning Bakery Set', '98 sold', '₸70,560'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11)),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightRatio, {bool isHighlight = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 140 * heightRatio,
          decoration: BoxDecoration(
            color: isHighlight ? AppTheme.bAccentTeal : AppTheme.bAccentPurple.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 11)),
      ],
    );
  }

  Widget _buildTopItem(String emoji, String title, String sold, String revenue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.bCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bBorder)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.bTextMain, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sold, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 12)),
              ],
            ),
          ),
          Text(revenue, style: const TextStyle(color: AppTheme.bAccentTeal, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}