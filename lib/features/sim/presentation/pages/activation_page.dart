import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/operation_validator.dart';
import '../../../../../core/providers/auth_provider.dart';
import '../../data/repositories/sim_activation_repository.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import '../../../../shared/widgets/step_progress_bar.dart';

import 'widgets/step_sim_details.dart';
import 'widgets/step_customer_info.dart';
import 'widgets/step_id_details.dart';
import 'widgets/step_photo_upload.dart';
import 'widgets/step_validation.dart';

class SimActivationPage extends ConsumerStatefulWidget {
  const SimActivationPage({super.key});

  @override
  ConsumerState<SimActivationPage> createState() => _SimActivationPageState();
}

class _SimActivationPageState extends ConsumerState<SimActivationPage> {
  int _currentStep = 1;
  bool _isSubmitting = false;

  final Map<String, TextEditingController> _ctrls = {
    'msisdn': TextEditingController(), 'serial': TextEditingController(),
    'firstName': TextEditingController(), 'lastName': TextEditingController(),
    'dob': TextEditingController(), 'pob': TextEditingController(),
    'geo': TextEditingController(), 'post': TextEditingController(),
    'email': TextEditingController(), 'job': TextEditingController(),
    'idNature': TextEditingController(), 'idNumber': TextEditingController(),
    'idValidity': TextEditingController(),
  };

  final Map<String, FocusNode> _nodes = {
    'msisdn': FocusNode(), 'serial': FocusNode(),
    'firstName': FocusNode(), 'lastName': FocusNode(),
    'dob': FocusNode(), 'pob': FocusNode(),
    'geo': FocusNode(), 'post': FocusNode(),
    'email': FocusNode(), 'job': FocusNode(),
    'idNature': FocusNode(), 'idNumber': FocusNode(),
    'idValidity': FocusNode(),
  };

  final Map<String, String?> _errors = {};
  bool _isMale = true;
  File? _frontImg;
  File? _backImg;

  @override
  void initState() {
    super.initState();
    // Auto-clear errors
    _ctrls['serial']!.addListener(() {
      if (_errors['serial'] != null) setState(() => _errors['serial'] = null);
    });
    _ctrls['msisdn']!.addListener(() {
      if (_errors['msisdn'] != null) setState(() => _errors['msisdn'] = null);
    });
  }

  @override
  void dispose() {
    _ctrls.forEach((_, v) => v.dispose());
    _nodes.forEach((_, v) => v.dispose());
    super.dispose();
  }

  Future<bool> _validate() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _errors.clear());

    if (_currentStep == 1) {
      if (_ctrls['serial']!.text.isEmpty) {
        setState(() => _errors['serial'] = l10n.sim_error_serial);
        _nodes['serial']!.requestFocus();
        return false;
      }
      if (_ctrls['msisdn']!.text.isEmpty) {
        setState(() => _errors['msisdn'] = l10n.step_sim_error_msisdn_required);
        return false;
      }
    }
    else if (_currentStep == 2) {
      if (_ctrls['lastName']!.text.trim().isEmpty) {
        setState(() => _errors['lastName'] = l10n.sim_error_lastname);
        _nodes['lastName']!.requestFocus();
        return false;
      }
      if (_ctrls['firstName']!.text.trim().isEmpty) {
        setState(() => _errors['firstName'] = l10n.sim_error_firstname);
        _nodes['firstName']!.requestFocus();
        return false;
      }
      if (_ctrls['dob']!.text.trim().isEmpty) {
        setState(() => _errors['dob'] = l10n.sim_error_dob);
        _nodes['dob']!.requestFocus();
        return false;
      }
      if (_ctrls['pob']!.text.trim().isEmpty) {
        setState(() => _errors['pob'] = l10n.sim_error_pob);
        _nodes['pob']!.requestFocus();
        return false;
      }
    }
    else if (_currentStep == 3) {
      if (_ctrls['idNature']!.text.trim().isEmpty) {
        setState(() => _errors['idNature'] = l10n.sim_error_id_nature);
        _nodes['idNature']!.requestFocus();
        return false;
      }
      if (_ctrls['idNumber']!.text.trim().isEmpty) {
        setState(() => _errors['idNumber'] = l10n.sim_error_id_number);
        _nodes['idNumber']!.requestFocus();
        return false;
      }
      if (_ctrls['idValidity']!.text.trim().isEmpty) {
        setState(() => _errors['idValidity'] = l10n.sim_error_id_validity);
        _nodes['idValidity']!.requestFocus();
        return false;
      }
      // Validation de la date minimale (dateJour)
      try {
        final date = DateFormat('dd/MM/yyyy').parse(_ctrls['idValidity']!.text.trim());
        final user = ref.read(authProvider).asData?.value?.userData;
        final minDate = user?.dateJour ?? DateTime.now();
        // On normalise pour comparer uniquement les dates (sans heures)
        final minDateNorm = DateTime(minDate.year, minDate.month, minDate.day);
        
        if (date.isBefore(minDateNorm)) {
           setState(() => _errors['idValidity'] = "Date invalide (min: ${DateFormat('dd/MM/yyyy').format(minDateNorm)})");
           _nodes['idValidity']!.requestFocus();
           return false;
        }
      } catch (_) {}
    }
    else if (_currentStep == 4) {
      if (_frontImg == null) {
        setState(() => _errors['idFront'] = l10n.sim_error_photo_front);
        return false;
      }
      if (_backImg == null) {
        setState(() => _errors['idBack'] = l10n.sim_error_photo_back);
        return false;
      }
    }
    return true;
  }

  Future<void> _onNext() async {
    if (await _validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (_currentStep < 5) {
        setState(() => _currentStep++);
      } else {
        _submitFinal();
      }
    }
  }

  Future<bool> _fetchSimDataManually() async {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary))
    );
    try {
      final repo = ref.read(simActivationRepositoryProvider);
      final serial = _ctrls['serial']!.text.trim();
      final fetchedMsisdn = await repo.fetchMsisdnFromSerial(serial);
      if (!mounted) return false;
      Navigator.pop(context);
      setState(() => _ctrls['msisdn']!.text = fetchedMsisdn);
      return true;
    } catch (e) {
      if (!mounted) return false;
      Navigator.pop(context);
      await showAppMessageDialog(
        context,
        title: l10n.common_error_title,
        message: e.toString().replaceAll('Exception: ', ''),
        type: AppMessageType.error,
      );
      return false;
    }
  }

  void _submitFinal() async {
    final l10n = AppLocalizations.of(context)!;

    final ok = await OperationValidator.validate(
      context,
      ref,
      reason: l10n.sim_act_title,
    );
    if (!ok) return;

    final idFront = _frontImg;
    final idBack = _backImg;
    if (idFront == null || idBack == null) return;

    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(simActivationRepositoryProvider);

      final fields = <String, dynamic>{
        'noms': _ctrls['lastName']!.text.trim(),
        'prenoms': _ctrls['firstName']!.text.trim(),
        'sexe': _isMale,
        'dateNaissance': DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_ctrls['dob']!.text.trim())),
        'lieuNaissance': _ctrls['pob']!.text.trim(),
        'profession': _ctrls['job']!.text.trim(),
        'dateValiditePiece': DateFormat('yyyy-MM-dd').format(DateFormat('dd/MM/yyyy').parse(_ctrls['idValidity']!.text.trim())),
        'numeroPiece': _ctrls['idNumber']!.text.trim(),
        'adressePostale': _ctrls['post']!.text.trim(),
        'numeroTelephoneClient': _ctrls['msisdn']!.text.trim(),
        'mail': _ctrls['email']!.text.trim(),
        'adresseGeographique': _ctrls['geo']!.text.trim(),
        'msisdn': _ctrls['serial']!.text.trim(),
        'idNaturePiece': int.tryParse(_ctrls['idNature']!.text.trim()) ?? 0,
      };

      final resp = await repo.activateSim(fields: fields, idFront: idFront, idBack: idBack);
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      // Met à jour les stats depuis le serveur
      ref.read(authProvider.notifier).refreshUserStats();

      await showAppMessageDialog(
        context,
        title: l10n.sim_msg_success_title,
        message: (resp['message']?.toString().isNotEmpty == true) ? resp['message'].toString() : l10n.sim_msg_success_body,
        type: AppMessageType.success,
        autoDismiss: const Duration(seconds: 2),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      await showAppMessageDialog(
        context,
        title: l10n.common_error_title,
        message: e.toString().replaceAll('Exception: ', ''),
        type: AppMessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final List<String> steps = [
      l10n.sim_step_1, l10n.sim_step_2, l10n.sim_step_3, l10n.sim_step_4, l10n.sim_step_5
    ];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.sim_act_title, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          StepProgressBar(currentStep: _currentStep, steps: steps),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildBody(),
            ),
          ),
          _buildNav(l10n, theme),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 1: return StepSimDetails(
        msisdn: _ctrls['msisdn']!,
        serial: _ctrls['serial']!,
        msisdnFocus: _nodes['msisdn']!,
        serialFocus: _nodes['serial']!,
        msisdnError: _errors['msisdn'],
        serialError: _errors['serial'],
        onFetchMsisdn: _fetchSimDataManually,
      );
      case 2: return StepCustomerInfo(ctrls: _ctrls, nodes: _nodes, errors: _errors, isMale: _isMale, onGenderChanged: (v) => setState(() => _isMale = v));
      case 3: return StepIdDetails(nature: _ctrls['idNature']!, number: _ctrls['idNumber']!, validity: _ctrls['idValidity']!, natureFocus: _nodes['idNature']!, numberFocus: _nodes['idNumber']!, validityFocus: _nodes['idValidity']!, natureError: _errors['idNature'], numberError: _errors['idNumber'], validityError: _errors['idValidity']);
      case 4: return StepPhotoUpload(frontImage: _frontImg, backImage: _backImg, frontError: _errors['idFront'], backError: _errors['idBack'], onPhotoCaptured: (file, isFront) { setState(() { if (isFront) { _frontImg = file; _errors['idFront'] = null; } else { _backImg = file; _errors['idBack'] = null; } }); });
      case 5: return StepValidation(ctrls: _ctrls, isMale: _isMale, frontImg: _frontImg, backImg: _backImg);
      default: return const SizedBox();
    }
  }

  Widget _buildNav(var l10n, ThemeData theme) {
    const double btnHeight = 48;
    final BorderRadius borderRadius = BorderRadius.circular(24);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _isSubmitting ? null : () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  minimumSize: const Size.fromHeight(btnHeight),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                ),
                child: Text(
                  l10n.sim_btn_prev,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                ),
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(btnHeight),
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                backgroundColor: AppColors.primary,
                elevation: 0, // optionnel: plus plat comme Outlined
              ),
              child: _isSubmitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                _currentStep == 5 ? l10n.sim_btn_submit : l10n.sim_btn_next,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}