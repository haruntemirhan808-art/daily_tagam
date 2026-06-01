import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class CustomerAllRestaurantsScreen extends StatefulWidget {
  const CustomerAllRestaurantsScreen({super.key});

  @override
  State<CustomerAllRestaurantsScreen> createState() => _CustomerAllRestaurantsScreenState();
}

class _CustomerAllRestaurantsScreenState extends State<CustomerAllRestaurantsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _rests = [];

  @override
  void initState() {
    super.initState();
    _fetchRests();
  }

  Future<void> _fetchRests() async {
    try {
      final response = await _apiClient.dio.get('/users/me/dashboard');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _rests = response.data['nearby_restaurants'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppTheme.cBg, borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: const Icon(Icons.chevron_left, size: 18, color: AppTheme.cTextMain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Nearby Restaurants 🏪', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _rests.length,
                      itemBuilder: (context, index) {
                        final biz = _rests[index];
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: biz),
                          child: Container(
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
                                  width: 56, height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFF0FDF4)]),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(biz['emoji'] ?? '🏪', style: const TextStyle(fontSize: 26)),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(biz['name'] ?? 'Restaurant', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star, color: AppTheme.cOrangeLight, size: 10),
                                          const SizedBox(width: 4),
                                          Text('${biz['rating'] ?? '4.5'} • ${biz['dist'] ?? '0.5 km'} • Food', style: const TextStyle(fontSize: 12, color: AppTheme.cTextSec)),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${biz['deals'] ?? 1}', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cOrange)),
                                    const Text('deals', style: TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}