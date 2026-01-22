import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../l10n/gen/app_localizations.dart';

import '../../../../../core/services/operation_validator.dart';

import '../../../../shared/widgets/app_message_dialog.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import 'widgets/step_search_sim.dart';
import 'widgets/step_check_client.dart';
import 'widgets/step_new_sim_details.dart';

class SimReactivationPage extends ConsumerStatefulWidget {
  const SimReactivationPage({super.key});

  @override
  ConsumerState<SimReactivationPage> createState() => _SimReactivationPageState();
}

class _SimReactivationPageState extends ConsumerState<SimReactivationPage> {
  int _currentStep = 1;

  final Map<String, TextEditingController> _ctrls = {
    'msisdnSearch': TextEditingController(),
    'msisdn': TextEditingController(),
    'reason': TextEditingController(),
    'newSerial': TextEditingController(),
    'frequent1': TextEditingController(),
    'frequent2': TextEditingController(),
    'frequent3': TextEditingController(),
  };

  final Map<String, FocusNode> _nodes = {
    'msisdnSearch': FocusNode(),
    'reason': FocusNode(),
    'newSerial': FocusNode(),
    'frequent1': FocusNode(),
    'frequent2': FocusNode(),
    'frequent3': FocusNode(),
  };

  final Map<String, String?> _errors = {};
  Map<String, dynamic>? _clientData;

  @override
  void initState() {
    super.initState();
    // Écouteur pour réinitialiser l'identification si le numéro de recherche change
    _ctrls['msisdnSearch']!.addListener(() {
      if (_clientData != null && _ctrls['msisdnSearch']!.text != _clientData!['msisdn']) {
        setState(() {
          _clientData = null;
          _ctrls['msisdn']!.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrls.forEach((_, c) => c.dispose());
    _nodes.forEach((_, n) => n.dispose());
    super.dispose();
  }

  void _closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _goToStep(int step) {
    _closeKeyboard(); // avant le setState

    setState(() => _currentStep = step);

    // après rebuild : évite le focus résiduel qui fait "bounce"
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _closeKeyboard();
    });
  }

  // --- LOGIQUE DE RECHERCHE ---
  Future<bool> _handleUserLookup(String phone) async {
    if (phone.isEmpty) return false;

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 1500));

      if (phone.endsWith("000")) throw Exception("Introuvable");

      setState(() {
        _clientData = {
          'msisdn': phone,
          'serial': '8922410123456789012',
          'status': 'Suspendue (Perte)',
          'nom': 'DJINE',
          'prenom': 'SINTO PAFING',
          'dob': '22/05/2005',
          'pob': 'Conakry',
          'gender': 'Homme',
          'job': 'Etudiant',
          'geo': 'Kipé, Rue KI-142, Conakry',
          'post': 'BP 1024 Conakry',
          'email': 'djine.pafing@gmail.com',
          'idNature': 'CIN',
          'idNumber': 'GN-12345678-22',
          'idValidity': '14/11/2028',
        };
        _ctrls['msisdn']?.text = _clientData?['msisdn'] ?? "";
      });

      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      return true;
    } catch (e) {
      if (mounted) Navigator.of(context, rootNavigator: true).pop();
      _ctrls['msisdn']?.clear();
      _closeKeyboard();
      _showError(l10n.sim_react_error_user_not_found);
      return false;
    }
  }

  bool _isInvalidFormat(String input) {
    final clean = input.replaceAll(' ', '');
    return clean.isNotEmpty && (clean.length < 9 || !clean.startsWith('6'));
  }

  void _onNext() async {
    setState(() => _errors.clear());

    final l10n = AppLocalizations.of(context)!;

    if (_currentStep == 1) {
      final phoneInput = _ctrls['msisdnSearch']?.text.trim() ?? "";
      final cleanPhone = phoneInput.replaceAll(' ', '');

      if (cleanPhone.isEmpty) {
        setState(() => _errors['msisdnSearch'] = l10n.sim_react_error_phone_required);
        return;
      }

      if (_isInvalidFormat(phoneInput)) {
        setState(() => _errors['msisdnSearch'] = l10n.auth_error_invalid_phone);
        _nodes['msisdnSearch']?.requestFocus();
        return;
      }

      // RECHERCHE AUTOMATIQUE SI NON IDENTIFIÉ
      final verifiedMsisdn = _ctrls['msisdn']?.text.replaceAll(' ', '') ?? "";
      if (verifiedMsisdn != cleanPhone) {
        bool success = await _handleUserLookup(cleanPhone);
        if (!success) return;
      }

      if (_ctrls['reason']?.text.isEmpty ?? true) {
        setState(() => _errors['reason'] = l10n.sim_react_error_reason_required);
        _nodes['reason']?.requestFocus();
        return;
      }
      _goToStep(2);
    } else if (_currentStep == 2) {
      _goToStep(3);
    } else {
      _finalValidation();
    }
  }

  void _finalValidation() {
    final l10n = AppLocalizations.of(context)!;
    bool hasError = false;

    final f1 = _ctrls['frequent1']!.text.trim();
    final f2 = _ctrls['frequent2']!.text.trim();
    final f3 = _ctrls['frequent3']!.text.trim();

    // Validation ICCID
    if (_ctrls['newSerial']?.text.isEmpty ?? true) {
      _errors['newSerial'] = l10n.sim_react_error_new_iccid_required;
      hasError = true;
    }

    // Validation Numéro 1 (Obligatoire)
    if (f1.isEmpty) {
      _errors['frequent1'] = l10n.sim_react_error_frequent1_required;
      hasError = true;
    } else if (_isInvalidFormat(f1)) {
      _errors['frequent1'] = l10n.auth_error_invalid_phone;
      hasError = true;
    }

    // Validation Numéros Optionnels
    if (f2.isNotEmpty && _isInvalidFormat(f2)) {
      _errors['frequent2'] = l10n.auth_error_invalid_phone;
      hasError = true;
    }
    if (f3.isNotEmpty && _isInvalidFormat(f3)) {
      _errors['frequent3'] = l10n.auth_error_invalid_phone;
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      // Focus sur le premier champ en erreur
      if (_errors['newSerial'] != null) {
        _nodes['newSerial']?.requestFocus();
      } else if (_errors['frequent1'] != null) {
        _nodes['frequent1']?.requestFocus();
      } else if (_errors['frequent2'] != null) {
        _nodes['frequent2']?.requestFocus();
      } else if (_errors['frequent3'] != null) {
        _nodes['frequent3']?.requestFocus();
      }
      return;
    }

    _submit();
  }

  void _submit() async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final ok = await OperationValidator.validate(
      context,
      ref,
      reason: l10n.sim_react_title,
    );
    if (!ok) return;

    _closeKeyboard();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
    );

    // Simulation de traitement
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) Navigator.of(context, rootNavigator: true).pop(); // Ferme le loader

    // Affichage du message de succès avant de quitter
    await showAppMessageDialog(
        context,
        title: l10n.sim_react_success_title,
        message: l10n.sim_react_success_body,
        type: AppMessageType.success,
        autoDismiss: const Duration(seconds: 2),
    );
    Navigator.pop(context);
  }

  void _showError(String msg) {
    final l10n = AppLocalizations.of(context)!;
    showAppMessageDialog(context, title: l10n.sim_react_error_title, message: msg, type: AppMessageType.error);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final steps = [l10n.sim_react_step_1, l10n.sim_react_step_2, l10n.sim_react_step_3];
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.sim_react_title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          StepProgressBar(currentStep: _currentStep, steps: steps),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: _buildStepView())),
          _buildNav(),
        ],
      ),
    );
  }

  Widget _buildStepView() {
    switch (_currentStep) {
      case 1:
        return StepSearchSim(ctrls: _ctrls, nodes: _nodes, errors: _errors);
      case 2:
        if (_clientData == null) {
          final theme = Theme.of(context);
          return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
        }
        return StepCheckClient(data: _clientData!);
      case 3:
        return StepNewSimDetails(ctrls: _ctrls, nodes: _nodes, errors: _errors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildNav() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    const double btnHeight = 48;
    final BorderRadius borderRadius = BorderRadius.circular(24);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(child: OutlinedButton(
                onPressed: () => _goToStep(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  minimumSize: const Size.fromHeight(btnHeight),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                ),
                child: Text(l10n.sim_btn_prev, style: TextStyle(color: theme.colorScheme.onSurface))
            )),
          if (_currentStep > 1) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(btnHeight),
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                backgroundColor: theme.colorScheme.primary,
                elevation: 0,
              ),
              child: Text(
                _currentStep == 3 ? l10n.sim_btn_submit : l10n.sim_btn_next,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}