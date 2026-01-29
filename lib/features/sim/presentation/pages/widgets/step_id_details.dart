import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../../../data/repositories/sim_activation_repository.dart';
import '../components/activation_helpers.dart';


class StepIdDetails extends ConsumerWidget {
  final TextEditingController nature;
  final TextEditingController number;
  final TextEditingController validity;

  final FocusNode natureFocus;
  final FocusNode numberFocus;
  final FocusNode validityFocus;
  final String? natureError;
  final String? numberError;
  final String? validityError;

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
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final idNaturesAsync = ref.watch(idNaturesProvider);

    final selectedValue = nature.text.isEmpty ? null : nature.text;

    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- NATURE DE LA PIÈCE ---
          LabelText(l10n.step_id_nature_label),
          idNaturesAsync.when(
            data: (items) {
              final dropdownItems = items.map<DropdownMenuItem<String>>((e) {
                final id = e['id'] ?? e['value'] ?? e['code'];
                final label = e['libelle'] ?? e['label'] ?? e['name'] ?? id?.toString() ?? '';
                return DropdownMenuItem<String>(
                  value: id?.toString(),
                  child: Text(label.toString()),
                );
              }).toList();

              return DropdownButtonFormField<String>(
                value: selectedValue,
                focusNode: natureFocus,
                isExpanded: true, // Indispensable pour que le texte tronqué prenne toute la largeur
                dropdownColor: theme.colorScheme.surface,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                
                // Définit l'affichage de l'élément une fois sélectionné dans le champ
                selectedItemBuilder: (BuildContext context) {
                  return items.map<Widget>((item) {
                    final label = item['libelle'] ?? item['label'] ?? item['name'] ?? '';
                    return Text(
                      label.toString(),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis, // Ajoute les "..." si le texte dépasse
                    );
                  }).toList();
                },

                decoration: inputDec(
                  context: context,
                  hint: l10n.step_id_nature_hint,
                  error: natureError,
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down, 
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                items: dropdownItems,
                onChanged: (newValue) {
                  if (newValue != null) {
                    nature.text = newValue;
                  }
                },
                borderRadius: BorderRadius.circular(12),
              );
            },
            loading: () => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: LinearProgressIndicator(color: AppColors.primary, backgroundColor: theme.dividerColor.withOpacity(0.2)),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                e.toString(),
                style: TextStyle(color: theme.colorScheme.error, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
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