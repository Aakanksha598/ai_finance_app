import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color primaryColor = Color(0xFF6750A4);
  static const Color secondaryColor = Color(0xFF625B71);
  static const Color tertiaryColor = Color(0xFF7D5260);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);

  static const Color surfaceColor = Color(0xFFFFFBFE);
  static const Color backgroundColor = Color(0xFFFFFBFE);
  static const Color onSurfaceColor = Color(0xFF1C1B1F);
  static const Color onBackgroundColor = Color(0xFF1C1B1F);

  // Light theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: errorColor,
      surface: surfaceColor,
      onSurface: onSurfaceColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: onSurfaceColor,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: surfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      filled: true,
      fillColor: surfaceColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryColor,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // Dark theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      error: errorColor,
      surface: Color(0xFF1C1B1F),
      onSurface: Color(0xFFE6E1E5),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1B1F),
      foregroundColor: Color(0xFFE6E1E5),
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      color: Color(0xFF1C1B1F),
      // elevation: 2, // <-- Remove this line
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      filled: true,
      fillColor: Color(0xFF1C1B1F),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1C1B1F),
      selectedItemColor: primaryColor,
      unselectedItemColor: secondaryColor,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
