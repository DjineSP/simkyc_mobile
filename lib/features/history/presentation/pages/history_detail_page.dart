import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/history_detail.dart';
import '../../domain/entities/history_item.dart';

class HistoryDetailPage extends StatelessWidget {
  final HistoryItem item;

  const HistoryDetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final detail = item.details;
    final type = item.type;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          _getTypeLabel(type, l10n).toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: detail == null 
        ? Center(child: Text(l10n.history_detail_error_load))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(detail, type, isDark, l10n),
                const SizedBox(height: 24),
                
                _buildSection(
                  title: l10n.history_detail_title_op,
                  icon: Icons.info_outline_rounded,
                  isDark: isDark,
                  children: [
                    _buildInfoRow(l10n.history_detail_label_op_id, detail.id, isCode: true),
                    _buildInfoRow(l10n.history_detail_label_op_serial, detail.msisdn, isCode: true),
                    _buildInfoRow(l10n.history_detail_label_op_target, StringUtils.formatPhone(detail.numeroTelephoneClient ?? ''), isCode: true, isBold: true),
                    _buildInfoRow(l10n.history_detail_label_op_date, _formatDateTime(detail.dateActivation ?? detail.editDate ?? detail.createDate)),
                  ],
                ),
                const SizedBox(height: 16),

                _buildSection(
                  title: l10n.history_detail_title_client,
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  children: [
                     _buildInfoRow(l10n.history_detail_label_fullname, "${detail.noms ?? ''} ${detail.prenoms ?? ''}".trim()),
                    _buildInfoRow(l10n.history_detail_label_gender, detail.sexe == true ? l10n.history_detail_value_male : l10n.history_detail_value_female),
                    _buildInfoRow(l10n.history_detail_label_dob, _formatDate(detail.dateNaissance)),
                    _buildInfoRow(l10n.history_detail_label_pob, detail.lieuNaissance ?? '-'),
                    _buildInfoRow(l10n.history_detail_label_job, detail.profession ?? '-'),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildSection(
                  title: l10n.history_detail_title_coords,
                  icon: Icons.contact_phone_outlined,
                  isDark: isDark,
                  children: [
                    _buildInfoRow(l10n.history_detail_label_phone, detail.numeroTelephoneClient ?? detail.msisdn, isBold: true),
                    _buildInfoRow(l10n.history_detail_label_email, detail.mail ?? '-'),
                    _buildInfoRow(l10n.history_detail_label_address, detail.adressePostale ?? '-'),
                    _buildInfoRow(l10n.history_detail_label_location, detail.adresseGeographique ?? '-'),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildSection(
                  title: l10n.history_detail_title_id,
                  icon: Icons.badge_outlined,
                  isDark: isDark,
                  children: [
                    _buildInfoRow(
                      l10n.history_detail_label_id_type,
                      detail.libelleNaturePiece ?? l10n.history_detail_value_unspecified
                    ),
                    _buildInfoRow(l10n.history_detail_label_id_number, detail.numeroPiece ?? '-', isCode: true),
                    _buildInfoRow(l10n.history_detail_label_id_expire, _formatDate(detail.dateValiditePiece)),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
    );
  }

  Widget _buildHeader(HistoryDetail detail, HistoryActionType type, bool isDark, AppLocalizations l10n) {
    // Determine status color
    final status = HistoryStatus.fromCode(detail.etat);
    final statusColor = status.color;
    // Map status label if possible, else use default
    String statusLabel = status.label;
    if (status == HistoryStatus.active) statusLabel = l10n.history_status_active;
    if (status == HistoryStatus.suspended) statusLabel = l10n.history_status_suspended;

    return Center(
      child: Column(
        children: [
           Text(
             "${detail.noms ?? ''} ${detail.prenoms ?? ''}".trim(),
             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
             textAlign: TextAlign.center,
           ),
           const SizedBox(height: 4),
           Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
             decoration: BoxDecoration(
               color: statusColor.withOpacity(0.1),
               borderRadius: BorderRadius.circular(20),
             ),
             child: Text(
               statusLabel,
               style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title, 
    required IconData icon, 
    required bool isDark, 
    required List<Widget> children
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.03),
             blurRadius: 10,
             offset: const Offset(0, 4),
           ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Padding(
             padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
             child: Row(
               children: [
                 Icon(icon, size: 18, color: AppColors.primary),
                 const SizedBox(width: 10),
                 Text(
                   title,
                   style: const TextStyle(
                     fontSize: 13,
                     fontWeight: FontWeight.bold,
                     color: AppColors.muted,
                     letterSpacing: 0.5,
                   ),
                 ),
               ],
             ),
           ),
           Divider(height: 1, color: isDark ? AppColors.darkBorder : AppColors.border.withOpacity(0.3)),
           Padding(
             padding: const EdgeInsets.all(20),
             child: Column(children: children),
           ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCode = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 14)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value, 
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500, 
                fontSize: 14,
                fontFamily: isCode ? 'Monospace' : null,
                color: isBold ? null : null,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  IconData _getIconForType(HistoryActionType type) {
    switch (type) {
      case HistoryActionType.activation: return Icons.add_circle_outline_rounded;
      case HistoryActionType.reactivation: return Icons.refresh_rounded;
      case HistoryActionType.update: return Icons.edit_outlined;
    }
  }

  String _getTypeLabel(HistoryActionType type, AppLocalizations l10n) {
    switch (type) {
      case HistoryActionType.activation: return l10n.home_action_activation; // Or specific key if needed
      case HistoryActionType.reactivation: return l10n.home_action_reactivation;
      case HistoryActionType.update: return l10n.home_action_update;
    }
  }
}
