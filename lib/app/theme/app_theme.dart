import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppTheme {
  // Thème Clair
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        // On utilise Slate pour les éléments secondaires pour un look pro
        secondary: AppColors.slate,
        surface: Colors.white,
        error: AppColors.error,
        onPrimary: Colors.white,
        outline: AppColors.border,
      ),

      // Couleur de fond des écrans (Ton gris F4F5F7)
      scaffoldBackgroundColor: AppColors.background,

      // Personnalisation des textes
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.slate,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: AppColors.slate),
        bodyMedium: TextStyle(color: AppColors.muted),
      ),

      // Style par défaut des boutons élevés (Rouge avec texte blanc)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // Style des champs de saisie (TextField)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
      ),

      // Style des cartes
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      // Style de l'AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }

  // Thème Sombre
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        secondary: AppColors.muted,
        surface: AppColors.darkSurface, // Pour les Cards et Dialogs
        onSurface: Colors.white,
        outline: AppColors.darkBorder,
        error: AppColors.error,
        onPrimary: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground, // Fond de l'app

      // AppBar Sombre
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),

      // Champs de saisie en mode sombre
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
      ),

      // Cartes en mode sombre
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
    );
  }
}