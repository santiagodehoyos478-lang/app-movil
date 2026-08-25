import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor:
    AppConstants.backgroundColor,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
    ),

    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),

    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}