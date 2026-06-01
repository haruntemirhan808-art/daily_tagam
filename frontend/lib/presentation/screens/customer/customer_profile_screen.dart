import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  // Real data state variables fetched from PostgreSQL
  String _name = "Loading...";
  String _email = "...";
  int _mealsSaved = 0;
  double _wasteSaved = 0.0;
  String _moneySaved = "₸0";
  int _bonusPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final response = await _apiClient.dio.get('/users/me/profile');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          // Added null safety checks to fix your console error!
          _name = response.data['name']?.toString() ?? "User";
          _email = response.data['email']?.toString() ?? "";
          _mealsSaved = response.data['meals_saved'] ?? 0;
          _wasteSaved = double.tryParse(response.data['waste_saved_kg']?.toString() ?? '0') ?? 0.0;
          _moneySaved = response.data['money_saved']?.toString() ?? "₸0";
          _bonusPoints = response.data['bonus_points'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching customer profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    String initials = _name.length >= 2 ? _name.substring(0, 2).toUpperCase() : "US";

    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 100), // Clears the BottomNav
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Profile', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                  const SizedBox(height: 16),

                  // --- PROFILE HERO CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFF8F0), Color(0xFFF0FDF4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [AppTheme.cOrange, Color(0xFFFF6B00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            boxShadow: [BoxShadow(color: AppTheme.cOrange.withAlpha(70), blurRadius: 24, offset: const Offset(0, 8))],
                          ),
                          alignment: Alignment.center,
                          child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        Text(_name, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                        const SizedBox(height: 4),
                        Text(_email, style: const TextStyle(fontSize: 13, color: AppTheme.cTextSec)),
                        const SizedBox(height: 16),
                        
                        // Impact Grid
                        Row(
                          children: [
                            _buildImpactStat(_mealsSaved.toString(), "Meals Saved"),
                            const SizedBox(width: 10),
                            _buildImpactStat("${_wasteSaved}kg", "Waste Saved"),
                            const SizedBox(width: 10),
                            _buildImpactStat(_moneySaved, "Saved Money"),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- BONUS POINTS CARD ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppTheme.cOrange, Color(0xFFFF6B00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('🌟 Bonus Points', style: TextStyle(color: Colors.white.withAlpha(230), fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('$_bonusPoints pts', style: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('≈ ₸$_bonusPoints discount on your next order', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text('Account', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                  const SizedBox(height: 12),

                  // --- MENU LIST ---
                  Column(
                    children: [
                      _buildMenuItem('🧾', 'Order History', AppTheme.cOrangePale, () => Navigator.pushNamed(context, '/order-history')),
                      _buildMenuItem('🌱', 'My Eco Impact', AppTheme.cGreenPale, () => Navigator.pushNamed(context, '/eco-impact')),
                      _buildMenuItem('⚙️', 'Settings', const Color(0xFFEFF6FF), () => Navigator.pushNamed(context, '/settings')),
                      _buildMenuItem('💬', 'Help & Support', AppTheme.cOrangePale, () => Navigator.pushNamed(context, '/help')),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Footer Text
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, color: AppTheme.cTextSec),
                        children: [
                          const TextSpan(text: 'You saved '),
                          TextSpan(text: '$_mealsSaved meals', style: const TextStyle(color: AppTheme.cGreen, fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' this month 🌱'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildImpactStat(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.cOrange)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.cTextSec, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(String emoji, String title, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.cTextMain))),
            const Icon(Icons.chevron_right, color: AppTheme.cTextSec, size: 16),
          ],
        ),
      ),
    );
  }
}