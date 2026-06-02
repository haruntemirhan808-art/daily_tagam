import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class BusinessAddDealScreen extends StatefulWidget {
  const BusinessAddDealScreen({super.key});

  @override
  State<BusinessAddDealScreen> createState() => _BusinessAddDealScreenState();
}

class _BusinessAddDealScreenState extends State<BusinessAddDealScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _saveDeal() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deal published successfully! 🎉'), backgroundColor: AppTheme.bAccentTeal),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bBg,
      appBar: AppBar(
        backgroundColor: AppTheme.bSurface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.bTextMain),
        title: Text('Create New Deal', style: GoogleFonts.spaceGrotesk(color: AppTheme.bTextMain, fontWeight: FontWeight.w700, fontSize: 18)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildInputLabel('Emoji / Icon'),
            _buildTextField(hint: 'e.g. 🍕', maxLength: 2),
            const SizedBox(height: 16),
            _buildInputLabel('Deal Title'),
            _buildTextField(hint: 'e.g. Pizza Combo Box'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('Original Price (₸)'), _buildTextField(hint: '2000', isNumber: true)])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('Discount Price (₸)'), _buildTextField(hint: '1000', isNumber: true)])),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('Quantity Available'), _buildTextField(hint: '5', isNumber: true)])),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildInputLabel('Pickup Time'), _buildTextField(hint: '20:00 - 22:00')])),
              ],
            ),
            const SizedBox(height: 16),
            _buildInputLabel('Description'),
            _buildTextField(hint: 'Describe what is inside...', maxLines: 3),
            const SizedBox(height: 32),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveDeal,
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.bAccentPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text('Publish Deal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(color: AppTheme.bTextSec, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1, int? maxLength, bool isNumber = false}) {
    return TextFormField(
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: AppTheme.bTextMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.bTextSec.withAlpha(100)),
        filled: true,
        fillColor: AppTheme.bSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.bBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.bBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.bAccentPurple)),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }
}