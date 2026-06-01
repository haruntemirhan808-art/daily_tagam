import 'package:flutter/material.dart';
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
          _ordersCount = 14; // Fallback for prototype
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
        padding: const EdgeInsets.only(bottom: 100), // Clear bottom nav
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- REWARDS HERO ---
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
                  // --- LEVEL PROGRESS ---
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

                  // --- ACTIVE COUPONS ---
                  const Text('🎟️ Active Coupons', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                  const SizedBox(height: 12),
                  _buildCouponCard('🎟️', 'SAVE10 — 10% Off', 'Expires May 31 • Napoli Pizza', AppTheme.cOrangePale, AppTheme.cOrange),
                  _buildCouponCard('⭐', 'BAKE20 — 20% Off', 'Expires June 5 • Golden Crust', AppTheme.cGreenPale, AppTheme.cGreen),
                  const SizedBox(height: 24),

                  // --- HOW TO EARN POINTS ---
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
                        _buildEarnRow('🛍️', 'Place an order', 'Earn points for every purchase', '+50–200 pts', true),
                        _buildEarnRow('⭐', 'Leave a review', 'Rate your meal after pickup', '+30 pts', true),
                        _buildEarnRow('👥', 'Refer a friend', 'Both of you get bonus points', '+150 pts', false),
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
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(45),
          borderRadius: BorderRadius.circular(12),
        ),
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

  Widget _buildCouponCard(String emoji, String title, String sub, Color bgColor, Color fgColor) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Text('Use', style: TextStyle(color: fgColor, fontSize: 11, fontWeight: FontWeight.w700)),
          )
        ],
      ),
    );
  }

  Widget _buildEarnRow(String emoji, String title, String sub, String points, bool border) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
        ],
      ),
    );
  }
}