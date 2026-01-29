import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
import 'dart:io';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/repositories/sim_activation_repository.dart';
import '../components/activation_helpers.dart';


class StepEditClient extends ConsumerWidget {
  final Map<String, TextEditingController> ctrls;
  final Map<String, FocusNode> nodes;
  final Map<String, String?> errors;
  final File? frontImg;
  final File? backImg;
  final Function(File? file, bool isFront) onPhotoUpdate;

  const StepEditClient({
    super.key,
    required this.ctrls,
    required this.nodes,
    required this.errors,
    this.frontImg,
    this.backImg,
    required this.onPhotoUpdate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final idNaturesAsync = ref.watch(idNaturesProvider);

    final selectedValue = (ctrls['idNature']?.text.isEmpty ?? true) ? null : ctrls['idNature']!.text;

    return ValueListenableBuilder(
      valueListenable: ctrls['gender']!,
      builder: (context, TextEditingValue genderValue, child) {
        bool isMale = genderValue.text == 'Homme' || genderValue.text == 'Male';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1 : IDENTITÉ ---
            LabelText(l10n.step_edit_identity_label),
            const SizedBox(height: 8),
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildField(context, l10n.step_cust_lastname, 'lastName', hint: l10n.step_cust_hint_name)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildField(context, l10n.step_cust_firstname, 'firstName', hint: l10n.step_cust_hint_firstname)),
                    ],
                  ),
                  _buildDatePicker(context, l10n.step_cust_dob, 'dob'),
                  _buildField(context, l10n.step_cust_pob, 'pob', hint: l10n.step_cust_hint_pob),
                  LabelText(l10n.step_cust_gender),
                  Row(
                    children: [
                      _radio(context, l10n.step_cust_male, true, isMale),
                      _radio(context, l10n.step_cust_female, false, isMale),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 2 : COMPLÉMENTS ---
            LabelText(l10n.step_edit_complementary_label),
            const SizedBox(height: 8),
            CardContainer(
              child: Column(
                children: [
                  _buildField(context, l10n.step_cust_job, 'job', hint: l10n.step_cust_hint_job),
                  _buildField(context, l10n.step_cust_geo, 'geo', hint: l10n.step_cust_hint_geo),
                  _buildField(context, l10n.step_cust_post, 'post', hint: l10n.step_cust_hint_post),
                  _buildField(context, l10n.step_cust_email, 'email', hint: l10n.step_cust_hint_email),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- SECTION 3 : DOCUMENT ---
            LabelText(l10n.step_edit_id_doc_label),
            const SizedBox(height: 8),
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelText(l10n.step_edit_nature_label),
                  idNaturesAsync.when(
                    data: (items) {
                      final dropdownItems = items.map<DropdownMenuItem<String>>((e) {
                        final id = e['id'] ?? e['value'] ?? e['code'];
                        final label = e['libelle'] ?? e['label'] ?? e['name'] ?? id?.toString() ?? '';
                        return DropdownMenuItem<String>(
                          value: id?.toString(),
                          child: Text(label.toString()), // Dans la liste ouverte, le texte peut rester normal
                        );
                      }).toList();

                      return DropdownButtonFormField<String>(
                        value: selectedValue,
                        isExpanded: true, // 1. Obligatoire pour permettre au texte de se tronquer
                        
                        // 2. Personnalise l'affichage du texte une fois sélectionné
                        selectedItemBuilder: (BuildContext context) {
                          return items.map<Widget>((e) {
                            final label = e['libelle'] ?? e['label'] ?? e['name'] ?? '';
                            return Text(
                              label.toString(),
                              maxLines: 1, // Force une ligne
                              overflow: TextOverflow.ellipsis, // Ajoute "..." si trop long
                              softWrap: false,
                            );
                          }).toList();
                        },

                        decoration: inputDec(
                          context: context, 
                          hint: l10n.step_edit_id_hint, 
                          error: errors['idNature'],
                        ),
                        dropdownColor: theme.colorScheme.surface,
                        style: TextStyle(
                          fontSize: 14, 
                          fontWeight: FontWeight.w600, 
                          color: theme.colorScheme.onSurface,
                        ),
                        items: dropdownItems,
                        onChanged: (val) {
                          if (val != null) ctrls['idNature']?.text = val;
                        },
                      );
                    },
                    loading: () => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: LinearProgressIndicator(
                        color: AppColors.primary,
                        backgroundColor: theme.dividerColor.withOpacity(0.2),
                      ),
                    ),
                    error: (e, _) => Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        e.toString(),
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildField(context, l10n.step_edit_id_number_label, 'idNumber', hint: l10n.step_edit_id_number_hint),
                  _buildDatePicker(context, l10n.step_id_validity, 'idValidity', isFuture: true),

                  const SizedBox(height: 8),
                  LabelText(l10n.step_edit_photos_label),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _EditPhotoBox(label: l10n.step_edit_photo_recto, image: frontImg, error: errors['idFront'], onTap: () => onPhotoUpdate(null, true))),
                      const SizedBox(width: 12),
                      Expanded(child: _EditPhotoBox(label: l10n.step_edit_photo_verso, image: backImg, error: errors['idBack'], onTap: () => onPhotoUpdate(null, false))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildField(BuildContext context, String label, String key, {required String hint}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(label),
        TextField(
          controller: ctrls[key],
          focusNode: nodes[key] ?? FocusNode(),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
          decoration: inputDec(context: context, hint: hint, error: errors[key]),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, String key, {bool isFuture = false}) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(label),
        TextField(
          controller: ctrls[key],
          readOnly: true,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
          decoration: inputDec(
            context: context,
            hint: l10n.step_edit_date_hint,
            error: errors[key],
            suffixIcon: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
          ),
          onTap: () async {
            final p = await showDatePicker(
              context: context,
              initialDate: isFuture ? DateTime.now().add(const Duration(days: 30)) : DateTime.now().subtract(const Duration(days: 6570)),
              firstDate: isFuture ? DateTime.now() : DateTime(1900),
              lastDate: isFuture ? DateTime(2100) : DateTime.now(),
              builder: (context, child) => Theme(
                data: theme.copyWith(colorScheme: theme.colorScheme.copyWith(primary: AppColors.primary)),
                child: child!,
              ),
            );
            if (p != null) ctrls[key]!.text = "${p.day.toString().padLeft(2, '0')}/${p.month.toString().padLeft(2, '0')}/${p.year}";
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _radio(BuildContext context, String t, bool v, bool current) => Expanded(
    child: RadioListTile<bool>(
      title: Text(t, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      value: v,
      groupValue: current,
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      onChanged: (val) { if (val != null) ctrls['gender']?.text = val ? 'Homme' : 'Femme'; },
    ),
  );
}

class _EditPhotoBox extends StatelessWidget {
  final String label;
  final File? image;
  final String? error;
  final VoidCallback onTap;

  const _EditPhotoBox({required this.label, this.image, this.error, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 115, width: double.infinity,
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? theme.colorScheme.surface : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: error != null ? AppColors.primary : (image != null ? Colors.green.withOpacity(0.5) : theme.dividerColor.withOpacity(0.1)),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: image != null
                  ? Stack(fit: StackFit.expand, children: [
                Image.file(image!, fit: BoxFit.cover),
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircleAvatar(backgroundColor: AppColors.primary, radius: 18, child: Icon(Icons.edit_rounded, color: Colors.white, size: 18))),
                ),
              ])
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_a_photo_outlined, color: error != null ? AppColors.primary : theme.colorScheme.onSurface.withOpacity(0.4), size: 28),
                const SizedBox(height: 4),
                Text(l10n.step_edit_photo_hint, style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.5))),
              ]),
            ),
          ),
        ),
        const SizedBox(height: 6),
        LabelText(label),
        if (error != null) Text(error!, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}