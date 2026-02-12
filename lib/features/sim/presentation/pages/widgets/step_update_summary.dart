import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../components/activation_helpers.dart';

class StepUpdateSummary extends StatelessWidget {
  final Map<String, TextEditingController> ctrls;
  final File? frontImg;
  final File? backImg;

  const StepUpdateSummary({
    super.key,
    required this.ctrls,
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
        // EN-TÊTE
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: double.infinity),
            Text(
              l10n.sim_update_summary_title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.sim_update_summary_subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 1. IDENTITÉ DE L'ABONNÉ
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
              _infoRow(theme, l10n.check_label_gender, ctrls['gender']?.text),
              _infoRow(theme, l10n.check_label_job, ctrls['job']?.text),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. COORDONNÉES
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

        // 3. DOCUMENT D'IDENTIFICATION
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

        // 4. DOCUMENTS MODIFIÉS (PHOTOS)
        _buildHeaderSection(theme, l10n.step_edit_photos_label),
        Row(
          children: [
            Expanded(child: _buildPhotoThumb(theme, l10n.step_edit_photo_recto, frontImg)),
            const SizedBox(width: 12),
            Expanded(child: _buildPhotoThumb(theme, l10n.step_edit_photo_verso, backImg)),
          ],
        ),
        const SizedBox(height: 24),

        // NOTE DE SÉCURITÉ
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.colorScheme.error.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.error, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.check_warning,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

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

  Widget _infoRow(ThemeData theme, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 145,
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

  Widget _buildPhotoThumb(ThemeData theme, String label, File? file) {
    return Column(
      children: [
        Container(
          height: 90,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: file != null
                ? Image.file(file, fit: BoxFit.cover)
                : Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}