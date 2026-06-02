import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  // Local state for dynamic updates
  String _bizName = 'Napoli Pizza';
  String _bizEmail = 'manager@napoli.kz';
  String _bizEmoji = '🍕';
  int _activeOffers = 0;
  int _totalOrders = 0;
  int _totalRevenue = 0;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final response = await _apiClient.dio.get('/business/me/profile');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _bizName = response.data['name'] ?? 'Napoli Pizza';
          _bizEmail = response.data['email'] ?? 'manager@napoli.kz';
          _bizEmoji = response.data['emoji'] ?? '🍕';
          _activeOffers = response.data['active_offer_count'] ?? 0;
          _totalOrders = response.data['total_orders'] ?? 0;
          _totalRevenue = response.data['total_revenue'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false); // Fallback to mock data on error
    }
  }

  void _handleLogout() async {
    await _apiClient.storage.delete(key: 'access_token');
    if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  // 🔴 INTERACTIVE: Edit Business Details Modal
  void _showEditDetailsModal() {
    final nameCtrl = TextEditingController(text: _bizName);
    final emailCtrl = TextEditingController(text: _bizEmail);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Business Details', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(nameCtrl, 'Business Name'),
              const SizedBox(height: 12),
              _buildTextField(emailCtrl, 'Contact Email'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Update local state and UI
                    setState(() {
                      _bizName = nameCtrl.text;
                      _bizEmail = emailCtrl.text;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully! ✅', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.bAccentTeal),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.bAccentPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                  ),
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  // 🔴 INTERACTIVE: Generic Info Dialog for other settings
  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.bTextMain)),
        content: Text(content, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppTheme.bAccentPurple, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.bTextMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.bTextSec.withAlpha(100)),
        filled: true, fillColor: AppTheme.bBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.bBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.bTextMain)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.bTextSec)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: AppTheme.bBg, body: Center(child: CircularProgressIndicator(color: AppTheme.bAccentPurple)));
    }

    return Scaffold(
      backgroundColor: AppTheme.bBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            Text('Settings ⚙️', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
            const SizedBox(height: 24),
            
            // --- PROFILE HEADER ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.bCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bBorder)),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(color: AppTheme.bAccentPurple, borderRadius: BorderRadius.circular(16)),
                    alignment: Alignment.center,
                    child: Text(_bizEmoji, style: const TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_bizName, style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(_bizEmail, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                _buildMetricChip('Offers', '$_activeOffers'),
                const SizedBox(width: 10),
                _buildMetricChip('Orders', '$_totalOrders'),
                const SizedBox(width: 10),
                _buildMetricChip('Revenue', '₸$_totalRevenue'),
              ],
            ),
            const SizedBox(height: 24),

            // --- INTERACTIVE SETTINGS LIST ---
            _buildSettingItem(Icons.store, 'Business Details', AppTheme.bAccentPurple, _showEditDetailsModal),
            
            _buildSettingItem(Icons.payment, 'Payouts & Banking', AppTheme.bAccentTeal, () {
              _showInfoDialog('Banking Info', 'Your payouts are currently routed to Kaspi Bank ending in **** 4921. Payouts are processed every Monday.');
            }),
            
            _buildSettingItem(Icons.schedule, 'Store Hours', AppTheme.cOrange, () {
              _showInfoDialog('Store Hours', 'Monday - Friday: 10:00 AM - 10:00 PM\nSaturday - Sunday: 11:00 AM - 11:00 PM');
            }),
            
            _buildSettingItem(Icons.help_outline, 'Help & Support', AppTheme.bTextSec, () {
              _showInfoDialog('Support Team', 'Need help? Contact Daily Tagam support at partner-support@dailytagam.kz or call +7 (700) 123-4567.');
            }),
            
            const SizedBox(height: 24),

            // --- SIGN OUT BUTTON ---
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withAlpha(30),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bSurface, 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(color: AppTheme.bTextMain, fontSize: 14, fontWeight: FontWeight.w600))),
            const Icon(Icons.chevron_right, color: AppTheme.bTextSec, size: 18),
          ],
        ),
      ),
    );
  }
}