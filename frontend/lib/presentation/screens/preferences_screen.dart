import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // Prototype Grid Categories[cite: 2]
  final List<Map<String, String>> _categories = [
    {'id': 'fast_food', 'name': 'Fast Food', 'emoji': '🍔'},
    {'id': 'bakery', 'name': 'Bakery', 'emoji': '🥐'},
    {'id': 'asian', 'name': 'Asian Food', 'emoji': '🍜'},
    {'id': 'desserts', 'name': 'Desserts', 'emoji': '🍰'},
    {'id': 'healthy', 'name': 'Healthy Food', 'emoji': '🥗'},
    {'id': 'drinks', 'name': 'Drinks', 'emoji': '🧃'},
    {'id': 'sushi', 'name': 'Sushi', 'emoji': '🍣'},
    {'id': 'pizza', 'name': 'Pizza', 'emoji': '🍕'},
  ];

  final Set<String> _selectedPrefs = {};
  bool _isLoading = false;

  void _savePreferences() async {
    setState(() => _isLoading = true);
    
    try {
      await ApiClient().dio.post('/users/me/preferences', data: _selectedPrefs.toList());
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // 🔴 DYNAMIC ROUTING: Checks if the user is in the settings flow or onboarding flow
    if (Navigator.canPop(context)) {
      Navigator.pop(context); // Pops back to Settings
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences Updated!')),
      );
    } else {
      Navigator.of(context).pushReplacementNamed('/feed'); // Pushes to Home Feed
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determines if the user came from Settings
    final bool isFromSettings = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- DYNAMIC BACK BUTTON ---
              if (isFromSettings) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(10), 
                      border: Border.all(color: AppTheme.cBorder)
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.chevron_left, size: 18, color: AppTheme.cTextMain),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Text('What do you love? 😍', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
              const SizedBox(height: 6),
              const Text('Select your food preferences to get personalized deals', style: TextStyle(fontSize: 14, color: AppTheme.cTextSec)),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedPrefs.contains(cat['id']);
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedPrefs.remove(cat['id']);
                          } else {
                            _selectedPrefs.add(cat['id']!);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.cOrangePale : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isSelected ? AppTheme.cOrange : AppTheme.cBorder, width: 2),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(cat['emoji']!, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(cat['name']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.cTextMain)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _savePreferences,
                  child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 🔴 DYNAMIC BUTTON TEXT
                          Text(isFromSettings ? 'Save Preferences' : 'Continue', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                          if (!isFromSettings) ...[
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ]
                        ],
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}