import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/network/api_client.dart';

class CustomerEcoImpactScreen extends StatefulWidget {
  const CustomerEcoImpactScreen({super.key});

  @override
  State<CustomerEcoImpactScreen> createState() => _CustomerEcoImpactScreenState();
}

class _CustomerEcoImpactScreenState extends State<CustomerEcoImpactScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;

  double _wasteSaved = 0.0;
  int _ordersCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchEcoData();
  }

  Future<void> _fetchEcoData() async {
    try {
      final response = await _apiClient.dio.get('/users/me/profile');
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _wasteSaved = double.tryParse(response.data['waste_saved_kg']?.toString() ?? '0') ?? 0.0;
          _ordersCount = response.data['order_count'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _wasteSaved = 0.0;
          _ordersCount = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: AppTheme.cBg, body: Center(child: CircularProgressIndicator()));

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
                  Text('My Eco Impact 🌱', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [AppTheme.cGreen, Color(0xFF16A34A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text('🌍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text('$_wasteSaved', style: GoogleFonts.sora(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, height: 1)),
                          Text('kg of food waste saved', style: TextStyle(fontSize: 16, color: Colors.white.withAlpha(230))),
                          const SizedBox(height: 6),
                          Text('equivalent to saving ${(_wasteSaved / 0.4).round()} meals from landfill', style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(200))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildEcoStat('🛍️', '$_ordersCount', '', 'Orders placed'),
                        _buildEcoStat('💨', '7.2', 'kg', 'CO₂ reduced'),
                        _buildEcoStat('💧', '420', 'L', 'Water saved'),
                        _buildEcoStat('🌳', '0.8', '', 'Trees equivalent'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Impact Level', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: const LinearProgressIndicator(
                              value: 0.56,
                              minHeight: 12,
                              backgroundColor: AppTheme.cBg,
                              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.cGreen),
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('🌱 Seedling', style: TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
                              Text('🌿 Sprout (Current)', style: TextStyle(fontSize: 11, color: AppTheme.cTextSec, fontWeight: FontWeight.bold)),
                              Text('🌳 Tree', style: TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoStat(String icon, String val, String unit, String lbl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(val, style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cGreen)),
              if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontSize: 12, color: AppTheme.cGreen, fontWeight: FontWeight.bold)),
            ],
          ),
          Text(lbl, style: const TextStyle(fontSize: 11, color: AppTheme.cTextSec)),
        ],
      ),
    );
  }
}