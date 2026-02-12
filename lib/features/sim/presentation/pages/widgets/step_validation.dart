import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../../l10n/gen/app_localizations.dart';
import '../components/activation_helpers.dart';

class StepValidation extends StatelessWidget {
  final Map<String, TextEditingController> ctrls;
  final bool isMale;
  final File? frontImg;
  final File? backImg;

  const StepValidation({
    super.key,
    required this.ctrls,
    required this.isMale,
    this.frontImg,
    this.backImg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Aligne la colonne au centre
          children: [
            const SizedBox(width: double.infinity), // Force la colonne à prendre toute la largeur pour le centrage
            Text(
              l10n.check_title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.check_subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic, // Mise en italique
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 1. SECTION SIM
        _buildHeaderSection(theme, l10n.sim_step_1),
        CardContainer(
          child: Column(
            children: [
              _infoRow(theme, l10n.check_label_msisdn, ctrls['msisdn']?.text),
              _infoRow(theme, l10n.check_label_serial, ctrls['serial']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. SECTION CLIENT
        _buildHeaderSection(theme, l10n.check_section_identity),
        CardContainer(
          child: Column(
            children: [
              _infoRow(
                theme,
                l10n.check_label_name,
                '${ctrls['lastName']?.text ?? ''} ${ctrls['firstName']?.text ?? ''}'.trim(),
              ),
              _infoRow(theme, l10n.check_label_dob, ctrls['dob']?.text),
              _infoRow(theme, l10n.check_label_pob, ctrls['pob']?.text),
              _infoRow(theme, l10n.check_label_gender, isMale ? l10n.step_cust_male : l10n.step_cust_female),
              _infoRow(theme, l10n.check_label_job, ctrls['job']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. SECTION COORDONNÉES
        _buildHeaderSection(theme, l10n.check_section_coords),
        CardContainer(
          child: Column(
            children: [
              _infoRow(theme, l10n.check_label_address, ctrls['geo']?.text),
              _infoRow(theme, l10n.check_label_post, ctrls['post']?.text),
              _infoRow(theme, l10n.check_label_email, ctrls['email']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. SECTION PIÈCE D'IDENTITÉ
        _buildHeaderSection(theme, l10n.check_section_id),
        CardContainer(
          child: Column(
            children: [
              _infoRow(theme, l10n.check_label_id_nature, ctrls['idNature']?.text),
              _infoRow(theme, l10n.check_label_id_number, ctrls['idNumber']?.text),
              _infoRow(theme, l10n.check_label_id_validity, ctrls['idValidity']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 5. SECTION PHOTOS
        _buildHeaderSection(theme, l10n.sim_step_4),
        Row(
          children: [
            _imagePreview(theme, l10n.step_photo_front_title, frontImg),
            const SizedBox(width: 12),
            _imagePreview(theme, l10n.step_photo_back_title, backImg),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Petit titre de section rouge et stylisé
  Widget _buildHeaderSection(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  // Ligne d'information clé/valeur
  Widget _infoRow(ThemeData theme, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de prévisualisation d'image
  Widget _imagePreview(ThemeData theme, String label, File? image) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: image != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(image, fit: BoxFit.cover),
            )
                : Icon(
                    Icons.image_not_supported_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}