import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';

class CustomerFeedScreen extends StatefulWidget {
  const CustomerFeedScreen({super.key});

  @override
  State<CustomerFeedScreen> createState() => _CustomerFeedScreenState();
}

class _CustomerFeedScreenState extends State<CustomerFeedScreen> {
  final ApiClient _apiClient = ApiClient();
  
  List<dynamic> _liveOffers = [];
  bool _isLoadingDeals = true;
  String _userName = "Guest";
  int _mealsSaved = 0;
  List<dynamic> _nearbyRestaurants = [];
  String _activeCategory = 'All';

  @override
  void initState() {
    super.initState();
    _fetchLiveOffers();
    _fetchDashboardData(); 
  }

  Future<void> _fetchLiveOffers() async {
    try {
      final response = await _apiClient.dio.get('/offers'); 
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _liveOffers = response.data;
          _isLoadingDeals = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingDeals = false);
    }
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/users/me/dashboard');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _userName = response.data['name'] ?? "Aizat Bekova";
          _mealsSaved = response.data['meals_saved'] ?? 142;
          _nearbyRestaurants = response.data['nearby_restaurants'] ?? [];
        });
      }
    } catch (e) {
      // Fallback for UI testing if backend is unreachable
      setState(() {
        _userName = "Aizat Bekova";
        _mealsSaved = 142;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SingleChildScrollView(
        // Padding bottom ensures the scrolling content clears the floating AppLayout taskbar
        padding: const EdgeInsets.only(bottom: 90), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHomeHeader(),
            _buildImpactBanner(),
            _buildSectionHeader('Categories', null),
            _buildCategories(),
            _buildSectionHeader('⚡ Best Deals', '/all-deals'),
            _buildBestDealsSection(),
            _buildSectionHeader('🏪 Nearby', '/all-restaurants'),
            _buildNearbySection(),
          ],
        ),
      ),
    );
  }

  // --- REPLICATING: .home-header ---
  Widget _buildHomeHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8F0), Color(0xFFF0FDF4)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good morning!', style: TextStyle(fontSize: 13, color: AppTheme.cTextSec)),
                    const SizedBox(height: 2),
                    Text(
                      '$_userName 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.cTextMain),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  _buildIconBadge(Icons.notifications_none, '3', () => Navigator.pushNamed(context, '/notifications')),
                  const SizedBox(width: 10),
                  _buildIconBadge(Icons.shopping_bag_outlined, '2', () => Navigator.pushNamed(context, '/cart')),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          // --- REPLICATING: .search-bar ---
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/explore'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 24, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppTheme.cTextSec.withAlpha(150), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Search food or restaurant...', style: TextStyle(color: AppTheme.cTextSec.withAlpha(150), fontSize: 14)),
                  ),
                  Icon(Icons.tune, color: AppTheme.cOrange, size: 18),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 24)],
            ),
            child: Icon(icon, color: AppTheme.cTextMain, size: 20),
          ),
          Positioned(
            top: -4, right: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.cOrange,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.cBg, width: 2),
              ),
              child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // --- REPLICATING: .impact-banner ---
  Widget _buildImpactBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/eco-impact'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFFF6B00)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌱 Saved from waste today', style: TextStyle(color: Colors.white.withAlpha(230), fontSize: 12)),
                Text('$_mealsSaved meals', style: GoogleFonts.sora(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2)),
                Text('in your city • Tap to see your impact', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11)),
              ],
            ),
            const Text('🌍', style: TextStyle(fontSize: 44)),
          ],
        ),
      ),
    );
  }

  // --- REPLICATING: .section-header ---
  Widget _buildSectionHeader(String title, String? routeUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
          if (routeUrl != null)
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, routeUrl),
              child: Text('See all', style: TextStyle(fontSize: 13, color: AppTheme.cOrange, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  // --- REPLICATING: .cat-pill ---
  Widget _buildCategories() {
    final categories = ['All', '🍕 Pizza', '🥐 Bakery', '🍜 Asian', '🍰 Dessert', '🥗 Healthy', '🍣 Sushi'];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = _activeCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _activeCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- REPLICATING: .food-card ---
  Widget _buildBestDealsSection() {
    if (_isLoadingDeals) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    
    // Mocking data based on your HTML prototype if backend is empty during testing
    final items = _liveOffers.isEmpty ? [
      {"title": "Pizza Combo", "rest": "Napoli Pizza", "emoji": "🍕", "old": "3,500", "new": "1,050", "badge": "70% OFF", "time": "2h left"},
      {"title": "Sushi Set", "rest": "Tokyo Roll", "emoji": "🍱", "old": "5,200", "new": "2,600", "badge": "Bonus", "time": "4h left"},
    ] : _liveOffers;

    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final offer = items[index];
          final badgeText = offer['badge']?.toString() ?? 'SALE';
          final isBonus = badgeText == 'Bonus';
          final title = offer['title']?.toString() ?? offer['name']?.toString() ?? 'Special Deal';
          final rest = offer['restaurant_name']?.toString() ?? offer['rest']?.toString() ?? 'Restaurant';
          final oldPrice = offer['old']?.toString() ?? offer['original_price']?.toString() ?? '';
          final newPrice = offer['new']?.toString() ?? offer['discounted_price']?.toString() ?? '';
          final timeLabel = offer['time']?.toString() ?? 'Now';
          final emoji = offer['emoji']?.toString() ?? '🍽️';

          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/detail'), // Future detail screen connection
            child: Container(
              width: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 24, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFF0FDF4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      child: Stack(
                        children: [
                          Center(child: Text(emoji, style: const TextStyle(fontSize: 52))),
                          Positioned(
                            top: 10, left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: isBonus ? AppTheme.cGreen : AppTheme.cOrange, borderRadius: BorderRadius.circular(50)),
                              child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                        const SizedBox(height: 4),
                        Text('🏪 $rest', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppTheme.cTextSec)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  if (oldPrice.isNotEmpty)
                                    Flexible(
                                      child: Text(
                                        '₸$oldPrice',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 11, color: AppTheme.cTextSec.withAlpha(150), decoration: TextDecoration.lineThrough),
                                      ),
                                    ),
                                  if (oldPrice.isNotEmpty) const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '₸$newPrice',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cOrange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time_filled, size: 11, color: AppTheme.cOrange),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      timeLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 11, color: AppTheme.cTextSec),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
    );
  }

  // --- REPLICATING: .rest-card ---
  Widget _buildNearbySection() {
    final rests = _nearbyRestaurants.isEmpty ? [
      {"name": "Napoli Pizza", "emoji": "🍕", "rating": "4.8", "dist": "0.3 km", "cat": "Pizza", "deals": "5"},
      {"name": "Tokyo Roll", "emoji": "🍱", "rating": "4.6", "dist": "0.7 km", "cat": "Asian", "deals": "3"},
    ] : _nearbyRestaurants;

    return Column(
      children: rests.map((biz) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/detail'),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 24, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFFFF3E0), Color(0xFFF0FDF4)]),
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: Center(child: Text(biz['emoji'] ?? '🏪', style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        biz['name']?.toString() ?? 'Restaurant',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.star, color: AppTheme.cOrangeLight, size: 10),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              '${biz['rating']} • ${biz['dist']} • ${biz['cat']}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: AppTheme.cTextSec),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(biz['deals'].toString(), style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cOrange)),
                    Text('deals', style: TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
                  ],
                )
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}