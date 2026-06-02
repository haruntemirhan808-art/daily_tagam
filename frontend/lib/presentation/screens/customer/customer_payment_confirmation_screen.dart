import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class CustomerPaymentConfirmationScreen extends StatelessWidget {
  const CustomerPaymentConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.popUntil(context, ModalRoute.withName('/cart')),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.cBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cBorder),
                  ),
                  child: const Icon(Icons.chevron_left, color: AppTheme.cTextMain, size: 20),
                ),
              ),
              const SizedBox(height: 28),
              Center(
                child: Container(
                  width: 94,
                  height: 94,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.cGreen.withAlpha(30),
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle, size: 54, color: AppTheme.cGreen),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Payment Confirmed!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.cTextMain),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Your order is now being processed. You will receive an email receipt shortly.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 1.5, color: AppTheme.cTextSec),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment details', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                    const SizedBox(height: 16),
                    _buildDetailRow('Order total', '₸2041'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Payment method', 'Visa • •••• 3456'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Order ID', 'DT-987654321'),
                    const SizedBox(height: 12),
                    _buildDetailRow('Status', 'Completed', isStatus: true),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/feed')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.cOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('Back to Home', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: AppTheme.cTextSec)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isStatus ? AppTheme.cGreen : AppTheme.cTextMain,
            fontWeight: isStatus ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
