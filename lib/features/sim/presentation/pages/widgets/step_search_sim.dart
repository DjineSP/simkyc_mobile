import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/utils/phone_formatter.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../components/activation_helpers.dart';

class StepSearchSim extends StatelessWidget {
  final Map<String, TextEditingController> ctrls;
  final Map<String, FocusNode> nodes;
  final Map<String, String?> errors;

  const StepSearchSim({
    super.key,
    required this.ctrls,
    required this.nodes,
    required this.errors,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: Listenable.merge([
        ctrls['msisdnSearch'] ?? TextEditingController(),
        ctrls['msisdn'] ?? TextEditingController(),
      ]),
      builder: (context, _) {
        final bool isIdentified = (ctrls['msisdn']?.text ?? "").isNotEmpty;

        return Column(
          children: [
            CardContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelText(l10n.step_search_sim_msisdn_label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrls['msisdnSearch'],
                    focusNode: nodes['msisdnSearch'],
                    keyboardType: TextInputType.phone,
                    // Note : PhoneFormatter gère déjà le filtrage des chiffres en interne
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneFormatter()],
                    cursorColor: theme.colorScheme.primary,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: inputDec(
                      context: context,
                      hint: l10n.step_search_sim_msisdn_hint,
                      error: errors['msisdnSearch'],
                      prefixIcon: Icon(
                        Icons.phone_android_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (isIdentified)
                    _buildUserBadge(ctrls['msisdn']!.text, theme, l10n)
                  else
                    _buildInfoBadge(theme, l10n),

                  const SizedBox(height: 24),
                  LabelText(l10n.step_search_sim_reason_label),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrls['reason'],
                    focusNode: nodes['reason'],
                    maxLines: 2,
                    cursorColor: theme.colorScheme.primary,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: inputDec(
                      context: context,
                      hint: l10n.step_search_sim_reason_hint,
                      error: errors['reason'],
                      prefixIcon: Icon(
                        Icons.edit_note_rounded,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUserBadge(String phone, ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.green.withOpacity(0.15) : const Color(0xFFE8F7EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1F7A3F).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1F7A3F), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.step_search_sim_user_identified,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF1F7A3F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(phone,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: theme.dividerColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.2))
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  l10n.step_search_sim_info,
                  style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.65), fontStyle: FontStyle.italic)
              ),
          ),
        ],
      ),
    );
  }
}