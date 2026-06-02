import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class BusinessDashboardScreen extends StatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  State<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends State<BusinessDashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  String _activeFilter = 'Today';
  final List<String> _filters = ['Today', 'This Week', 'This Month'];
  List<Map<String, dynamic>> _dashboardKpis = [];

  // 🔴 INTERACTIVE: Dynamic KPI Data mapped to the selected filter
  final Map<String, List<Map<String, dynamic>>> _kpiData = {
    'Today': [
      {'emoji': '🍽️', 'val': '28', 'lbl': 'Meals Sold', 'change': '↑ +12% vs yesterday', 'isUp': true, 'color': AppTheme.bAccentPurple},
      {'emoji': '♻️', 'val': '11.2kg', 'lbl': 'Waste Saved', 'change': '↑ +8% vs yesterday', 'isUp': true, 'color': AppTheme.bAccentTeal},
      {'emoji': '💰', 'val': '₸42K', 'lbl': 'Revenue Today', 'change': '↑ +5% vs avg', 'isUp': true, 'color': AppTheme.cOrange},
      {'emoji': '⭐', 'val': '4.8', 'lbl': 'Rating', 'change': '↑ 3 new reviews', 'isUp': true, 'color': const Color(0xFFFF6B9D)},
    ],
    'This Week': [
      {'emoji': '🍽️', 'val': '194', 'lbl': 'Meals Sold', 'change': '↑ +22% vs last week', 'isUp': true, 'color': AppTheme.bAccentPurple},
      {'emoji': '♻️', 'val': '78.5kg', 'lbl': 'Waste Saved', 'change': '↑ +15% vs last week', 'isUp': true, 'color': AppTheme.bAccentTeal},
      {'emoji': '💰', 'val': '₸291K', 'lbl': 'Revenue Week', 'change': '↓ -2% vs avg', 'isUp': false, 'color': AppTheme.cOrange},
      {'emoji': '⭐', 'val': '4.9', 'lbl': 'Rating', 'change': '↑ 14 new reviews', 'isUp': true, 'color': const Color(0xFFFF6B9D)},
    ],
    'This Month': [
      {'emoji': '🍽️', 'val': '842', 'lbl': 'Meals Sold', 'change': '↑ +45% vs last month', 'isUp': true, 'color': AppTheme.bAccentPurple},
      {'emoji': '♻️', 'val': '340kg', 'lbl': 'Waste Saved', 'change': '↑ +30% vs last month', 'isUp': true, 'color': AppTheme.bAccentTeal},
      {'emoji': '💰', 'val': '₸1.2M', 'lbl': 'Revenue Month', 'change': '↑ +18% vs avg', 'isUp': true, 'color': AppTheme.cOrange},
      {'emoji': '⭐', 'val': '4.8', 'lbl': 'Rating', 'change': '↑ 52 new reviews', 'isUp': true, 'color': const Color(0xFFFF6B9D)},
    ],
  };

  // 🔴 INTERACTIVE: Local state lists for instant UI updates
  List<Map<String, dynamic>> _liveOrders = [];
  List<Map<String, dynamic>> _activeDeals = [];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await _apiClient.dio.get('/business/me/dashboard');
      if (response.statusCode == 200 && mounted) {
        final liveOrders = List<Map<String, dynamic>>.from(response.data['live_orders'] ?? []);
        final activeDeals = List<Map<String, dynamic>>.from(response.data['active_deals'] ?? []);
        final dailyMeals = response.data['daily_meals_sold'] ?? 0;
        final dailyRevenue = response.data['daily_revenue'] ?? 0;
        final totalOrders = response.data['total_orders'] ?? 0;
        final activeOffers = response.data['active_offers'] ?? 0;

        setState(() {
          _liveOrders = liveOrders;
          _activeDeals = activeDeals;
          _dashboardKpis = [
            {
              'emoji': '🍽️',
              'val': '$dailyMeals',
              'lbl': 'Meals Sold',
              'change': 'Today',
              'isUp': true,
              'color': AppTheme.bAccentPurple,
            },
            {
              'emoji': '💰',
              'val': '₸$dailyRevenue',
              'lbl': 'Revenue',
              'change': 'Today',
              'isUp': true,
              'color': AppTheme.cOrange,
            },
            {
              'emoji': '🛒',
              'val': '$totalOrders',
              'lbl': 'Orders',
              'change': 'Total',
              'isUp': true,
              'color': AppTheme.bAccentTeal,
            },
            {
              'emoji': '📦',
              'val': '$activeOffers',
              'lbl': 'Active Offers',
              'change': 'Live',
              'isUp': true,
              'color': const Color(0xFFFF6B9D),
            },
          ];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _liveOrders = [
            {'emoji': '🍕', 'title': 'Order #1042 — Aizat B.', 'sub': 'Pizza Combo × 2 • ₸2,100', 'status': 'New', 'color': AppTheme.bAccentPurple},
            {'emoji': '🥗', 'title': 'Order #1041 — Dana K.', 'sub': 'Caesar Salad × 1 • ₸900', 'status': 'Ready', 'color': AppTheme.bAccentTeal},
            {'emoji': '🍞', 'title': 'Order #1040 — Marat S.', 'sub': 'Bread Bundle × 3 • ₸1,800', 'status': 'Done', 'color': AppTheme.bTextSec},
          ];
          _activeDeals = [
            {'emoji': '🍕', 'title': 'Pizza Combo Box', 'sub': '5 remaining • 70% OFF • ends 9 PM', 'status': 'Live', 'color': AppTheme.bAccentTeal},
            {'emoji': '🥗', 'title': 'Caesar Salad Pack', 'sub': '2 remaining • 55% OFF • ends 8 PM', 'status': 'Ending', 'color': AppTheme.cOrange},
          ];
          _dashboardKpis = [];
          _isLoading = false;
        });
      }
    }
  }

  // 🔴 INTERACTIVE: Updates order status via Bottom Sheet
  void _showOrderActionSheet(int index) {
    final order = _liveOrders[index];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Update ${order['title']}', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSheetAction('Mark as Ready', AppTheme.bAccentTeal, Icons.check_circle_outline, () {
                  setState(() {
                    _liveOrders[index]['status'] = 'Ready';
                    _liveOrders[index]['color'] = AppTheme.bAccentTeal;
                  });
                  Navigator.pop(context);
                }),
                _buildSheetAction('Mark as Done', AppTheme.bTextSec, Icons.done_all, () {
                  setState(() {
                    _liveOrders[index]['status'] = 'Done';
                    _liveOrders[index]['color'] = AppTheme.bTextSec;
                  });
                  Navigator.pop(context);
                }),
                _buildSheetAction('Cancel Order', Colors.redAccent, Icons.cancel_outlined, () {
                  setState(() => _liveOrders.removeAt(index));
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔴 INTERACTIVE: Manages deals via Bottom Sheet
  void _showDealActionSheet(int index) {
    final deal = _activeDeals[index];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Manage ${deal['title']}', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildSheetAction('Edit Details', AppTheme.bAccentPurple, Icons.edit_outlined, () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit screen coming soon!')));
                }),
                _buildSheetAction(deal['status'] == 'Paused' ? 'Resume Deal' : 'Pause Deal', AppTheme.cOrange, Icons.pause_circle_outline, () {
                  setState(() {
                    bool isPaused = deal['status'] == 'Paused';
                    _activeDeals[index]['status'] = isPaused ? 'Live' : 'Paused';
                    _activeDeals[index]['color'] = isPaused ? AppTheme.bAccentTeal : AppTheme.cOrange;
                  });
                  Navigator.pop(context);
                }),
                _buildSheetAction('Delete Deal', Colors.redAccent, Icons.delete_outline, () {
                  setState(() => _activeDeals.removeAt(index));
                  Navigator.pop(context);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetAction(String title, Color color, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(backgroundColor: AppTheme.bBg, body: Center(child: CircularProgressIndicator(color: AppTheme.bAccentPurple)));
    }

    final currentKpis = _dashboardKpis.isNotEmpty ? _dashboardKpis : _kpiData[_activeFilter]!;

    return Scaffold(
      backgroundColor: AppTheme.bBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- TOP BAR ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: AppTheme.bSurface,
                border: Border(bottom: BorderSide(color: AppTheme.bBorder)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Napoli Pizza 🍕', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                      const SizedBox(height: 2),
                      const Text('Restaurant Panel', style: TextStyle(fontSize: 12, color: AppTheme.bTextSec)),
                    ],
                  ),
                  Row(
                    children: [
                      _buildIconBtn(Icons.notifications_none, badge: '2', onTap: () {
                        Navigator.pushNamed(context, '/biz-notifications');
                      }),
                      const SizedBox(width: 8),
                      _buildIconBtn(Icons.person_outline, onTap: () {}),
                    ],
                  )
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- FILTERS ---
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        scrollDirection: Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final filter = _filters[index];
                          final isActive = _activeFilter == filter;
                          return GestureDetector(
                            onTap: () => setState(() => _activeFilter = filter),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isActive ? AppTheme.bAccentPurple.withAlpha(50) : AppTheme.bSurface,
                                border: Border.all(color: isActive ? AppTheme.bAccentPurple : AppTheme.bBorder),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: isActive ? AppTheme.bAccentPurple : AppTheme.bTextSec,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // --- DYNAMIC KPI GRID ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: currentKpis.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final kpi = currentKpis[index];
                          return _buildKpiCard(kpi['emoji'], kpi['val'], kpi['lbl'], kpi['change'], kpi['color'], kpi['isUp']);
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- LIVE ORDERS ---
                    _buildSectionTitle('🔴 Live Orders', 'Manage all', () {
                      Navigator.pushNamed(context, '/biz-orders');
                    }),
                    if (_liveOrders.isEmpty)
                      const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No live orders at the moment.", style: TextStyle(color: AppTheme.bTextSec))))
                    else
                      ..._liveOrders.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var order = entry.value;
                        return _buildLiveOrder(order['emoji'], order['title'], order['sub'], order['status'], order['color'], () => _showOrderActionSheet(idx));
                      }),
                    
                    const SizedBox(height: 20),

                    // --- ACTIVE DEALS ---
                    _buildSectionTitle('🔥 Active Deals', '+ Add', () {
                       Navigator.pushNamed(context, '/biz-add-food');
                    }),
                    if (_activeDeals.isEmpty)
                      const Padding(padding: EdgeInsets.all(20), child: Center(child: Text("No active deals. Create one to attract customers!", style: TextStyle(color: AppTheme.bTextSec))))
                    else
                      ..._activeDeals.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var deal = entry.value;
                        return _buildActiveDeal(deal['emoji'], deal['title'], deal['sub'], deal['status'], deal['color'], () => _showDealActionSheet(idx));
                      }),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                             Navigator.pushNamed(context, '/biz-add-food');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.bAccentPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.add, color: Colors.white, size: 18),
                          label: const Text('Add New Deal', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, {String? badge, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppTheme.bCard,
              border: Border.all(color: AppTheme.bBorder),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: AppTheme.bTextSec, size: 18),
          ),
          if (badge != null)
            Positioned(
              top: -4, right: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppTheme.bAccentPurple, shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildKpiCard(String emoji, String val, String lbl, String change, Color accentColor, bool isUp) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey<String>(val + lbl),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bCard,
          border: Border.all(color: AppTheme.bBorder),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const Spacer(),
            Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.bTextMain, height: 1)),
            const SizedBox(height: 4),
            Text(lbl, style: const TextStyle(fontSize: 11, color: AppTheme.bTextSec)),
            const SizedBox(height: 6),
            Text(change, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isUp ? AppTheme.bAccentTeal : const Color(0xFFFF6B6B))),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String actionLbl, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
          GestureDetector(
            onTap: onAction,
            child: Text(actionLbl, style: const TextStyle(fontSize: 12, color: AppTheme.bAccentPurple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveOrder(String emoji, String title, String sub, String status, Color? statusColor, VoidCallback onTap) {
    final resolvedColor = statusColor ?? AppTheme.bAccentPurple;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bCard,
          border: Border.all(color: AppTheme.bBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppTheme.bAccentPurple.withAlpha(40), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.bTextSec)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'Done' ? Colors.white.withAlpha(20) : resolvedColor.withAlpha(50),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(status, style: TextStyle(color: status == 'Done' ? AppTheme.bTextSec : resolvedColor, fontSize: 10, fontWeight: FontWeight.w700)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeal(String emoji, String title, String sub, String status, Color? statusColor, VoidCallback onTap) {
    final resolvedColor = statusColor ?? AppTheme.cOrange;
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bCard,
          border: Border.all(color: AppTheme.bBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppTheme.cOrange.withAlpha(40), borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 11, color: AppTheme.bTextSec)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: resolvedColor.withAlpha(50),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(status, style: TextStyle(color: resolvedColor, fontSize: 10, fontWeight: FontWeight.w700)),
            )
          ],
        ),
      ),
    );
  }
}