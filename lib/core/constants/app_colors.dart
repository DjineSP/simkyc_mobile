import 'package:flutter/material.dart';

class AppColors {
  // Couleurs de la Marque (Tes couleurs spécifiques)
  static const Color primary = Color(0xFFB30000); // Ton Rouge
  static const Color red = Color(0xFFB30000);     // Alias explicite

  // Couleurs de structure (Inspirées de Slate/Tailwind)
  static const Color slate = Color(0xFF0F172A);
  static const Color muted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);

  // Fonds et Surfaces
  static const Color background = Color(0xFFF4F5F7); // Ton BG
  static const Color bg = Color(0xFFF4F5F7);         // Alias explicite

  // Status et Utilitaires
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800 (plus clair pour les cartes)
  static const Color darkBorder = Color(0xFF334155);     // Slate 700
}