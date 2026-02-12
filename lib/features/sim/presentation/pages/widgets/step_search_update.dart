import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/utils/phone_formatter.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../components/activation_helpers.dart';

class StepSearchUpdate extends StatelessWidget {
  final Map<String, TextEditingController> ctrls;
  final Map<String, FocusNode> nodes;
  final Map<String, String?> errors;

  const StepSearchUpdate({
    super.key,
    required this.ctrls,
    required this.nodes,
    required this.errors
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelText(l10n.step_search_update_msisdn_label),
          const SizedBox(height: 8),
          TextField(
            controller: ctrls['msisdnSearch'],
            focusNode: nodes['msisdnSearch'],
            keyboardType: TextInputType.phone,
            cursorColor: theme.colorScheme.primary,
            // Utilisation du formateur de téléphone pour gérer le format guinéen (commençant par 6)
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneFormatter()],
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            decoration: inputDec(
              context: context,
              hint: l10n.step_search_update_msisdn_hint,
              error: errors['msisdnSearch'],
              prefixIcon: Icon(
                Icons.phone_android_rounded,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                size: 20,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Badge informatif simple (sans l'état "Abonné trouvé")
          Container(
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
                        l10n.step_search_update_info,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.65), fontStyle: FontStyle.italic)
                    )
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}