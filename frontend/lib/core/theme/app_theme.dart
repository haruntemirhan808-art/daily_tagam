import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- CUSTOMER PALETTE (Light Mode) ---
  static const Color cOrange = Color(0xFFFF8A00);
  static const Color cOrangeLight = Color(0xFFFFB347);
  static const Color cOrangePale = Color(0xFFFFF3E0);
  
  static const Color cGreen = Color(0xFF22C55E);
  static const Color cGreenLight = Color(0xFF86EFAC);
  static const Color cGreenPale = Color(0xFFF0FDF4);
  
  static const Color cBg = Color(0xFFF8F9FA);
  static const Color cCard = Color(0xFFFFFFFF);
  static const Color cTextMain = Color(0xFF1A1A2E);
  static const Color cTextSec = Color(0xFF64748B);
  static const Color cBorder = Color(0xFFE2E8F0);

  // --- BUSINESS PALETTE (Dark Mode) ---
  static const Color bBg = Color(0xFF0F1117);
  static const Color bSurface = Color(0xFF1A1D27);
  static const Color bCard = Color(0xFF20243A);
  static const Color bBorder = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color bTextMain = Color(0xFFF0F2F8);
  static const Color bTextSec = Color(0xFF8B92A8);
  static const Color bAccentPurple = Color(0xFF6C63FF);
  static const Color bAccentTeal = Color(0xFF00D4AA);

  // --- CUSTOMER THEME ---
  static ThemeData get customerTheme {
    return ThemeData(
      scaffoldBackgroundColor: cBg,
      primaryColor: cOrange,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.sora(color: cTextMain, fontWeight: FontWeight.w800),
        titleLarge: GoogleFonts.sora(color: cTextMain, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: cTextMain),
        bodyMedium: TextStyle(color: cTextSec),
      ),
      colorScheme: const ColorScheme.light(
        primary: cOrange,
        secondary: cGreen,
        surface: cCard,
        background: cBg,
      ),
    );
  }

  // --- BUSINESS THEME ---
  static ThemeData get businessTheme {
    return ThemeData(
      scaffoldBackgroundColor: bBg,
      primaryColor: bAccentPurple,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(color: bTextMain, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.spaceGrotesk(color: bTextMain, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: bTextMain),
        bodyMedium: TextStyle(color: bTextSec),
      ),
      colorScheme: const ColorScheme.dark(
        primary: bAccentPurple,
        secondary: bAccentTeal,
        surface: bSurface,
        background: bBg,
      ),
    );
  }
}