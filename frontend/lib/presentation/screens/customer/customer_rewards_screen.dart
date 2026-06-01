import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added for Clipboard functionality
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class CustomerRewardsScreen extends StatefulWidget {
  const CustomerRewardsScreen({super.key});

  @override
  State<CustomerRewardsScreen> createState() => _CustomerRewardsScreenState();
}

class _CustomerRewardsScreenState extends State<CustomerRewardsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  int _bonusPoints = 0;
  int _ordersCount = 0;
  int _mealsSaved = 0;

  @override
  void initState() {
    super.initState();
    _fetchRewardsData();
  }

  Future<void> _fetchRewardsData() async {
    try {
      final response = await _apiClient.dio.get('/users/me/profile');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _bonusPoints = response.data['bonus_points'] ?? 1240;
          _mealsSaved = response.data['meals_saved'] ?? 14;
          _ordersCount = 14; 
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bonusPoints = 1240;
          _mealsSaved = 14;
          _ordersCount = 14;
          _isLoading = false;
        });
      }
    }
  }

  // 🔴 INTERACTIVE: Copy coupon to clipboard
  void _useCoupon(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Coupon "$code" copied to clipboard! 📋', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.cGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 🔴 INTERACTIVE: Show details dialog for earning points
  void _showEarnDetails(String title, String details) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.sora(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.cTextMain)),
        content: Text(details, style: const TextStyle(color: AppTheme.cTextSec, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: AppTheme.cOrange, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.cBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.cOrange, Color(0xFFFF6B00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Balance', style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(220))),
                  const SizedBox(height: 4),
                  Text('$_bonusPoints', style: GoogleFonts.sora(fontSize: 44, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                  const SizedBox(height: 4),
                  Text('Bonus Points ≈ ₸$_bonusPoints', style: TextStyle(fontSize: 14, color: Colors.white.withAlpha(230))),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _buildHeroStat('🛍️', '$_ordersCount Orders'),
                      const SizedBox(width: 10),
                      _buildHeroStat('🌱', '$_mealsSaved Meals saved'),
                      const SizedBox(width: 10),
                      _buildHeroStat('🏅', 'Sprout Level'),
                    ],
                  )
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏅 Level Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('🌿 Sprout', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.cTextMain)),
                            Text('$_bonusPoints / 2,000 pts', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.cOrange)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: LinearProgressIndicator(
                            value: _bonusPoints / 2000,
                            minHeight: 10,
                            backgroundColor: AppTheme.cBg,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.cOrange),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text('${2000 - _bonusPoints} pts to reach 🌳 Tree level', style: const TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('🎟️ Active Coupons', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                  const SizedBox(height: 12),
                  _buildCouponCard('🎟️', 'SAVE10 — 10% Off', 'Expires May 31 • Napoli Pizza', 'SAVE10', AppTheme.cOrangePale, AppTheme.cOrange),
                  _buildCouponCard('⭐', 'BAKE20 — 20% Off', 'Expires June 5 • Golden Crust', 'BAKE20', AppTheme.cGreenPale, AppTheme.cGreen),
                  const SizedBox(height: 24),

                  const Text('⚡ How to earn points', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: [
                        _buildEarnRow('🛍️', 'Place an order', 'Earn points for every purchase', '+50–200 pts', true, 
                          () => _showEarnDetails('Place an order', 'You earn 50 points for every meal you save. Points are added to your account immediately after pickup!')),
                        _buildEarnRow('⭐', 'Leave a review', 'Rate your meal after pickup', '+30 pts', true, 
                          () => _showEarnDetails('Leave a review', 'Help the community by rating your food out of 5 stars after pickup to instantly receive 30 points.')),
                        _buildEarnRow('👥', 'Refer a friend', 'Both of you get bonus points', '+150 pts', false, 
                          () => _showEarnDetails('Refer a friend', 'Share your unique invite link. Once your friend completes their first order, you both get 150 points!')),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroStat(String emoji, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white.withAlpha(45), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildCouponCard(String emoji, String title, String sub, String promoCode, Color bgColor, Color fgColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Row(
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
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(fontSize: 12, color: AppTheme.cTextSec)),
              ],
            ),
          ),
          // 🔴 INTERACTIVE: Makes the "Use" button clickable
          GestureDetector(
            onTap: () => _useCoupon(promoCode),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
              child: Text('Copy', style: TextStyle(color: fgColor, fontSize: 12, fontWeight: FontWeight.w800)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEarnRow(String emoji, String title, String sub, String points, bool border, VoidCallback onTap) {
    // 🔴 INTERACTIVE: InkWell makes the row tap-able with a ripple effect
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: border ? const Border(bottom: BorderSide(color: AppTheme.cBorder)) : null),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.cTextMain)),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
                ],
              ),
            ),
            Text(points, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.cOrange)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 16, color: AppTheme.cTextSec),
          ],
        ),
      ),
    );
  }
}