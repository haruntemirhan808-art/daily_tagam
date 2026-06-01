import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Customer Colors
  static const Color orange = Color(0xFFFF8A00);
  static const Color orangeLight = Color(0xFFFFB347);
  static const Color orangePale = Color(0xFFFFF3E0);
  static const Color green = Color(0xFF22C55E);
  static const Color greenPale = Color(0xFFF0FDF4);
  
  static const Color bg = Color(0xFFF8F9FA);
  static const Color textMain = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  // Business Colors
  static const Color bizBg = Color(0xFF0F1117);
  static const Color bizSurface = Color(0xFF1A1D27);
  static const Color bizCard = Color(0xFF20243A);
  static const Color bizAccent = Color(0xFF6C63FF);
  static const Color bizAccentTeal = Color(0xFF00D4AA);
  static const Color bizText = Color(0xFFF0F2F8);

  static ThemeData get customerTheme {
    return ThemeData(
      scaffoldBackgroundColor: bg,
      primaryColor: orange,
      textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: orange,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}