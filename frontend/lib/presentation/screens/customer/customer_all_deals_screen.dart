import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class CustomerAllDealsScreen extends StatefulWidget {
  const CustomerAllDealsScreen({super.key});

  @override
  State<CustomerAllDealsScreen> createState() => _CustomerAllDealsScreenState();
}

class _CustomerAllDealsScreenState extends State<CustomerAllDealsScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _deals = [];

  @override
  void initState() {
    super.initState();
    _fetchDeals();
  }

  Future<void> _fetchDeals() async {
    try {
      final response = await _apiClient.dio.get('/offers');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _deals = response.data ?? [];
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
                  Text('All Deals ⚡', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _deals.length,
                      itemBuilder: (context, index) {
                        final item = _deals[index];
                        final String title = item['title']?.toString() ?? 'Deal';
                        final String rest = item['restaurant_name']?.toString() ?? 'Restaurant';
                        final String price = item['discounted_price']?.toString() ?? '0';
                        final String old = item['original_price']?.toString() ?? '0';
                        final String emoji = item['emoji']?.toString() ?? '🍽️';

                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 72, height: 72,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFF0FDF4)]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(emoji, style: const TextStyle(fontSize: 34)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                                      Text('🏪 $rest', style: const TextStyle(fontSize: 12, color: AppTheme.cTextSec)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text('₸$price', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.cOrange)),
                                          const SizedBox(width: 4),
                                          Text('₸$old', style: const TextStyle(fontSize: 11, color: AppTheme.cTextSec, decoration: TextDecoration.lineThrough)),
                                          const Spacer(),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(color: AppTheme.cOrange, borderRadius: BorderRadius.circular(50)),
                                            child: const Text('SALE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
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