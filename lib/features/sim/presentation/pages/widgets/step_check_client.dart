import 'package:flutter/material.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';
import '../components/activation_helpers.dart';

class StepCheckClient extends StatelessWidget {
  final Map<String, dynamic> data;

  const StepCheckClient({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // EN-TÊTE
        _buildPageHeader(l10n, theme),
        const SizedBox(height: 24),

        // 1. LIGNE À RÉACTIVER
        _buildSectionTitle(l10n.check_section_line),
        CardContainer(
          child: Column(
            children: [
              _infoRow(l10n.check_label_msisdn, data['msisdn'], theme),
              _infoRow(l10n.check_label_serial, data['serial'] ?? data['serialSearch'], theme),
              _infoRow(l10n.check_label_status, data['status'] ?? l10n.check_status_unknown, theme, isStatus: true),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. IDENTITÉ DE L'ABONNÉ
        _buildSectionTitle(l10n.check_section_identity),
        CardContainer(
          child: Column(
            children: [
              _infoRow(l10n.check_label_name, '${data['nom'] ?? ''} ${data['prenom'] ?? ''}'.trim(), theme),
              _infoRow(l10n.check_label_dob, data['dob'], theme),
              _infoRow(l10n.check_label_pob, data['pob'], theme),
              _infoRow(l10n.check_label_gender, data['gender'] ?? (data['isMale'] == true ? 'Masculin' : 'Féminin'), theme),
              _infoRow(l10n.check_label_job, data['job'], theme),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 3. COORDONNÉES
        _buildSectionTitle(l10n.check_section_coords),
        CardContainer(
          child: Column(
            children: [
              _infoRow(l10n.check_label_address, data['geo'], theme),
              _infoRow(l10n.check_label_post, data['post'] ?? 'N/A', theme),
              _infoRow(l10n.check_label_email, data['email'], theme),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. DOCUMENT D'IDENTIFICATION
        _buildSectionTitle(l10n.check_section_id),
        CardContainer(
          child: Column(
            children: [
              _infoRow(l10n.check_label_id_nature, data['idNature'] ?? 'CNI', theme),
              _infoRow(l10n.check_label_id_number, data['idNumber'], theme),
              _infoRow(l10n.check_label_id_validity, data['idValidity'], theme),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // NOTE DE SÉCURITÉ
        _buildWarningNote(l10n, theme, isDark),
      ],
    );
  }

  Widget _buildPageHeader(var l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: double.infinity),
        Text(
          l10n.check_title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
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
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value, ThemeData theme, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
                label,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.55))
            ),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? '-' : value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isStatus ? AppColors.primary : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningNote(var l10n, ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(isDark ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(isDark ? 0.4 : 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
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
    );
  }
}