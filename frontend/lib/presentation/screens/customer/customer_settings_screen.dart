import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class CustomerSettingsScreen extends StatefulWidget {
  const CustomerSettingsScreen({super.key});

  @override
  State<CustomerSettingsScreen> createState() => _CustomerSettingsScreenState();
}

class _CustomerSettingsScreenState extends State<CustomerSettingsScreen> {
  // Local state for interactive toggle switches
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _ecoAlertsEnabled = true;

  // Sign out functionality
  Future<void> _handleSignOut() async {
    // 1. Delete the JWT token from secure storage
    await ApiClient().storage.delete(key: 'access_token');
    
    if (!mounted) return;
    
    // 2. Clear the entire navigation history and push back to Auth
    Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppTheme.cBg, borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.center,
                    child: const Icon(Icons.chevron_left, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Text('Settings ⚙️', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
              ],
            ),
            const SizedBox(height: 24),

            // --- ACCOUNT SECTION ---
            _buildSectionTitle('Account'),
            _buildMenuCard([
              _buildActionItem('👤', 'Edit Profile', const Color(0xFFEFF6FF), isLast: false),
              _buildActionItem('🔒', 'Change Password', AppTheme.cOrangePale, isLast: false),
              _buildActionItem('📱', 'Phone Number', AppTheme.cGreenPale, isLast: true),
            ]),

            // --- NOTIFICATIONS SECTION ---
            _buildSectionTitle('Notifications'),
            _buildMenuCard([
              _buildToggleItem('🔔', 'Push Notifications', AppTheme.cOrangePale, _pushEnabled, (val) => setState(() => _pushEnabled = val), isLast: false),
              _buildToggleItem('📧', 'Email Updates', const Color(0xFFEFF6FF), _emailEnabled, (val) => setState(() => _emailEnabled = val), isLast: false),
              _buildToggleItem('🌱', 'Eco Impact Alerts', AppTheme.cGreenPale, _ecoAlertsEnabled, (val) => setState(() => _ecoAlertsEnabled = val), isLast: true),
            ]),

            // --- PREFERENCES SECTION ---
            _buildSectionTitle('Preferences'),
            _buildMenuCard([
              // 🔴 INTERACTIVE: Routes back to your Preferences Grid
              _buildActionItem('🍕', 'Food Preferences', AppTheme.cOrangePale, isLast: false, onTap: () => Navigator.pushNamed(context, '/preferences')),
              _buildActionItem('📍', 'Delivery Location', AppTheme.cGreenPale, isLast: false),
              _buildActionItem('🌐', 'Language', const Color(0xFFEFF6FF), isLast: true),
            ]),

            // --- PRIVACY & LEGAL ---
            _buildSectionTitle('Privacy & Legal'),
            _buildMenuCard([
              _buildActionItem('🛡️', 'Privacy Policy', const Color(0xFFEFF6FF), isLast: false),
              _buildActionItem('📄', 'Terms of Service', AppTheme.cOrangePale, isLast: true),
            ]),
            
            const SizedBox(height: 10),

            // --- SIGN OUT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _handleSignOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withAlpha(25),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),

            const SizedBox(height: 16),
            const Center(
              child: Text('Daily Tagam v4.0.0', style: TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.cTextSec, letterSpacing: 1.2),
      ),
    );
  }

  // Helper for the White Card Container
  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  // Helper for Standard Action Items
  Widget _buildActionItem(String emoji, String title, Color bgColor, {required bool isLast, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.cBorder)),
        ),
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

  // Helper for Custom Animated Toggles
  Widget _buildToggleItem(String emoji, String title, Color bgColor, bool isEnabled, Function(bool) onChanged, {required bool isLast}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppTheme.cBorder)),
      ),
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
          GestureDetector(
            onTap: () => onChanged(!isEnabled),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44, height: 24,
              decoration: BoxDecoration(
                color: isEnabled ? AppTheme.cGreen : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: isEnabled ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    width: 20, height: 20,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}