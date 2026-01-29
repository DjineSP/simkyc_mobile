import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../../../data/repositories/sim_activation_repository.dart';
import '../components/activation_helpers.dart';
import '../components/sim_code_scanner.dart';

class StepSimDetails extends ConsumerWidget {
  final TextEditingController msisdn;
  final TextEditingController serial;
  final FocusNode msisdnFocus;
  final FocusNode serialFocus;
  final String? msisdnError;
  final String? serialError;

  const StepSimDetails({
    super.key,
    required this.msisdn,
    required this.serial,
    required this.msisdnFocus,
    required this.serialFocus,
    this.msisdnError,
    this.serialError,
  });

  // --- LOGIQUE DU SCANNER ---
  void _handleScan(BuildContext context, WidgetRef ref) {
    SimCodeScanner.show(
      context,
      onCodeScanned: (code) => _fetchSimDataFromApi(context, ref, code),
    );
  }

  Future<void> _fetchSimDataFromApi(BuildContext context, WidgetRef ref, String code) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      serial.text = code;

      final repo = ref.read(simActivationRepositoryProvider);
      final fetchedMsisdn = await repo.fetchMsisdnFromSerial(code);
      msisdn.text = fetchedMsisdn;

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([msisdn, serial]),
      builder: (context, child) {
        final bool hasMsisdn = msisdn.text.isNotEmpty;

        return CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(l10n.step_sim_serial_label),
              const SizedBox(height: 8),
              TextField(
                controller: serial,
                focusNode: serialFocus,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) {
                  if (value.isNotEmpty) _fetchSimDataFromApi(context, ref, value);
                },
                decoration: inputDec(
                  context: context,
                  hint: l10n.step_sim_serial_hint,
                  error: serialError,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary, size: 24),
                    onPressed: () => _handleScan(context, ref),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Feedback visuel (Badge)
              hasMsisdn
                  ? _buildSuccessBadge(msisdn.text, theme, l10n)
                  : _buildInfoBadge(theme, l10n),

              if (msisdnError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                      msisdnError!,
                      style: const TextStyle(color: AppColors.primary, fontSize: 12)
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSuccessBadge(String phone, ThemeData theme, var l10n) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.green.withOpacity(0.15) : const Color(0xFFE8F7EE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  l10n.step_sim_success,
                  style: const TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)
              ),
              Text(
                  phone,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: theme.colorScheme.onSurface)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(ThemeData theme, var l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: theme.colorScheme.onSurface.withOpacity(0.4), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
                l10n.step_sim_info,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5), fontStyle: FontStyle.italic)
            ),
          ),
        ],
      ),
    );
  }
}