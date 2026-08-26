import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Arial',
      scaffoldBackgroundColor: const Color(0xFFF4F7FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF245FC9),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF245FC9),
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }
}
