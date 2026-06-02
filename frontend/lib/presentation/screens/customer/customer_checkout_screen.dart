import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class CustomerCheckoutScreen extends StatefulWidget {
  const CustomerCheckoutScreen({super.key});

  @override
  State<CustomerCheckoutScreen> createState() => _CustomerCheckoutScreenState();
}

class _CustomerCheckoutScreenState extends State<CustomerCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  bool _saveCard = true;

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _payNow() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pushReplacementNamed(context, '/checkout-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cBg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.cTextMain),
        title: Text('Payment', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Enter your bank card details to complete checkout.', style: TextStyle(fontSize: 14, color: AppTheme.cTextSec, height: 1.4)),
              const SizedBox(height: 20),
              _buildCardPreview(),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Cardholder Name', _nameController, hint: 'Jane Doe', keyboardType: TextInputType.name),
                    const SizedBox(height: 16),
                    _buildField('Card Number', _cardNumberController, hint: '1234 5678 9012 3456', keyboardType: TextInputType.number, maxLength: 19),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildField('Expiry', _expiryController, hint: 'MM/YY', keyboardType: TextInputType.datetime, maxLength: 5)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildField('CVV', _cvvController, hint: '123', keyboardType: TextInputType.number, maxLength: 3)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Switch(
                          value: _saveCard,
                          onChanged: (value) => setState(() => _saveCard = value),
                          thumbColor: WidgetStateProperty.resolveWith((states) => AppTheme.cOrange),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Save this card for future payments', style: TextStyle(fontSize: 13, color: AppTheme.cTextMain))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _payNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: Text('Pay Now', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint, TextInputType? keyboardType, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.cTextSec, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.cBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppTheme.cBorder)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(colors: [Color(0xFF1FBD71), Color(0xFF0B8C5A)]),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Bank Card', style: TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 18),
          const Text('1234 5678 9012 3456', style: TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('CARDHOLDER', style: TextStyle(color: Colors.white70, fontSize: 10)),
              Text('VALID THRU', style: TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('JANE DOE', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              Text('12/26', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
