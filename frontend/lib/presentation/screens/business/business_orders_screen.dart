import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BusinessOrdersScreen extends StatefulWidget {
  const BusinessOrdersScreen({super.key});

  @override
  State<BusinessOrdersScreen> createState() => _BusinessOrdersScreenState();
}

class _BusinessOrdersScreenState extends State<BusinessOrdersScreen> {
  String _activeFilter = 'All';
  final List<String> _filters = ['All', 'New', 'Ready', 'Done'];

  // Interactive local state
  final List<Map<String, dynamic>> _orders = [
    {'id': '#1042', 'customer': 'Aizat B.', 'items': 'Pizza Combo × 2', 'price': '₸2,100', 'time': '19:42', 'status': 'New', 'emoji': '🍕', 'color': AppTheme.bAccentPurple},
    {'id': '#1041', 'customer': 'Dana K.', 'items': 'Caesar Salad × 1', 'price': '₸900', 'time': '19:30', 'status': 'Ready', 'emoji': '🥗', 'color': AppTheme.bAccentTeal},
    {'id': '#1040', 'customer': 'Marat S.', 'items': 'Bread Bundle × 3', 'price': '₸1,800', 'time': '18:55', 'status': 'Done', 'emoji': '🍞', 'color': AppTheme.bTextSec},
    {'id': '#1039', 'customer': 'Eldar T.', 'items': 'Sushi Set × 1', 'price': '₸2,600', 'time': '18:15', 'status': 'Done', 'emoji': '🍣', 'color': AppTheme.bTextSec},
    {'id': '#1038', 'customer': 'Aruzhan M.', 'items': 'Pizza Combo × 1', 'price': '₸1,050', 'time': '18:02', 'status': 'New', 'emoji': '🍕', 'color': AppTheme.bAccentPurple},
  ];

  void _showOrderOptions(int originalIndex) {
    final order = _orders[originalIndex];

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
                Text('Order ${order['id']} - ${order['customer']}', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (order['status'] == 'New') 
                  _buildSheetAction('Mark as Ready', AppTheme.bAccentTeal, Icons.check_circle_outline, () {
                    setState(() {
                      _orders[originalIndex]['status'] = 'Ready';
                      _orders[originalIndex]['color'] = AppTheme.bAccentTeal;
                    });
                    Navigator.pop(context);
                  }),
                if (order['status'] == 'Ready' || order['status'] == 'New')
                  _buildSheetAction('Mark as Done', AppTheme.bTextSec, Icons.done_all, () {
                    setState(() {
                      _orders[originalIndex]['status'] = 'Done';
                      _orders[originalIndex]['color'] = AppTheme.bTextSec;
                    });
                    Navigator.pop(context);
                  }),
                _buildSheetAction('Cancel Order', Colors.redAccent, Icons.cancel_outlined, () {
                  setState(() => _orders.removeAt(originalIndex));
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
    // Filter the list dynamically
    final filteredOrders = _activeFilter == 'All' 
        ? _orders 
        : _orders.where((o) => o['status'] == _activeFilter).toList();

    return Scaffold(
      backgroundColor: AppTheme.bBg,
      appBar: AppBar(
        backgroundColor: AppTheme.bSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.bTextMain),
        title: Text('All Orders', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: Column(
        children: [
          // Filter Row
          Container(
            height: 60,
            color: AppTheme.bBg,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Orders List
          Expanded(
            child: filteredOrders.isEmpty
                ? Center(child: Text('No $_activeFilter orders.', style: const TextStyle(color: AppTheme.bTextSec)))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      // Find original index to update the master list
                      final originalIndex = _orders.indexOf(order);

                      return InkWell(
                        onTap: () => _showOrderOptions(originalIndex),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bCard,
                            border: Border.all(color: AppTheme.bBorder),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48, height: 48,
                                decoration: BoxDecoration(
                                  color: order['color'].withAlpha(40),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(order['emoji'], style: const TextStyle(fontSize: 24)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('${order['id']} — ${order['customer']}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                                        Text(order['time'], style: const TextStyle(fontSize: 12, color: AppTheme.bTextSec)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${order['items']} • ${order['price']}', style: const TextStyle(fontSize: 12, color: AppTheme.bTextSec)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: order['status'] == 'Done' ? Colors.white.withAlpha(20) : order['color'].withAlpha(50),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(order['status'], style: TextStyle(color: order['status'] == 'Done' ? AppTheme.bTextSec : order['color'], fontSize: 11, fontWeight: FontWeight.w700)),
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
    );
  }
}