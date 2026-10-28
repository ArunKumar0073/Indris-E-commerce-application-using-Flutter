import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Colors picked to match indrishome.netlify.app
class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color cream = Color(0xFFF6F4F1);
  static const Color black = Color(0xFF17181A);
  static const Color textGrey = Color(0xFF6C6C6C);
  static const Color border = Color(0xFFE3E1DD);
  static const Color green = Color(0xFF5B7A5C); // sofa green accent
  static const Color greenDark = Color(0xFF445E45);
}

/// Logo / heading font -> bold italic serif, same feel as "Indris" wordmark
TextStyle logoStyle({double size = 26}) => GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      color: AppColors.black,
      letterSpacing: 0.2,
    );

TextStyle headingStyle({double size = 32, Color? color}) =>
    GoogleFonts.playfairDisplay(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color ?? AppColors.black,
      height: 1.2,
    );

/// Nav / body font -> clean sans-serif with letter spacing, like the site nav
TextStyle navStyle({double size = 13, Color? color, FontWeight? weight}) =>
    GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w500,
      color: color ?? AppColors.black,
      letterSpacing: 0.6,
    );

TextStyle bodyStyle({double size = 14, Color? color, FontWeight? weight}) =>
    GoogleFonts.poppins(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.textGrey,
      height: 1.6,
    );

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.green, width: 1.4),
      ),
      hintStyle: bodyStyle(size: 13.5, color: AppColors.textGrey),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        elevation: 0,
        textStyle:
            navStyle(size: 14, color: Colors.white, weight: FontWeight.w600),
      ),
    ),
  );
}
