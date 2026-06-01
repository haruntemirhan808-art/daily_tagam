import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/network/api_client.dart';

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
          _name = response.data['name'];
          _email = response.data['email'];
          _mealsSaved = response.data['meals_saved'];
          _wasteSaved = double.tryParse(response.data['waste_saved_kg'].toString()) ?? 0.0;
          _moneySaved = response.data['money_saved'];
          _bonusPoints = response.data['bonus_points'];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching customer profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Prototype Visual Theme Palette
  final Color _orange = const Color(0xFFFF8A00);
  final Color _textMain = const Color(0xFF1A1A2E);
  final Color _textSec = const Color(0xFF64748B);
  final Color _border = const Color(0xFFE2E8F0);
  final Color _bg = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    String initials = _name.length >= 2 ? _name.substring(0, 2).toUpperCase() : "MX";

    return Scaffold(
      backgroundColor: _bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('My Profile', style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: _textMain)),
                  const SizedBox(height: 16),

                  // Profile Info Card Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20)],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: _orange,
                          child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        Text(_name, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
                        Text(_email, style: TextStyle(fontSize: 13, color: _textSec)),
                        const SizedBox(height: 20),
                        
                        // Impact Statistics Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(_mealsSaved.toString(), "Meals Saved"),
                            _buildStatItem("${_wasteSaved}kg", "Waste Saved"),
                            _buildStatItem(_moneySaved, "Saved Money"),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gamified Rewards Points Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFFF6B00)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // FIX: Changed from Colors.whiteBF to a valid translucent white style
                        Text('🌟 Bonus Points', style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text('$_bonusPoints pts', style: GoogleFonts.sora(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
                        const SizedBox(height: 2),
                        // FIX: Changed from Colors.whiteBF to a valid translucent white style
                        Text('≈ ₸$_bonusPoints discount on your next order', style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Account Settings', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: _textMain)),
                  const SizedBox(height: 12),

                  // Menu Action List
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
                    child: Column(
                      children: [
                        _buildMenuItem(Icons.receipt_long_outlined, 'Order History', const Color(0xFFFFF3E0), _orange),
                        _buildMenuItem(Icons.eco_outlined, 'My Eco Impact', const Color(0xFFF0FDF4), const Color(0xFF22C55E)),
                        _buildMenuItem(Icons.settings_outlined, 'Settings', const Color(0xFFEFF6FF), const Color(0xFF3B82F6)),
                        _buildMenuItem(Icons.logout_outlined, 'Sign Out', Colors.red.withAlpha(20), Colors.red, isLast: true, onTap: () {
                          Navigator.of(context).pushReplacementNamed('/auth');
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: _orange)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: _textSec, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color bgCircle, Color iconColor, {bool isLast = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : Border(bottom: BorderSide(color: _border)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: bgCircle, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textMain))),
            Icon(Icons.chevron_right, color: _textSec.withAlpha(100), size: 16),
          ],
        ),
      ),
    );
  }
}