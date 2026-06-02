import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_theme.dart';

class BusinessAnalyticsScreen extends StatefulWidget {
  const BusinessAnalyticsScreen({super.key});

  @override
  State<BusinessAnalyticsScreen> createState() => _BusinessAnalyticsScreenState();
}

class _BusinessAnalyticsScreenState extends State<BusinessAnalyticsScreen> {
  int _totalRevenue = 0;
  int _totalOrders = 0;
  int _dailyMealsSold = 0;
  List<int> _weeklySales = List<int>.filled(7, 0);
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalyticsData();
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      final dio = Dio();
      final response = await dio.get('http://127.0.0.1:8000/business/me/dashboard',
        options: Options(headers: {'Authorization': 'Bearer YOUR_TOKEN_HERE'}),
      );
      
      if (mounted) {
        setState(() {
          _totalRevenue = response.data['total_revenue'] ?? 0;
          _totalOrders = response.data['total_orders'] ?? 0;
          _dailyMealsSold = response.data['daily_meals_sold'] ?? 0;
          _weeklySales = List<int>.from(response.data['weekly_sales'] ?? List<int>.filled(7, 0));
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<double> get _weeklyPerformanceRatios {
    if (_weeklySales.isEmpty) return List<double>.filled(7, 0.0);
    final maxSales = _weeklySales.reduce((a, b) => a > b ? a : b);
    if (maxSales == 0) return List<double>.filled(7, 0.0);
    return _weeklySales.map((sales) => (sales / maxSales).clamp(0.05, 1.0)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Text('Analytics 📊', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.bAccentPurple, Color(0xFF9C67F5)]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total Revenue (This Month)', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13)),
                          const SizedBox(height: 8),
                          _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text('₸${_totalRevenue.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}', 
                                  style: GoogleFonts.spaceGrotesk(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _buildStat('Orders', _totalOrders.toString()),
                              _buildStat('Meals Sold', _dailyMealsSold.toString()),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Weekly Performance', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                    const SizedBox(height: 16),
                    Container(
                      height: 120,
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                      decoration: BoxDecoration(color: AppTheme.bCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppTheme.bBorder)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _weeklyPerformanceRatios
                            .asMap()
                            .entries
                            .map((entry) => _buildBar(
                                  ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][entry.key],
                                  entry.value,
                                  isHighlight: entry.key == 4,
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Top Selling Items', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                    const SizedBox(height: 12),
                    _isLoading
                        ? const Padding(
                            padding: EdgeInsets.only(top: 20),
                            child: CircularProgressIndicator(),
                          )
                        : _totalOrders == 0
                            ? Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(color: AppTheme.bCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bBorder)),
                                child: const Text('No sales yet. Your weekly chart will appear once you start selling.', style: TextStyle(color: AppTheme.bTextSec, fontSize: 14)),
                              )
                            : Column(
                                children: [
                                  _buildTopItem('🍕', 'Pizza Combo Box', '0 sold', '₸0'),
                                  _buildTopItem('🥗', 'Caesar Salad Pack', '0 sold', '₸0'),
                                  _buildTopItem('🥐', 'Morning Bakery Set', '0 sold', '₸0'),
                                ],
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

  Widget _buildStat(String label, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11)),
          Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBar(String day, double heightRatio, {bool isHighlight = false}) {
    final barHeight = (56 * heightRatio).clamp(10.0, 56.0);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 18,
          height: barHeight,
          decoration: BoxDecoration(
            color: isHighlight ? AppTheme.bAccentTeal : AppTheme.bAccentPurple.withAlpha(100),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(day, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 11)),
      ],
    );
  }

  Widget _buildTopItem(String emoji, String title, String sold, String revenue) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppTheme.bCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bBorder)),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppTheme.bTextMain, fontWeight: FontWeight.bold, fontSize: 14)),
                Text(sold, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 12)),
              ],
            ),
          ),
          Text(revenue, style: const TextStyle(color: AppTheme.bAccentTeal, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}