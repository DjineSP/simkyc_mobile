import 'package:flutter/material.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
import 'dart:io';
import '../../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import '../../../../shared/widgets/step_progress_bar.dart';

import 'widgets/step_sim_details.dart';
import 'widgets/step_customer_info.dart';
import 'widgets/step_id_details.dart';
import 'widgets/step_photo_upload.dart';
import 'widgets/step_validation.dart';

class SimActivationPage extends StatefulWidget {
  const SimActivationPage({super.key});

  @override
  State<SimActivationPage> createState() => _SimActivationPageState();
}

class _SimActivationPageState extends State<SimActivationPage> {
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
      if (_ctrls['msisdn']!.text.isEmpty) return await _fetchSimDataManually();
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
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary))
    );
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.pop(context);
      setState(() => _ctrls['msisdn']!.text = "690000000");
      return true;
    }
    return false;
  }

  void _submitFinal() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    await showAppMessageDialog(
      context,
      title: l10n.sim_msg_success_title,
      message: l10n.sim_msg_success_body,
      type: AppMessageType.success,
      autoDismiss: const Duration(seconds: 2),
    );
    Navigator.pop(context);
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
      case 1: return StepSimDetails(msisdn: _ctrls['msisdn']!, serial: _ctrls['serial']!, msisdnFocus: _nodes['msisdn']!, serialFocus: _nodes['serial']!, msisdnError: _errors['msisdn'], serialError: _errors['serial']);
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
                  minimumSize: const Size.fromHeight(btnHeight),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                  side: BorderSide(color: theme.dividerColor),
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