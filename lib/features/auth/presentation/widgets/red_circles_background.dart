import 'package:flutter/material.dart';

class RedCirclesBackground extends StatelessWidget {
  const RedCirclesBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        // Cercle en bas à gauche
        Positioned(
          left: -70,
          bottom: -80,
          child: _Circle(size: 220, opacity: 0.18),
        ),
        // Cercle en haut à droite
        Positioned(
          right: -90,
          top: 30,
          child: _Circle(size: 260, opacity: 0.14),
        ),
        // Cercle central décalé
        Positioned(
          left: 80,
          top: 90,
          child: _Circle(size: 180, opacity: 0.16),
        ),
      ],
    );
  }
}

// Sous-widget privé pour optimiser les performances
class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle({
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        // On utilise Colors.black car les cercles sont superposés
        // sur un fond rouge (AppColors.primary)
        color: Colors.black.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}