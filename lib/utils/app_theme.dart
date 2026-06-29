import 'package:flutter/material.dart';

class AppTheme {
  // Color palette — dark gamer aesthetic
  static const Color bgDeep = Color(0xFF0D0D14);
  static const Color bgCard = Color(0xFF16161F);
  static const Color bgSurface = Color(0xFF1E1E2A);
  static const Color accentGame = Color(0xFF7C5CFC); // purple — game
  static const Color accentComic = Color(0xFFFC5C7D); // pink-red — comic
  static const Color textPrimary = Color(0xFFEFEFF5);
  static const Color textSecondary = Color(0xFF8888AA);
  static const Color starColor = Color(0xFFFFD166);
  static const Color divider = Color(0xFF2A2A3A);

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDeep,
        colorScheme: const ColorScheme.dark(
          background: bgDeep,
          surface: bgCard,
          primary: accentGame,
          secondary: accentComic,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgDeep,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: textPrimary),
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: textPrimary,
          unselectedLabelColor: textSecondary,
          indicatorColor: accentGame,
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgSurface,
          hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
          labelStyle: const TextStyle(color: textSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accentGame, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentGame,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w700, fontSize: 22),
          titleLarge: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w600, fontSize: 17),
          titleMedium: TextStyle(
              color: textPrimary, fontWeight: FontWeight.w500, fontSize: 15),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        ),
        dividerColor: divider,
        useMaterial3: true,
      );
}

class AppConstants {
  // Game statuses
  static const List<String> gameStatuses = [
    'Wishlist',
    'Playing',
    'Completed',
    'Dropped',
    'On Hold',
  ];

  // Comic statuses
  static const List<String> comicStatuses = [
    'Want to Read',
    'Reading',
    'Completed',
    'Dropped',
    'On Hold',
  ];

  static Color statusColor(String status) {
    switch (status) {
      case 'Playing':
      case 'Reading':
        return const Color(0xFF4CAF50);
      case 'Completed':
        return const Color(0xFF2196F3);
      case 'Dropped':
        return const Color(0xFFF44336);
      case 'On Hold':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF8888AA);
    }
  }
}
