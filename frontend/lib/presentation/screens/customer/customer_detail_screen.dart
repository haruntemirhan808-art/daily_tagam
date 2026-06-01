import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class CustomerDetailScreen extends StatefulWidget {
  const CustomerDetailScreen({super.key});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;

  void _changeQty(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 99);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Strictly dynamic data from the routed item
    final item = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    
    final String title = item['title']?.toString() ?? 'Food Deal';
    final String rest = item['restaurant_name']?.toString() ?? item['rest']?.toString() ?? 'Restaurant';
    final String emoji = item['emoji']?.toString() ?? '🍽️';
    final String description = item['description']?.toString() ?? 'No description provided by the restaurant.';
    final String distance = item['distance']?.toString() ?? 'Location details unavailable';
    final String stock = item['stock']?.toString() ?? 'Limited stock';
    final String pickupTime = item['pickup_time']?.toString() ?? 'Check with restaurant';
    final String bonusPts = item['bonus_points']?.toString() ?? '0';
    final String itemsCount = item['items_count']?.toString() ?? '1 item';
    
    // Optional specific fields
    final String? couponCode = item['coupon_code']?.toString();
    final String? ecoSavedKg = item['eco_saved_kg']?.toString();

    // Price parsing
    final String newPriceStr = item['discounted_price']?.toString() ?? item['price']?.toString() ?? '0';
    final String oldPriceStr = item['original_price']?.toString() ?? item['old_price']?.toString() ?? newPriceStr;
    
    final int unitPrice = int.tryParse(newPriceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final int oldPrice = int.tryParse(oldPriceStr.replaceAll(RegExp(r'[^0-9]'), '')) ?? unitPrice;

    // Calculate discount tag dynamically
    String discount = item['discount']?.toString() ?? '';
    if (discount.isEmpty && oldPrice > 0 && unitPrice < oldPrice) {
      discount = '${(((oldPrice - unitPrice) / oldPrice) * 100).round()}% OFF';
    } else if (discount.isEmpty) {
      discount = 'SALE';
    }

    final int totalPrice = unitPrice * _quantity;

    return Scaffold(
      backgroundColor: AppTheme.cBg,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.cBorder)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (oldPrice > unitPrice)
                  Text(
                    '₸$oldPrice',
                    style: const TextStyle(fontSize: 12, color: AppTheme.cTextSec, decoration: TextDecoration.lineThrough),
                  ),
                Text(
                  '₸$unitPrice',
                  style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.cOrange),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Simulates adding to cart. This will eventually map to a POST request to save the session.
                    Navigator.of(context).popUntil((route) => route.settings.name == '/feed');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$title added to cart! 🛒')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 18),
                  label: const Text('Add to Cart', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HERO SECTION ---
            Stack(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFF3E0), Color(0xFFF0FDF4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 100)),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withAlpha(75)],
                        stops: const [0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 24)],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.chevron_left, color: AppTheme.cTextMain, size: 20),
                    ),
                  ),
                ),
              ],
            ),

            // --- BODY SECTION ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(title, style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isFavorite = !_isFavorite),
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: const Color(0xFFFFE0E0), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Icon(
                            _isFavorite ? Icons.favorite : Icons.favorite_border, 
                            color: Colors.red, 
                            size: 18
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Restaurant Info (Dynamic)
                  Row(
                    children: [
                      const Icon(Icons.store, color: AppTheme.cOrange, size: 14),
                      const SizedBox(width: 6),
                      Text(rest, style: const TextStyle(fontSize: 13, color: AppTheme.cTextSec)),
                      const SizedBox(width: 8),
                      const Text('•', style: TextStyle(color: AppTheme.cTextSec)),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on, color: AppTheme.cOrange, size: 14),
                      const SizedBox(width: 6),
                      Text(distance, style: const TextStyle(fontSize: 13, color: AppTheme.cTextSec)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tags (Dynamic)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (discount != 'SALE') _buildTag(Icons.local_fire_department, discount, AppTheme.cOrangePale, AppTheme.cOrange),
                      _buildTag(Icons.eco, 'Save from waste', AppTheme.cGreenPale, AppTheme.cGreen),
                      _buildTag(Icons.bolt, '$stock left', AppTheme.cOrangePale, AppTheme.cOrange),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info Grid (Dynamic)
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildInfoCard('📦', 'Pickup only', 'Order type'),
                      _buildInfoCard('⏰', pickupTime, 'Pickup time'),
                      _buildInfoCard('🌟', '+$bonusPts pts', 'Bonus points'),
                      _buildInfoCard(emoji, itemsCount, 'In this package'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quantity Control
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(color: AppTheme.cBg, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        _buildQtyBtn('−', () => _changeQty(-1)),
                        const SizedBox(width: 14),
                        Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                        const SizedBox(width: 14),
                        _buildQtyBtn('+', () => _changeQty(1)),
                        const Expanded(child: Center(child: Text('quantity', style: TextStyle(fontSize: 13, color: AppTheme.cTextSec)))),
                        Text('₸$totalPrice', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cOrange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Coupon Card (Only renders if a coupon_code exists in the DB response)
                  if (couponCode != null && couponCode.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFF8F0), Color(0xFFFFF3E0)]),
                        border: Border.all(color: AppTheme.cOrangeLight),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🎟️', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Special Coupon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                                const SizedBox(height: 2),
                                Text('Apply at checkout for extra savings', style: TextStyle(fontSize: 12, color: AppTheme.cTextSec)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppTheme.cOrange, borderRadius: BorderRadius.circular(8)),
                            child: Text(couponCode, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Description (Dynamic)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About this deal', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(fontSize: 13, color: AppTheme.cTextSec, height: 1.6),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Eco Badge (Only renders if eco_saved_kg exists in the DB response)
                  if (ecoSavedKg != null && ecoSavedKg.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppTheme.cGreenPale, borderRadius: BorderRadius.circular(50)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.eco, color: AppTheme.cGreen, size: 14),
                          const SizedBox(width: 6),
                          Text('You\'ll save $ecoSavedKg kg of food waste', style: const TextStyle(color: AppTheme.cGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color bgColor, Color fgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(50)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fgColor, size: 12),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: fgColor, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String icon, String val, String lbl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
          Text(lbl, style: const TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.cBorder),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
      ),
    );
  }
}