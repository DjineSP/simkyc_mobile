import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../components/activation_helpers.dart';


class StepIdDetails extends StatelessWidget {
  final TextEditingController nature;
  final TextEditingController number;
  final TextEditingController validity;

  final FocusNode natureFocus;
  final FocusNode numberFocus;
  final FocusNode validityFocus;
  final String? natureError;
  final String? numberError;
  final String? validityError;

  final List<String> naturesPiece = [
    'CNI',
    'Passeport',
    'Carte de séjour',
    'Récépissé',
    'Permis de conduire'
  ];

  StepIdDetails({
    super.key,
    required this.nature,
    required this.number,
    required this.validity,
    required this.natureFocus,
    required this.numberFocus,
    required this.validityFocus,
    this.natureError,
    this.numberError,
    this.validityError,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NATURE DE LA PIÈCE ---
          LabelText(l10n.step_id_nature_label),
          DropdownButtonFormField<String>(
            value: nature.text.isEmpty ? null : nature.text,
            focusNode: natureFocus,
            // Adaptation au Dark Mode pour le menu
            dropdownColor: theme.colorScheme.surface,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            decoration: inputDec(
              context: context,
              hint: l10n.step_id_nature_hint,
              error: natureError,
            ),
            icon: Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            items: naturesPiece.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                nature.text = newValue;
              }
            },
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 16),

          // --- NUMÉRO DE LA PIÈCE ---
          LabelText(l10n.step_id_number_label),
          TextField(
            controller: number,
            focusNode: numberFocus,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface
            ),
            decoration: inputDec(
              context: context,
              hint: l10n.step_id_number_hint,
              error: numberError,
            ),
          ),
          const SizedBox(height: 16),

          // --- DATE DE VALIDITÉ ---
          LabelText(l10n.step_id_validity),
          TextField(
            controller: validity,
            focusNode: validityFocus,
            readOnly: true,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface
            ),
            decoration: inputDec(
              context: context,
              hint: l10n.step_id_date_hint,
              error: validityError,
              suffixIcon: Icon(Icons.event_available_rounded, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ),
            onTap: () => _selectValidityDate(context),
          ),
        ],
      ),
    );
  }

  Future<void> _selectValidityDate(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)), // Par défaut +1 an
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: theme.colorScheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      validity.text =
      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }
}