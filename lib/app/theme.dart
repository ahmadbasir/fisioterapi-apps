import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand HSL/HEX Colors
  static const Color background = Color(0xFF0A0E1A); // Deep Obsidian Blue
  static const Color surface = Color(0xFF151B2C);    // Midnight Navy Blue
  static const Color cardBg = Color(0xFF1E263D);      // Slate Glass-blue
  
  static const Color primary = Color(0xFF3B82F6);     // Electric Blue
  static const Color secondary = Color(0xFF8B5CF6);   // Mystic Purple (Accent Glow)
  
  // Pain Severity Scale Colors (Medical VAS)
  static const Color painMild = Color(0xFF10B981);     // Vibrant Emerald Green (1-3)
  static const Color painModerate = Color(0xFFF59E0B); // Warm Amber Orange (4-6)
  static const Color painSevere = Color(0xFFEF4444);   // Crimson Red (7-10)
  
  static const Color textPrimary = Color(0xFFF3F4F6); // Cool White/Gray 100
  static const Color textSecondary = Color(0xFF9CA3AF); // Muted Cool Gray 400
  static const Color textMuted = Color(0xFF6B7280);    // Dark Muted Gray 500

  // Gradients for high-end look
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surface, cardBg],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient painGradient = LinearGradient(
    colors: [painMild, painModerate, painSevere],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // High-fidelity Shadows
  static List<BoxShadow> get premiumShadow => [
    BoxShadow(
      color: primary.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.4),
      blurRadius: 15,
      offset: const Offset(0, 5),
    ),
  ];

  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 25,
      spreadRadius: 2,
    ),
  ];

  // Theme data definition
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        background: background,
        surface: surface,
        error: painSevere,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: textPrimary),
          displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
          titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
          bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
          bodyMedium: TextStyle(fontSize: 14, color: textSecondary),
          bodySmall: TextStyle(fontSize: 12, color: textMuted),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        inactiveTrackColor: cardBg,
        thumbColor: primary,
        overlayColor: primary.withOpacity(0.2),
        valueIndicatorColor: surface,
        valueIndicatorTextStyle: const TextStyle(color: textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: Colors.white.withOpacity(0.15), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: painSevere, width: 1.5),
        ),
      ),
    );
  }
}
