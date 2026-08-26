import 'package:flutter/material.dart';
import '../constants/app_dana.dart';

class AppDanaTheme {
  AppDanaTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppDanaConstants.backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppDanaConstants.primaryColor,
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