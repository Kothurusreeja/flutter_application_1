import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0D0D14),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9C6BFF),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
        titleMedium: TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF5F3FF),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF9C6BFF),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1C1C2D)),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1C1C2D)),
        bodyMedium: TextStyle(color: Color(0xFF1C1C2D)),
        titleMedium: TextStyle(color: Color(0xFF1C1C2D)),
      ),
    );
  }
}
