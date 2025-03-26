// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class AppTheme {
  // Modern Color Palette
  static const Color primaryLight = Color(0xFF4361EE); // Vibrant blue
  static const Color primaryLightVariant = Color(0xFF3A56D4); // Slightly darker blue
  static const Color backgroundLight = Color(0xFFF8F9FC); // Very light blue-gray
  static const Color cardLight = Colors.white;
  static const Color textPrimaryLight = Color(0xFF2D3748); // Dark blue-gray
  static const Color textSecondaryLight = Color(0xFF718096); // Medium blue-gray
  
  // Updated Dark Theme Colors
  static const Color primaryDark = Color(0xFF6366F1); // Indigo color for dark theme
  static const Color primaryDarkVariant = Color(0xFF818CF8); // Lighter indigo
  static const Color backgroundDark = Color(0xFF121212); // Darker background
  static const Color cardDark = Color(0xFF1E1E1E); // Darker card
  static const Color textPrimaryDark = Color(0xFFF9FAFB); // Whiter text for better contrast
  static const Color textSecondaryDark = Color(0xFFB0B9C6); // Lighter secondary text
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue
  
  // Card shadow colors
  static const Color shadowColorLight = Color(0x1A000000); // Black with 10% opacity
  static const Color shadowColorDark = Color(0x4D000000); // Black with 30% opacity

  // Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: primaryLight,
        onPrimary: Colors.white,
        primaryContainer: primaryLight.withOpacity(0.1),
        onPrimaryContainer: primaryLight,
        secondary: Color(0xFF6366F1), // Indigo
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFF6366F1).withOpacity(0.1),
        onSecondaryContainer: Color(0xFF6366F1),
        tertiary: Color(0xFF8B5CF6), // Purple
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFF8B5CF6).withOpacity(0.1),
        onTertiaryContainer: Color(0xFF8B5CF6),
        surface: cardLight,
        onSurface: textPrimaryLight,
        surfaceVariant: Color(0xFFF1F5F9),
        onSurfaceVariant: textSecondaryLight,
        background: backgroundLight,
        onBackground: textPrimaryLight,
        error: error,
        onError: Colors.white,
        errorContainer: error.withOpacity(0.1),
        onErrorContainer: error,
      ),
      scaffoldBackgroundColor: backgroundLight,
      cardTheme: CardTheme(
        color: cardLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: textPrimaryLight, 
          fontSize: 16,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          color: textSecondaryLight, 
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryLight),
        titleTextStyle: TextStyle(
          color: textPrimaryLight,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: primaryLight,
        labelColor: primaryLight,
        unselectedLabelColor: textSecondaryLight,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryLight,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryLight,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryLight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: primaryLight, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primaryLight,
          backgroundColor: Colors.transparent,
          minimumSize: Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryLight, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondaryLight),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 24,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardLight,
        indicatorColor: primaryLight.withOpacity(0.1),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textPrimaryLight,
          ),
        ),
        iconTheme: MaterialStateProperty.all(
          IconThemeData(
            color: textSecondaryLight,
            size: 24,
          ),
        ),
      ),
    );
  }

  // Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: primaryDark,
        onPrimary: Colors.white,
        primaryContainer: primaryDark.withOpacity(0.15),
        onPrimaryContainer: Colors.white,
        secondary: primaryDarkVariant, // Using our lighter indigo
        onSecondary: Colors.white,
        secondaryContainer: primaryDarkVariant.withOpacity(0.15),
        onSecondaryContainer: Colors.white,
        tertiary: Color(0xFFA78BFA), // Lighter purple
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFA78BFA).withOpacity(0.15),
        onTertiaryContainer: Colors.white,
        surface: cardDark,
        onSurface: textPrimaryDark,
        surfaceVariant: Color(0xFF2A2A2A), // Slightly lighter than card
        onSurfaceVariant: textPrimaryDark,
        background: backgroundDark,
        onBackground: textPrimaryDark,
        error: error,
        onError: Colors.white,
        errorContainer: error.withOpacity(0.15),
        onErrorContainer: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundDark,
      cardTheme: CardTheme(
        color: cardDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFF303030), width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.bold,
          fontSize: 28,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.2,
        ),
        titleMedium: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          color: textPrimaryDark, 
          fontSize: 16,
          letterSpacing: 0.1,
        ),
        bodyMedium: TextStyle(
          color: textSecondaryDark, 
          fontSize: 14,
          letterSpacing: 0.1,
        ),
        labelLarge: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.w500,
          fontSize: 14,
          letterSpacing: 0.1,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimaryDark,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: primaryDark),
        titleTextStyle: TextStyle(
          color: textPrimaryDark,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      tabBarTheme: TabBarTheme(
        indicatorColor: primaryDark,
        labelColor: primaryDark,
        unselectedLabelColor: textSecondaryDark,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryDark,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          side: BorderSide(color: primaryDark, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: primaryDark,
          backgroundColor: Colors.transparent,
          minimumSize: Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF252525),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF303030), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF303030), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryDark, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        labelStyle: TextStyle(color: textSecondaryDark),
      ),
      dividerTheme: DividerThemeData(
        color: Color(0xFF303030),
        thickness: 1,
        space: 24,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cardDark,
        indicatorColor: primaryDark.withOpacity(0.15),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textPrimaryDark,
          ),
        ),
        iconTheme: MaterialStateProperty.all(
          IconThemeData(
            color: textSecondaryDark,
            size: 24,
          ),
        ),
      ),
    );
  }
}