import 'package:flutter/material.dart';

class AppColors {
  static const background  = Color(0xFF0D0D0D);
  static const panel       = Color(0xFF1A1A1A);
  static const card        = Color(0xFF242424);
  static const cardLong    = Color(0xFF0D2B1A);
  static const cardShort   = Color(0xFF2B0D0D);
  static const orange      = Color(0xFFF7931A);
  static const textMain    = Color(0xFFFFFFFF);
  static const textMuted   = Color(0xFF888888);
  static const green       = Color(0xFF00C853);
  static const red         = Color(0xFFFF1744);
  static const yellow      = Color(0xFFFFD600);
  static const divider     = Color(0xFF333333);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary:   AppColors.orange,
      secondary: AppColors.orange,
      surface:   AppColors.card,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.panel,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.orange,
        fontSize: 18, fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: AppColors.orange),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:      AppColors.panel,
      selectedItemColor:    AppColors.orange,
      unselectedItemColor:  AppColors.textMuted,
      type: BottomNavigationBarType.fixed,
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(0),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      labelStyle: const TextStyle(color: AppColors.textMuted),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.orange),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: AppColors.textMain),
      bodySmall:  TextStyle(color: AppColors.textMuted),
    ),
    dividerColor: AppColors.divider,
    fontFamily: 'Roboto',
  );
}
