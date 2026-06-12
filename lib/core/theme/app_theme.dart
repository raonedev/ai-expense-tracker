import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ───  System Light Colors ───────────────────────────────────────────────
  static const Color _lightBackground = Color(0xFFF2F2F7); //  Grouped Background
  static const Color _lightSurface = Color(0xFFFFFFFF);    //  Secondary Grouped
  static const Color _lightPrimary = Color(0xFF007AFF);    //  System Blue
  static const Color _lightSuccess = Color(0xFF34C759);    //  System Green
  static const Color _lightTextPrimary = Color(0xFF000000);
  static const Color _lightTextSecondary = Color(0xFF8E8E93);

  // ───  System Dark Colors ────────────────────────────────────────────────
  static const Color _darkBackground = Color(0xFF000000);  // True  Dark Background
  static const Color _darkSurface = Color(0xFF1C1C1E);     //  Dark Elevated Surface
  static const Color _darkPrimary = Color(0xFF0A84FF);     //  Dark System Blue
  static const Color _darkSuccess = Color(0xFF30D158);     //  Dark System Green
  static const Color _darkTextPrimary = Color(0xFFFFFFFF);
  static const Color _darkTextSecondary = Color(0xFF8E8E93);

  // ─── Shared Cupertino Geometry ─────────────────────────────────────────────
  static const double _radius = 12.0;

  // ─── Light Theme Definition ────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: _lightPrimary,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: const ColorScheme.light(
        primary: _lightPrimary,
        surface: _lightSurface,
        error: Color(0xFFFF3B30), //  System Red
      ),
      
      //  Navigation Bar Configuration
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _lightTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600, //  SF Compact SemiBold
          letterSpacing: -0.41,
        ),
        iconTheme: IconThemeData(color: _lightPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Dark status icons on light background
      ),

      //  Style Card/Container Geometry
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),

      // List Elements
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontSize: 17, 
          color: _lightTextPrimary, 
          letterSpacing: -0.41,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 15, 
          color: _lightTextSecondary, 
          letterSpacing: -0.24,
        ),
      ),

      //  Style Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _lightSurface,
        selectedItemColor: _lightPrimary,
        unselectedItemColor: _lightTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
    );
  }

  // ─── Dark Theme Definition ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: _darkPrimary,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: _darkPrimary,
        surface: _darkSurface,
        error: Color(0xFFFF453A), //  Dark System Red
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBackground,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: _darkTextPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.41,
        ),
        iconTheme: IconThemeData(color: _darkPrimary),
        systemOverlayStyle: SystemUiOverlayStyle.light, // Light status icons on dark background
      ),

      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontSize: 17, 
          color: _darkTextPrimary, 
          letterSpacing: -0.41,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 15, 
          color: _darkTextSecondary, 
          letterSpacing: -0.24,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _darkSurface,
        selectedItemColor: _darkPrimary,
        unselectedItemColor: _darkTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
    );
  }
}