import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/network/api_client.dart';

class CustomerFeedScreen extends StatefulWidget {
  const CustomerFeedScreen({super.key});

  @override
  State<CustomerFeedScreen> createState() => _CustomerFeedScreenState();
}

class _CustomerFeedScreenState extends State<CustomerFeedScreen> {
  final ApiClient _apiClient = ApiClient();
  
  // --- DYNAMIC STATE VARIABLES ---
  List<dynamic> _liveOffers = [];
  bool _isLoadingDeals = true;

  String _userName = "Guest";
  int _mealsSaved = 0;
  List<dynamic> _nearbyRestaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchLiveOffers();
    _fetchDashboardData(); // Fetch the new dynamic context
  }

  // 1. Fetch active food listings
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
      debugPrint("Failed to fetch offers: $e");
      if (mounted) setState(() => _isLoadingDeals = false);
    }
  }

  // 2. Fetch the user's name, impact, and local businesses
  Future<void> _fetchDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/users/me/dashboard');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _userName = response.data['name'];
          _mealsSaved = response.data['meals_saved'];
          _nearbyRestaurants = response.data['nearby_restaurants'];
        });
      }
    } catch (e) {
      debugPrint("Failed to fetch dashboard context: $e");
    }
  }

  // --- THEME COLORS ---
  final Color _orange = const Color(0xFFFF8A00);
  final Color _textMain = const Color(0xFF1A1A2E);
  final Color _textSec = const Color(0xFF64748B);
  final Color _bg = const Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderAndSearch(),
                _buildImpactBanner(),
                _buildCategories(),
                _buildBestDealsSection(),
                _buildNearbySection(),
              ],
            ),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),
        ],
      ),
    );
  }

  Widget _buildHeaderAndSearch() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8F0), Color(0xFFF0FDF4)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good morning!', style: TextStyle(fontSize: 13, color: _textSec)),
                  // DYNAMIC: Displaying the real backend name
                  Text('$_userName 👋', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
                ],
              ),
              Row(
                children: [
                  _buildIconBadge(Icons.notifications_none, '3'),
                  const SizedBox(width: 10),
                  _buildIconBadge(Icons.shopping_bag_outlined, '2'),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search food or restaurant...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: Icon(Icons.tune, color: _orange),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, String count) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
          ),
          child: Icon(icon, color: _textMain, size: 20),
        ),
        Positioned(
          top: -4, right: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _orange,
              shape: BoxShape.circle,
              border: Border.all(color: _bg, width: 2),
            ),
            child: Text(count, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        )
      ],
    );
  }

  Widget _buildImpactBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
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
              const Text('🌱 Saved from waste today', style: TextStyle(color: Colors.white70, fontSize: 12)),
              // DYNAMIC: Displaying actual meals saved
              Text('$_mealsSaved meals', style: GoogleFonts.sora(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, height: 1.2)),
              const Text('in your city • Tap to see your impact', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const Text('🌍', style: TextStyle(fontSize: 44)),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['All', '🍕 Pizza', '🥐 Bakery', '🍜 Asian', '🍰 Dessert'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text('Categories', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: _textMain)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 36,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              bool isSelected = index == 0;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? _orange : Colors.white,
                  border: Border.all(color: isSelected ? _orange : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : _textSec,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBestDealsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('⚡ Best Deals', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: _textMain)),
              Text('See all', style: TextStyle(fontSize: 13, color: _orange, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (_isLoadingDeals)
          const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
        else if (_liveOffers.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text("No deals available right now. Check back soon!", style: TextStyle(color: _textSec)),
            ),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _liveOffers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final offer = _liveOffers[index];
                return _buildDealCard(offer);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDealCard(Map<String, dynamic> offer) {
    final originalPrice = double.tryParse(offer['original_price'].toString()) ?? 0.0;
    final discountedPrice = double.tryParse(offer['discounted_price'].toString()) ?? 0.0;
    
    int discountPercent = 0;
    if (originalPrice > 0) {
      discountPercent = (((originalPrice - discountedPrice) / originalPrice) * 100).round();
    }

    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF0FDF4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Stack(
                children: [
                  const Center(child: Text('🍽️', style: TextStyle(fontSize: 50))), 
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(50)),
                      child: Text('$discountPercent% OFF', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
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
                Text(offer['title'] ?? 'Food Deal', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textMain)),
                const SizedBox(height: 2),
                Text('🏪 Restaurant Partner', style: TextStyle(fontSize: 11, color: _textSec)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('₸${originalPrice.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10, color: Colors.grey, decoration: TextDecoration.lineThrough)),
                        Text('₸${discountedPrice.toStringAsFixed(0)}', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.bold, color: _orange)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time_filled, size: 12, color: _orange),
                        const SizedBox(width: 2),
                        const Text('2h', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNearbySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🏪 Nearby', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: _textMain)),
              Text('See all', style: TextStyle(fontSize: 13, color: _orange, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        
        // DYNAMIC: Mapping over real businesses retrieved from FastAPI
        if (_nearbyRestaurants.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text("No partner restaurants in your area yet.", style: TextStyle(color: _textSec)),
            ),
          )
        else
          ..._nearbyRestaurants.map((biz) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text('🏪', style: TextStyle(fontSize: 28))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(biz['name'] ?? 'Restaurant', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textMain)),
                        const SizedBox(height: 4),
                        Text('⭐ ${biz['rating']} • ${biz['distance']} • Food', style: TextStyle(fontSize: 12, color: _textSec)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(biz['active_deals'].toString(), style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: _orange)),
                      Text('deals', style: TextStyle(fontSize: 10, color: _textSec)),
                    ],
                  )
                ],
              ),
            );
          }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, 'Home', true),
          _buildNavItem(Icons.explore_outlined, 'Explore', false),
          
          Transform.translate(
            offset: const Offset(0, -12),
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF8A00), Color(0xFFFF6B00)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: _orange.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 24),
            ),
          ),
          
          _buildNavItem(Icons.card_giftcard_outlined, 'Rewards', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    final color = isActive ? _orange : _textSec.withValues(alpha: 0.6);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}