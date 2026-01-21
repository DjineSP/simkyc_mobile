import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/utils/phone_formatter.dart';
import '../../../../../l10n/gen/app_localizations.dart';
import '../components/activation_helpers.dart';
import '../components/sim_code_scanner.dart';

class StepNewSimDetails extends StatefulWidget {
  final Map<String, TextEditingController> ctrls;
  final Map<String, FocusNode> nodes;
  final Map<String, String?> errors;

  const StepNewSimDetails({
    super.key,
    required this.ctrls,
    required this.nodes,
    required this.errors,
  });

  @override
  State<StepNewSimDetails> createState() => _StepNewSimDetailsState();
}

class _StepNewSimDetailsState extends State<StepNewSimDetails> {
  String? _associatedMsisdn;
  bool _isLoading = false;
  bool _isScanned = false; // <-- Contrôle l'affichage du badge

  @override
  void initState() {
    super.initState();
    // On écoute toujours les changements pour réinitialiser l'état si on efface
    widget.ctrls['newSerial']!.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    if (widget.ctrls['newSerial']!.text.isEmpty && (_isScanned || _associatedMsisdn != null)) {
      setState(() {
        _isScanned = false;
        _associatedMsisdn = null;
      });
    }
  }

  // --- RECHERCHE API SIMULÉE ---
  Future<void> _lookupNumber(String iccid) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _associatedMsisdn = "620 45 88 12";
      });
    }
  }

  // --- LOGIQUE DE SCAN ---
  void _handleScan(BuildContext context) {
    SimCodeScanner.show(
      context,
      onCodeScanned: (code) {
        setState(() {
          _isScanned = true; // On marque comme scanné
        });
        widget.ctrls['newSerial']?.text = code;
        _lookupNumber(code); // Lance la recherche car provient d'un scan
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(theme, l10n.step_new_sim_section_title),
        CardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabelText(l10n.step_new_sim_serial_label),
              const SizedBox(height: 8),
              TextField(
                controller: widget.ctrls['newSerial'],
                focusNode: widget.nodes['newSerial'],
                keyboardType: TextInputType.number,
                cursorColor: theme.colorScheme.primary,
                style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                decoration: inputDec(
                  context: context,
                  hint: l10n.step_new_sim_serial_hint,
                  error: widget.errors['newSerial'],
                  prefixIcon: Icon(
                    Icons.sim_card_outlined,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 20,
                  ),
                  suffixIcon: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        )
                      : IconButton(
                          icon: Icon(
                            Icons.qr_code_scanner_rounded,
                            color: theme.colorScheme.primary,
                          ),
                          onPressed: () => _handleScan(context),
                        ),
                ),
              ),

              // AFFICHAGE : Seulement si _isScanned est vrai
              if (_isScanned && _associatedMsisdn != null) ...[
                const SizedBox(height: 16),
                _buildSuccessBadge(_associatedMsisdn!, theme, l10n),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),
        _buildSectionHeader(theme, l10n.step_new_sim_frequent_section),
        CardContainer(
          child: Column(
            children: [
              _contactField(context, l10n.step_new_sim_frequent_1, 'frequent1', error: widget.errors['frequent1']),
              const SizedBox(height: 12),
              _contactField(context, l10n.step_new_sim_frequent_2, 'frequent2', error: widget.errors['frequent2']),
              const SizedBox(height: 12),
              _contactField(context, l10n.step_new_sim_frequent_3, 'frequent3', error: widget.errors['frequent3']),
            ],
          ),
        ),
      ],
    );
  }

  Widget _contactField(BuildContext context, String label, String key, {String? error}) {
    final theme = Theme.of(context);
    return TextField(
      controller: widget.ctrls[key],
      focusNode: widget.nodes[key],
      keyboardType: TextInputType.phone,
      cursorColor: theme.colorScheme.primary,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneFormatter()],
      style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
      decoration: inputDec(
        context: context,
        hint: label,
        error: error,
        prefixIcon: Icon(
          Icons.phone_android_rounded,
          color: theme.colorScheme.onSurface.withOpacity(0.5),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSuccessBadge(String msisdn, ThemeData theme, AppLocalizations l10n) {
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.step_new_sim_associated,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF1F7A3F),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                msisdn,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}