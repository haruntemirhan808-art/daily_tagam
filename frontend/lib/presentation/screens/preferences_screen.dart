import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../core/network/api_client.dart';

class FoodPreference {
  final String id;
  final String name;
  final IconData icon;

  FoodPreference({required this.id, required this.name, required this.icon});
}

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  // 1. Instantiating repository reference to clear the '_authRepository' error
  final AuthRepository _authRepository = AuthRepository(ApiClient());
  
  // 2. Local state tracking to clear the '_isLoading' errors
  bool _isLoading = false;

  final List<FoodPreference> _categories = [
    FoodPreference(id: 'fast_food', name: 'Fast Food', icon: Icons.local_pizza),
    FoodPreference(id: 'bakery', name: 'Bakery', icon: Icons.bakery_dining),
    FoodPreference(id: 'asian', name: 'Asian Food', icon: Icons.ramen_dining),
    FoodPreference(id: 'desserts', name: 'Desserts', icon: Icons.cake),
    FoodPreference(id: 'healthy', name: 'Healthy Food', icon: Icons.eco),
    FoodPreference(id: 'drinks', name: 'Drinks', icon: Icons.local_drink),
    FoodPreference(id: 'sushi', name: 'Sushi', icon: Icons.set_meal),
    FoodPreference(id: 'burgers', name: 'Burgers', icon: Icons.lunch_dining),
  ];

  final Set<String> _selectedPreferences = {};

  void _togglePreference(String id) {
    if (_isLoading) return; // Prevent changing selections during active network submit
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40.0 : 24.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'What do you love?',
                      style: TextStyle(
                        fontSize: isDesktop ? 36 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF11142D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('😍', style: TextStyle(fontSize: isDesktop ? 36 : 28)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Select your food preferences to get personalized deals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 48),

                Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: _categories.map((category) {
                    final isSelected = _selectedPreferences.contains(category.id);
                    
                    return InkWell(
                      onTap: () => _togglePreference(category.id),
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isDesktop ? 180 : 150,
                        height: isDesktop ? 160 : 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFFFF7A00) : Colors.grey.shade200,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? const Color(0xFFFF7A00).withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              category.icon,
                              size: isDesktop ? 44 : 36,
                              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF2D3142),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                fontSize: isDesktop ? 15 : 14,
                                color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFF2D3142),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 60),

                SizedBox(
                  width: isDesktop ? 300 : double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7A00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                    onPressed: (_selectedPreferences.isEmpty || _isLoading)
                        ? null
                        : () async {
                            setState(() => _isLoading = true);

                            final categoriesList = _selectedPreferences.toList();
                            
                            // FIX: Capture navigator context state safely before entering the async block
                            final navigator = Navigator.of(context);
                            final scaffoldMessenger = ScaffoldMessenger.of(context);

                            bool savedSuccessfully = await _authRepository.savePreferences(categoriesList);

                            if (!mounted) return;
                            setState(() => _isLoading = false);

                            if (savedSuccessfully) {
                              // Use the safely stored navigator instance context across the async gap
                              navigator.pushReplacementNamed('/feed');
                            } else {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(content: Text('Failed to save choices. Please verify server connection.')),
                              );
                            }
                          },
                    child: _isLoading 
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Continue',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}