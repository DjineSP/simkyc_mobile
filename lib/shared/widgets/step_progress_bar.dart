import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isEven) {
            final stepIndex = index ~/ 2;
            final stepNumber = stepIndex + 1;
            final isCompleted = stepNumber < currentStep;
            final isActive = stepNumber == currentStep;

            return Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _StepCircle(
                    number: stepNumber,
                    isActive: isActive,
                    isCompleted: isCompleted,
                  ),
                  const SizedBox(height: 8),
                  // Contraint le texte pour éviter les débordements sur petits écrans
                  Text(
                    steps[stepIndex],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      // Utilise la couleur du thème pour le texte actif
                      color: isActive
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final stepIndex = (index - 1) ~/ 2;
            final isLineActive = (stepIndex + 1) < currentStep;

            return Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(top: 16, left: 4, right: 4),
                height: 2,
                // Utilise la couleur de bordure du thème pour la ligne inactive
                color: isLineActive
                    ? AppColors.primary
                    : theme.dividerColor.withOpacity(0.1),
              ),
            );
          }
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool isActive;
  final bool isCompleted;

  const _StepCircle({
    required this.number,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        // En mode sombre, le cercle inactif devient gris foncé (surface)
        color: (isActive || isCompleted)
            ? AppColors.primary
            : theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: (isActive || isCompleted)
              ? AppColors.primary
              : theme.dividerColor.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ] : null,
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : Text(
        '$number',
        style: TextStyle(
          color: isActive
              ? Colors.white
              : theme.colorScheme.onSurface.withOpacity(0.4),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}