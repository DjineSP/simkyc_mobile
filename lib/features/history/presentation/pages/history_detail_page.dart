import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/history_detail.dart';
import '../../domain/entities/history_item.dart';
import '../providers/history_provider.dart';

class HistoryDetailPage extends ConsumerWidget {
  final String itemId;
  final HistoryActionType type;

  const HistoryDetailPage({
    super.key,
    required this.itemId,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Ajout d'un log pour vérifier que le build se fait et que l'ID est correct
    debugPrint("Build HistoryDetailPage for ID: $itemId, Type: $type");
    
    final asyncDetail = ref.watch(historyDetailProvider((id: itemId, type: type)));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        title: Text(
          type.label.toUpperCase(), 
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 24), // Utilisation de arrow_back_rounded standard
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: asyncDetail.when(
        data: (detail) {
          if (detail == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.error_outline_rounded, size: 64, color: AppColors.muted.withOpacity(0.5)),
                   const SizedBox(height: 16),
                   const Text("Impossible de charger les détails.", style: TextStyle(color: AppColors.muted)),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(detail, isDark),
                const SizedBox(height: 24),
                
                _buildSection(
                  title: "INFOS CLIENT",
                  icon: Icons.person_outline_rounded,
                  isDark: isDark,
                  children: [
                    _buildInfoRow("Nom Complet", "${detail.prenoms ?? ''} ${detail.noms ?? ''}".trim()),
                    _buildInfoRow("Sexe", detail.sexe == true ? "Masculin" : "Féminin"),
                    _buildInfoRow("Né(e) le", _formatDate(detail.dateNaissance)),
                    _buildInfoRow("À", detail.lieuNaissance ?? '-'),
                    _buildInfoRow("Profession", detail.profession ?? '-'),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildSection(
                  title: "COORDONNÉES",
                  icon: Icons.contact_phone_outlined,
                  isDark: isDark,
                  children: [
                    _buildInfoRow("Téléphone", detail.numeroTelephoneClient ?? detail.msisdn, isBold: true),
                    _buildInfoRow("Email", detail.mail ?? '-'),
                    _buildInfoRow("Adresse", detail.adressePostale ?? '-'),
                    _buildInfoRow("Localisation", detail.adresseGeographique ?? '-'),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildSection(
                  title: "DOCUMENT D'IDENTITÉ",
                  icon: Icons.badge_outlined,
                  isDark: isDark,
                  children: [
                    _buildInfoRow("Type", detail.idNaturePiece?.toString() ?? 'Non spécifié'),
                    _buildInfoRow("Numéro", detail.numeroPiece ?? '-', isCode: true),
                    _buildInfoRow("Expire le", _formatDate(detail.dateValiditePiece)),
                  ],
                ),
                const SizedBox(height: 16),
                
                _buildSection(
                  title: "DÉTAILS OPÉRATION",
                  icon: Icons.info_outline_rounded,
                  isDark: isDark,
                  children: [
                    _buildInfoRow("ID Transaction", detail.id, isCode: true),
                    _buildInfoRow("MSISDN Cible", detail.msisdn, isCode: true),
                    _buildInfoRow("Date", _formatDateTime(detail.dateActivation ?? detail.editDate ?? detail.createDate)),
                    _buildInfoRow("Opérateur (ID)", detail.createCodeUser?.toString() ?? '-'),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        error: (err, stack) {
          debugPrint("Error fetching details: $err");
          return Center(child: Text("Une erreur est survenue: $err"));
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
    );
  }

  Widget _buildHeader(HistoryDetail detail, bool isDark) {
    // Determine status color
    final status = HistoryStatus.fromCode(detail.etat);
    final statusColor = status.color;

    return Center(
      child: Column(
        children: [
           Container(
             padding: const EdgeInsets.all(20),
             decoration: BoxDecoration(
               color: statusColor.withOpacity(0.1),
               shape: BoxShape.circle,
               border: Border.all(color: statusColor.withOpacity(0.2), width: 2),
             ),
             child: Icon(
                _getIconForType(type),
                color: statusColor,
                size: 40,
             ),
           ),
           const SizedBox(height: 16),
           Text(
             "${detail.prenoms ?? ''} ${detail.noms ?? ''}".trim(),
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
               status.label,
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
                color: isBold ? AppColors.primary : null,
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
}
