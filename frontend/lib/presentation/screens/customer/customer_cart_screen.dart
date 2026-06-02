import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({super.key});

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  // --- MOCK CART STATE ---
  // In a production app, this would be fetched from your database or global state.
  final List<Map<String, dynamic>> _cartItems = [
    {
      "id": "1",
      "title": "Pizza Combo Box",
      "rest": "Napoli Pizza",
      "emoji": "🍕",
      "base_price": 1050,
      "qty": 1,
    },
    {
      "id": "2",
      "title": "Bakery Morning Pack",
      "rest": "Golden Crust",
      "emoji": "🥐",
      "base_price": 720,
      "qty": 2,
    }
  ];

  bool _useBonusPoints = false;
  int _couponDiscount = 0;
  final TextEditingController _couponController = TextEditingController();

  // --- MATH CALCULATIONS ---
  int get _subtotal {
    int total = 0;
    for (var item in _cartItems) {
      total += (item['base_price'] as int) * (item['qty'] as int);
    }
    return total;
  }

  int get _bonusDiscountAmount => _useBonusPoints ? 200 : 0;

  int get _total => (_subtotal - _couponDiscount - _bonusDiscountAmount).clamp(0, 999999);

  void _changeQty(int index, int delta) {
    setState(() {
      int newQty = _cartItems[index]['qty'] + delta;
      if (newQty < 1) return; // Prevent going below 1
      _cartItems[index]['qty'] = newQty;
      
      // Recalculate coupon if it's percentage-based (e.g., 10% off subtotal)
      if (_couponDiscount > 0) {
        _couponDiscount = (_subtotal * 0.10).round();
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _cartItems.removeAt(index);
      // Recalculate coupon if it's percentage-based
      if (_couponDiscount > 0) {
        _couponDiscount = (_subtotal * 0.10).round();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: const Text('Item removed from cart'), backgroundColor: Colors.red.shade400, duration: const Duration(seconds: 2)),
    );
  }

  void _applyCoupon() {
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    final code = _couponController.text.trim().toUpperCase();
    
    if (code == 'SAVE10' || code == 'BAKE20' || code == 'WELCOME15') {
      setState(() {
        _couponDiscount = (_subtotal * 0.10).round(); // 10% discount
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coupon applied! ✅', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppTheme.cGreen),
      );
    } else {
      setState(() {
        _couponDiscount = 0;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coupon code ❌'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBg,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.cBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.chevron_left, size: 18, color: AppTheme.cTextMain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'My Cart 🛒',
                    style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.cTextMain),
                  ),
                ],
              ),
            ),

            // --- CART ITEMS & SUMMARY ---
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                child: Column(
                  children: [
                    if (_cartItems.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text("Your cart is empty.", style: TextStyle(color: AppTheme.cTextSec)),
                      )
                    else
                      ..._cartItems.asMap().entries.map((entry) {
                        int index = entry.key;
                        var item = entry.value;
                        int itemTotal = (item['base_price'] as int) * (item['qty'] as int);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              // Image/Emoji Box
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [AppTheme.cOrangePale, AppTheme.cGreenPale], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                alignment: Alignment.center,
                                child: Text(item['emoji'], style: const TextStyle(fontSize: 32)),
                              ),
                              const SizedBox(width: 14),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['title'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                                    Text(item['rest'], style: const TextStyle(fontSize: 12, color: AppTheme.cTextSec)),
                                    const SizedBox(height: 8),
                                    // Qty Control & Remove
                                    Row(
                                      children: [
                                        _buildSmallQtyBtn('−', () => _changeQty(index, -1)),
                                        SizedBox(
                                          width: 28,
                                          child: Text('${item['qty']}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
                                        ),
                                        _buildSmallQtyBtn('+', () => _changeQty(index, 1)),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () => _removeItem(index),
                                          child: Container(
                                            width: 28, height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              border: Border.all(color: Colors.red.shade300, width: 1.5),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.close, color: Colors.red.shade600, size: 16),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // Price
                              Text(
                                '₸$itemTotal',
                                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cOrange),
                              ),
                            ],
                          ),
                        );
                      }),

                    const SizedBox(height: 16),

                    // --- BONUS POINTS ROW ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(color: AppTheme.cGreenPale, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: AppTheme.cGreen, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Use 200 bonus points', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.cTextMain)),
                                Text('Save extra ₸200', style: TextStyle(fontSize: 11, color: AppTheme.cTextSec.withAlpha(200))),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _useBonusPoints = !_useBonusPoints),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44, height: 24,
                              decoration: BoxDecoration(
                                color: _useBonusPoints ? AppTheme.cGreen : Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: AnimatedAlign(
                                duration: const Duration(milliseconds: 200),
                                alignment: _useBonusPoints ? Alignment.centerRight : Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    width: 20, height: 20,
                                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- COUPON ROW ---
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.cBorder),
                            ),
                            child: TextField(
                              controller: _couponController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Enter coupon code',
                                hintStyle: TextStyle(color: AppTheme.cTextSec.withAlpha(150), fontSize: 14),
                                prefixIcon: Icon(Icons.local_offer, color: AppTheme.cTextSec.withAlpha(150), size: 16),
                                prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _applyCoupon,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cGreen,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // --- SUMMARY CARD ---
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 24, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', '₸$_subtotal', isBold: false),
                          if (_couponDiscount > 0) ...[
                            const SizedBox(height: 12),
                            _buildSummaryRow('Coupon (${_couponController.text.toUpperCase()})', '−₸$_couponDiscount', isBold: false, valueColor: AppTheme.cGreen),
                          ],
                          if (_useBonusPoints) ...[
                            const SizedBox(height: 12),
                            _buildSummaryRow('Bonus points', '−₸$_bonusDiscountAmount', isBold: false, valueColor: AppTheme.cGreen),
                          ],
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: AppTheme.cBorder, height: 1),
                          ),
                          _buildSummaryRow('Total', '₸$_total', isBold: true, valueColor: AppTheme.cOrange),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- CHECKOUT BUTTON ---
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/checkout');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.cOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.lock, color: Colors.white, size: 16),
                        label: Text('Checkout — ₸$_total', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
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

  Widget _buildSmallQtyBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          color: AppTheme.cBg,
          border: Border.all(color: AppTheme.cBorder, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.cTextMain)),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val, {required bool isBold, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? AppTheme.cTextMain : AppTheme.cTextSec, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.normal)),
        Text(val, style: TextStyle(color: valueColor ?? AppTheme.cTextMain, fontSize: isBold ? 16 : 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w600)),
      ],
    );
  }
}