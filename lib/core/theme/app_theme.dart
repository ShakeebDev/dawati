import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// نظام التصميم وألوان التطبيق
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════
  // الألوان الأساسية - اللون الذهبي والكحلي
  // ═══════════════════════════════════════════
  static const Color goldPrimary = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8D07A);
  static const Color goldDark = Color(0xFFA8862A);
  static const Color navyPrimary = Color(0xFF0D1B3E);
  static const Color navyLight = Color(0xFF1A2D5A);
  static const Color navyDark = Color(0xFF060D1F);

  // ═══════════════════════════════════════════
  // الثيم البديل - البيج والوردي
  // ═══════════════════════════════════════════
  static const Color beigeLight = Color(0xFFF5EDD8);
  static const Color rosePrimary = Color(0xFFD4879C);
  static const Color roseLight = Color(0xFFF0B8C8);

  // ═══════════════════════════════════════════
  // الألوان المساعدة
  // ═══════════════════════════════════════════
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  /// اسم خط القاهرة - ثابت لاستخدامه في const TextStyle
  static const String fontFamily = 'Cairo';

  static const Color surfaceDark = Color(0xFF060912); // Deepest Navy
  static const Color cardDark = Color(0xFF0F172A); // Rich Navy
  static const Color dividerDark = Color(0xFF1E293B);

  static const Color surfaceLight = Color(0xFFFAF7F2);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color dividerLight = Color(0xFFE5E0D8);

  // ═══════════════════════════════════════════
  // تدرجات الألوان
  // ═══════════════════════════════════════════
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDark, goldPrimary, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient navyGradient = LinearGradient(
    colors: [navyDark, navyPrimary, navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [navyDark, navyPrimary, navyLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldGlassGradient = LinearGradient(
    colors: [
      Color(0x33D4AF37),
      Color(0x1AD4AF37),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFF8E8EE), roseLight, beigeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ═══════════════════════════════════════════
  // الظلال والحواف
  // ═══════════════════════════════════════════
  static List<BoxShadow> shadowLow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowMedium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowHigh = [
    BoxShadow(
      color: goldPrimary.withOpacity(0.15),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusExtraLarge = 32.0;

  static const double spacingEmpty = 0.0;
  static const double spacingXS = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // ═══════════════════════════════════════════
  // الخطوط - خط القاهرة العربي
  // ═══════════════════════════════════════════
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: textColor,
        height: 1.4,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.4,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.4,
      ),
      headlineLarge: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: textColor,
        height: 1.4,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.6,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.6,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textColor,
        height: 1.6,
      ),
      labelLarge: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.5,
      ),
      labelMedium: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      labelSmall: GoogleFonts.cairo(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: textColor,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // الثيم الداكن
  // ═══════════════════════════════════════════
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: GoogleFonts.cairo().fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: goldPrimary,
        primaryContainer: goldDark,
        secondary: goldLight,
        secondaryContainer: Color(0xFF3D2B00),
        surface: surfaceDark,
        error: error,
        onPrimary: navyDark,
        onSecondary: navyDark,
        onSurface: Colors.white,
        outline: dividerDark,
        surfaceContainerHighest: cardDark,
      ),
      scaffoldBackgroundColor: surfaceDark,
      textTheme: _buildTextTheme(Colors.white),
      cardTheme: CardThemeData(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: goldPrimary,
        ),
        iconTheme: const IconThemeData(color: goldPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldPrimary,
          foregroundColor: navyDark,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: goldPrimary,
          side: const BorderSide(color: goldPrimary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: goldPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.cairo(color: Colors.white60),
        hintStyle: GoogleFonts.cairo(color: Colors.white38),
        prefixIconColor: goldPrimary,
        suffixIconColor: Colors.white54,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldPrimary,
        foregroundColor: navyDark,
        elevation: 4,
        shape: CircleBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: goldPrimary,
        unselectedItemColor: Colors.white38,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cardDark,
        selectedColor: goldPrimary.withOpacity(0.2),
        labelStyle: GoogleFonts.cairo(fontSize: 12),
        side: const BorderSide(color: dividerDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerDark,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: cardDark,
        contentTextStyle: GoogleFonts.cairo(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // الثيم الفاتح
  // ═══════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: GoogleFonts.cairo().fontFamily,
      colorScheme: ColorScheme.light(
        primary: goldDark,
        primaryContainer: goldLight.withOpacity(0.3),
        secondary: navyPrimary,
        secondaryContainer: navyLight.withOpacity(0.1),
        surface: surfaceLight,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: navyDark,
        outline: dividerLight,
        surfaceContainerHighest: cardLight,
      ),
      scaffoldBackgroundColor: surfaceLight,
      textTheme: _buildTextTheme(navyDark),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        shadowColor: navyPrimary.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: navyPrimary,
        ),
        iconTheme: const IconThemeData(color: navyPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldDark,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: navyPrimary,
          side: const BorderSide(color: navyPrimary, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle:
              GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: dividerLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: goldDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: error),
        ),
        labelStyle: GoogleFonts.cairo(color: navyPrimary.withOpacity(0.6)),
        hintStyle: GoogleFonts.cairo(color: navyPrimary.withOpacity(0.4)),
        prefixIconColor: goldDark,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldDark,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerLight,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: navyPrimary,
        contentTextStyle: GoogleFonts.cairo(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
