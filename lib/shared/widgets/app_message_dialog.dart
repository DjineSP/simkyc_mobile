import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum AppMessageType { success, error, info }

Future<void> showAppMessageDialog(
    BuildContext context, {
      required String title,
      required String message,
      AppMessageType type = AppMessageType.info,
      Duration? autoDismiss,
    }) {
  final theme = Theme.of(context);
  final scheme = theme.colorScheme;

  Color iconColor;
  IconData icon;

  // Harmonisation avec tes couleurs AppColors
  switch (type) {
    case AppMessageType.success:
      iconColor = AppColors.success;
      icon = Icons.check_circle_rounded;
      break;
    case AppMessageType.error:
      iconColor = scheme.error;
      icon = Icons.error_rounded;
      break;
    case AppMessageType.info:
    default:
      iconColor = scheme.primary;
      icon = Icons.info_outline_rounded;
      break;
  }

  // Timer pour auto-fermeture si nécessaire
  if (autoDismiss != null) {
    Future.delayed(autoDismiss, () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Message',
    barrierColor: Colors.black.withOpacity(0.5), // Un peu plus sombre pour focus
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);

      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(curved),
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icône stylisée
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 32),
                    ),
                    const SizedBox(height: 20),
                    // Titre
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Message
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: scheme.onSurface.withOpacity(0.75),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Bouton de fermeture optionnel (pour UX)
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: scheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "OK",
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}