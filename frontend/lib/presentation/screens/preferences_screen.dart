import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/network/api_client.dart';

class FoodPreference {
  final String id;
  final String name;
  final String emoji;

  FoodPreference({required this.id, required this.name, required this.emoji});
}

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final AuthRepository _authRepository = AuthRepository(ApiClient());
  bool _isLoading = false;

  // Matching the prototype's emoji categories
  final List<FoodPreference> _categories = [
    FoodPreference(id: 'fast_food', name: 'Fast Food', emoji: '🍕'),
    FoodPreference(id: 'bakery', name: 'Bakery', emoji: '🥐'),
    FoodPreference(id: 'asian', name: 'Asian Food', emoji: '🍜'),
    FoodPreference(id: 'desserts', name: 'Desserts', emoji: '🍰'),
    FoodPreference(id: 'healthy', name: 'Healthy Food', emoji: '🥗'),
    FoodPreference(id: 'drinks', name: 'Drinks', emoji: '🧃'),
    FoodPreference(id: 'sushi', name: 'Sushi', emoji: '🍣'),
    FoodPreference(id: 'burgers', name: 'Burgers', emoji: '🍔'),
  ];

  final Set<String> _selectedPreferences = {};

  // Theme Colors
  final Color _orange = const Color(0xFFFF8A00);
  final Color _bg = const Color(0xFFF8F9FA);
  final Color _textMain = const Color(0xFF1A1A2E);
  final Color _textSec = const Color(0xFF64748B);
  final Color _border = const Color(0xFFE2E8F0);
  final Color _orangePale = const Color(0xFFFFF3E0);

  void _togglePreference(String id) {
    if (_isLoading) return;
    setState(() {
      if (_selectedPreferences.contains(id)) {
        _selectedPreferences.remove(id);
      } else {
        _selectedPreferences.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What do you love? 😍', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: _textMain)),
                  const SizedBox(height: 6),
                  Text('Select your food preferences to get personalized deals', style: TextStyle(fontSize: 14, color: _textSec)),
                  const SizedBox(height: 24),
                  
                  // Custom Grid Layout matching the HTML prototype
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedPreferences.contains(category.id);
                      
                      return GestureDetector(
                        onTap: () => _togglePreference(category.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isSelected ? _orangePale : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? _orange : _border, width: 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(category.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(category.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textMain)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // The crucial Continue Button & Routing Logic
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: (_selectedPreferences.isEmpty || _isLoading)
                          ? null
                          : () async {
                              setState(() => _isLoading = true);
                              final categoriesList = _selectedPreferences.toList();
                              
                              // Capture navigator and messenger states BEFORE the await
                              final navigator = Navigator.of(context);
                              final scaffoldMessenger = ScaffoldMessenger.of(context);

                              // Save to database
                              bool savedSuccessfully = await _authRepository.savePreferences(categoriesList);

                              if (!mounted) return;
                              setState(() => _isLoading = false);

                              if (savedSuccessfully) {
                                // Explicitly transfer to the customer feed screen
                                navigator.pushReplacementNamed('/feed');
                              } else {
                                // If it fails, let the user know so they aren't stuck clicking a dead button
                                scaffoldMessenger.showSnackBar(
                                  const SnackBar(content: Text('Failed to save choices. Did you drop/refresh your database table?')),
                                );
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Continue'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}