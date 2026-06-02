import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BusinessCouponsScreen extends StatefulWidget {
  const BusinessCouponsScreen({super.key});

  @override
  State<BusinessCouponsScreen> createState() => _BusinessCouponsScreenState();
}

class _BusinessCouponsScreenState extends State<BusinessCouponsScreen> {
  // Interactive Local State
  final List<Map<String, dynamic>> _coupons = [
    {'code': 'SAVE10', 'title': '10% Off Entire Order', 'stats': 'Used 45 times • Active', 'color': AppTheme.bAccentTeal},
    {'code': 'FREEDRINK', 'title': 'Free Drink with Combo', 'stats': 'Used 12 times • Active', 'color': AppTheme.bAccentTeal},
    {'code': 'WELCOME20', 'title': '20% Off First Order', 'stats': 'Used 108 times • Paused', 'color': AppTheme.cOrange},
    {'code': 'NEWYEAR', 'title': '15% Off', 'stats': 'Used 300 times • Expired', 'color': AppTheme.bTextSec},
  ];

  // 🔴 INTERACTIVE: Opens a Bottom Sheet to Add a New Coupon
  void _showAddCouponModal() {
    final codeController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Moves up when the keyboard opens
      backgroundColor: AppTheme.bSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, 
            left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create New Coupon', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                style: const TextStyle(color: AppTheme.bTextMain),
                decoration: InputDecoration(
                  hintText: 'Code (e.g. SPRING25)',
                  hintStyle: TextStyle(color: AppTheme.bTextSec.withAlpha(100)),
                  filled: true, fillColor: AppTheme.bBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                style: const TextStyle(color: AppTheme.bTextMain),
                decoration: InputDecoration(
                  hintText: 'Description (e.g. 25% Off Salads)',
                  hintStyle: TextStyle(color: AppTheme.bTextSec.withAlpha(100)),
                  filled: true, fillColor: AppTheme.bBg,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (codeController.text.isNotEmpty && descController.text.isNotEmpty) {
                      setState(() {
                        _coupons.insert(0, {
                          'code': codeController.text.toUpperCase(),
                          'title': descController.text,
                          'stats': 'Used 0 times • Active',
                          'color': AppTheme.bAccentTeal
                        });
                      });
                      Navigator.pop(context); // Close the modal
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bAccentPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Add Coupon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }

  // 🔴 INTERACTIVE: Manage or delete existing coupons
  void _showCouponOptions(int index) {
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
                Text('Manage ${_coupons[index]['code']}', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  title: const Text('Delete Coupon', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                  onTap: () {
                    setState(() => _coupons.removeAt(index));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Coupons 🎟️', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppTheme.bTextMain)),
                  // 🔴 The Add Button now triggers the Modal
                  GestureDetector(
                    onTap: _showAddCouponModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.bAccentPurple, borderRadius: BorderRadius.circular(8)),
                      child: const Text('+ Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: _coupons.isEmpty 
                  ? const Center(child: Text("No coupons active.", style: TextStyle(color: AppTheme.bTextSec)))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: _coupons.length,
                      itemBuilder: (context, index) {
                        final coupon = _coupons[index];
                        return _buildCoupon(coupon['code'], coupon['title'], coupon['stats'], coupon['color'], () => _showCouponOptions(index));
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoupon(String code, String title, String stats, Color statusColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.bCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.bBorder)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: statusColor.withAlpha(20), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.local_offer, color: AppTheme.bTextMain),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(code, style: GoogleFonts.spaceGrotesk(color: statusColor, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(title, style: const TextStyle(color: AppTheme.bTextMain, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(stats, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: AppTheme.bTextSec),
          ],
        ),
      ),
    );
  }
}