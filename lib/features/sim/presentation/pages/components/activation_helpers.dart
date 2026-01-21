import 'package:flutter/material.dart';


// Décoration des champs avec gestion dynamique du thème
InputDecoration inputDec({
  required BuildContext context,
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? error,
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final borderColor = theme.colorScheme.outline.withOpacity(isDark ? 0.55 : 0.40);

  return InputDecoration(
    hintText: hint,
    errorText: error,
    errorStyle: TextStyle(color: theme.colorScheme.error, fontSize: 11),
    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.30)),
    filled: true,
    // En dark mode, on utilise la couleur de surface, sinon un gris très clair
    fillColor: isDark ? theme.colorScheme.surface : const Color(0xFFF8FAFC),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),

    border: _outline(borderColor),
    enabledBorder: _outline(borderColor),
    focusedBorder: _outline(theme.colorScheme.primary, width: 1.6),
    errorBorder: _outline(theme.colorScheme.error),
    focusedErrorBorder: _outline(theme.colorScheme.error, width: 1.6),
  );
}

OutlineInputBorder _outline(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: color, width: width),
  );
}

// Libellé de champ adapté au thème
class LabelText extends StatelessWidget {
  final String text;
  const LabelText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface.withOpacity(0.65),
        ),
      ),
    );
  }
}

// Conteneur de carte adapté au thème
class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        boxShadow: theme.brightness == Brightness.dark ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }
}