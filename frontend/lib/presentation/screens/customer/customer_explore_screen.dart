import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class CustomerExploreScreen extends StatefulWidget {
  const CustomerExploreScreen({super.key});

  @override
  State<CustomerExploreScreen> createState() => _CustomerExploreScreenState();
}

class _CustomerExploreScreenState extends State<CustomerExploreScreen> {
  final ApiClient _apiClient = ApiClient();
  
  bool _isLoading = true;
  List<dynamic> _exploreDeals = [];
  String _activeCategory = 'All';

  final List<String> _categories = [
    'All',
    '🍕 Pizza',
    '🍣 Sushi',
    '🥐 Bakery',
    '🍔 Burger',
    '🥗 Healthy',
    '🍰 Dessert'
  ];

  @override
  void initState() {
    super.initState();
    _fetchExploreDeals();
  }

  Future<void> _fetchExploreDeals() async {
    try {
      final response = await _apiClient.dio.get('/offers');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _exploreDeals = response.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch explore deals: $e");
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
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.cBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.chevron_left, size: 18, color: AppTheme.cTextMain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Explore Deals',
                    style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain),
                  ),
                ],
              ),
            ),

            // --- SEARCH BAR ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search food, restaurant...',
                    hintStyle: TextStyle(color: AppTheme.cTextSec.withAlpha(150), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppTheme.cTextSec.withAlpha(150), size: 18),
                    prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // --- FILTER ROW ---
            SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isActive = _activeCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _activeCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.cOrange : Colors.white,
                        border: Border.all(color: isActive ? AppTheme.cOrange : AppTheme.cBorder, width: 1.5),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isActive ? Colors.white : AppTheme.cTextSec,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // --- DYNAMIC GRID VIEW ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _exploreDeals.isEmpty
                      ? const Center(
                          child: Text(
                            "No deals available matching this category.",
                            style: TextStyle(color: AppTheme.cTextSec, fontSize: 14),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.92,
                          ),
                          itemCount: _exploreDeals.length,
                          itemBuilder: (context, index) {
                            final item = _exploreDeals[index];
                            
                            // Safe dynamic parsing from DB
                            final String title = item['title']?.toString() ?? 'Food Deal';
                            final String rest = item['restaurant_name']?.toString() ?? item['rest']?.toString() ?? 'Restaurant';
                            final String price = item['discounted_price']?.toString() ?? item['price']?.toString() ?? '0';
                            final String emoji = item['emoji']?.toString() ?? '🍽️';
                            
                            // Calculate discount if missing
                            String discountStr = item['discount']?.toString() ?? '';
                            if (discountStr.isEmpty && item['original_price'] != null && item['discounted_price'] != null) {
                              double orig = double.tryParse(item['original_price'].toString()) ?? 0;
                              double disc = double.tryParse(item['discounted_price'].toString()) ?? 0;
                              if (orig > 0) {
                                discountStr = '${(((orig - disc) / orig) * 100).round()}% OFF';
                              }
                            }
                            if (discountStr.isEmpty) discountStr = 'SALE';

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/detail', arguments: item);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 16, offset: const Offset(0, 3))],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 110,
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Color(0xFFFFF3E0), Color(0xFFF0FDF4)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      child: Stack(
                                        children: [
                                          Center(child: Text(emoji, style: const TextStyle(fontSize: 32))),
                                          Positioned(
                                            top: 8, left: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppTheme.cOrange,
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              child: Text(
                                                discountStr,
                                                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.cTextMain),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            rest,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 11, color: AppTheme.cTextSec),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '₸$price',
                                            style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.cOrange),
                                          ),
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