import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../../l10n/gen/app_localizations.dart';

import '../../../../../core/services/operation_validator.dart';


import '../../../../shared/widgets/app_message_dialog.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import 'widgets/step_search_update.dart';
import 'widgets/step_edit_client.dart';
import 'widgets/step_update_summary.dart';

class SimUpdatePage extends ConsumerStatefulWidget {
  const SimUpdatePage({super.key});

  @override
  ConsumerState<SimUpdatePage> createState() => _SimUpdatePageState();
}

class _SimUpdatePageState extends ConsumerState<SimUpdatePage> {
  int _currentStep = 1;
  bool _isLoading = false;

  final Map<String, TextEditingController> _ctrls = {
    'msisdnSearch': TextEditingController(),
    'firstName': TextEditingController(),
    'lastName': TextEditingController(),
    'dob': TextEditingController(),
    'pob': TextEditingController(),
    'gender': TextEditingController(text: 'Homme'),
    'job': TextEditingController(),
    'geo': TextEditingController(),
    'post': TextEditingController(),
    'email': TextEditingController(),
    'idNature': TextEditingController(),
    'idNumber': TextEditingController(),
    'idValidity': TextEditingController(),
  };

  final Map<String, FocusNode> _nodes = {
    'msisdnSearch': FocusNode(),
    'firstName': FocusNode(),
    'lastName': FocusNode(),
    'dob': FocusNode(),
    'pob': FocusNode(),
    'job': FocusNode(),
    'geo': FocusNode(),
    'idNumber': FocusNode(),
    'idValidity': FocusNode(),
  };

  final Map<String, String?> _errors = {};
  File? _frontImg;
  File? _backImg;

  @override
  void dispose() {
    _ctrls.forEach((_, c) => c.dispose());
    _nodes.forEach((_, n) => n.dispose());
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  //  Anti "keyboard bounce" helpers
  // ---------------------------------------------------------------------------

  void _closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _goToStep(int step) {
    // Ferme le clavier AVANT
    _closeKeyboard();

    // Change l'étape
    setState(() => _currentStep = step);

    // Ferme le clavier APRÈS rebuild (anti focus résiduel)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _closeKeyboard();
    });
  }

  // ---------------------------------------------------------------------------
  //  Navigation & Validation
  // ---------------------------------------------------------------------------

  void _onNext() {
    setState(() => _errors.clear());

    if (_currentStep == 1) {
      _validateStep1();
    } else if (_currentStep == 2) {
      _validateStep2();
    } else {
      _submitFinalUpdate();
    }
  }

  void _validateStep1() {
    final l10n = AppLocalizations.of(context)!;
    final phone = _ctrls['msisdnSearch']!.text.replaceAll(' ', '');
    if (phone.isEmpty) {
      _applyError('msisdnSearch', l10n.sim_update_error_phone_required);
    } else if (phone.length < 9 || !phone.startsWith('6')) {
      _applyError('msisdnSearch', l10n.auth_error_invalid_phone);
    } else {
      _handleSearch(_ctrls['msisdnSearch']!.text);
    }
  }

  void _validateStep2() {
    final l10n = AppLocalizations.of(context)!;
    // 1. Informations Identitaires
    if (_ctrls['lastName']!.text.trim().isEmpty) {
      return _applyError('lastName', l10n.sim_error_lastname);
    }
    if (_ctrls['firstName']!.text.trim().isEmpty) {
      return _applyError('firstName', l10n.sim_error_firstname);
    }
    if (_ctrls['dob']!.text.trim().isEmpty) {
      return _applyError('dob', l10n.sim_error_dob);
    }
    if (_ctrls['pob']!.text.trim().isEmpty) {
      return _applyError('pob', l10n.sim_error_pob);
    }

    // 2. Localisation & Compléments
    if (_ctrls['geo']!.text.trim().isEmpty) {
      return _applyError('geo', l10n.sim_update_error_geo_required);
    }

    // 3. Document d'identification
    if (_ctrls['idNature']!.text.trim().isEmpty) {
      // NOTE: idNature n'est pas dans _nodes => pas de focus auto, mais erreur OK.
      // Si tu veux focus, ajoute 'idNature': FocusNode() dans _nodes et passe-le au widget.
      return _applyError('idNature', l10n.sim_error_id_nature);
    }
    if (_ctrls['idNumber']!.text.trim().isEmpty) {
      return _applyError('idNumber', l10n.sim_error_id_number);
    }
    if (_ctrls['idValidity']!.text.trim().isEmpty) {
      return _applyError('idValidity', l10n.sim_error_id_validity);
    }

    // 4. Photos
    if (_frontImg == null) {
      // NOTE: idFront/idBack ne sont pas dans _nodes => pas de focus, c'est normal.
      return _applyError('idFront', l10n.sim_error_photo_front);
    }
    if (_backImg == null) {
      return _applyError('idBack', l10n.sim_error_photo_back);
    }

    // Si tout est OK
    _goToStep(3);
  }

  // ---------------------------------------------------------------------------
  //  Validation helpers
  // ---------------------------------------------------------------------------

  void _applyError(String key, String message) {
    setState(() => _errors[key] = message);

    // Focus seulement si un FocusNode existe
    if (_nodes.containsKey(key)) {
      FocusScope.of(context).requestFocus(_nodes[key]);
    }
  }

  // ---------------------------------------------------------------------------
  //  API & Photos
  // ---------------------------------------------------------------------------

  Future<void> _handleSearch(String phone) async {
    // Très important pour éviter keyboard bounce + dialog
    _closeKeyboard();

    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;

      setState(() {
        _ctrls['firstName']!.text = "Jean Paul";
        _ctrls['lastName']!.text = "KAMDEM";
        _ctrls['dob']!.text = "15/03/1990";
        _ctrls['pob']!.text = "Conakry";
        _ctrls['gender']!.text = "Homme";
        _ctrls['job']!.text = "Ingénieur";
        _ctrls['geo']!.text = "Kaloum, Conakry";
        _ctrls['idNature']!.text = "CNI";
        _ctrls['idNumber']!.text = "123456789";
        _ctrls['idValidity']!.text = "20/12/2028";
      });

      // Ferme le loader d'abord
      Navigator.of(context, rootNavigator: true).pop();

      // Puis change d'étape proprement (anti-bounce)
      _goToStep(2);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Navigator.of(context, rootNavigator: true).pop();
        showAppMessageDialog(
          context,
          title: l10n.sim_update_error_title,
          message: l10n.sim_update_error_subscriber_not_found,
          type: AppMessageType.error,
        );
      }
    }
  }

  void _handlePhotoAction(bool isFront) async {
    _closeKeyboard();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final ImagePicker picker = ImagePicker();
    final source = await _showSourceDialog();
    if (source == null) return;

    final XFile? pickedFile =
    await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: l10n.step_photo_crop_title,
          toolbarColor: theme.colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true,
          aspectRatioPresets: const [CropAspectRatioPreset.ratio16x9],
        ),
        IOSUiSettings(
          title: l10n.step_photo_crop_title,
          aspectRatioPresets: const [CropAspectRatioPreset.ratio16x9],
        ),
      ],
    );

    if (!mounted) return;

    if (croppedFile != null) {
      setState(() {
        if (isFront) {
          _frontImg = File(croppedFile.path);
        } else {
          _backImg = File(croppedFile.path);
        }
      });
    }
  }

  Future<ImageSource?> _showSourceDialog() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.step_photo_source_title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: l10n.step_photo_source_camera,
                    onTap: () =>
                        Navigator.pop(context, ImageSource.camera),
                  ),
                  _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: l10n.step_photo_source_gallery,
                    onTap: () =>
                        Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitFinalUpdate() async {
    // Anti-bounce + éviter que le clavier soit visible sous le loader
    _closeKeyboard();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final ok = await OperationValidator.validate(
      context,
      ref,
      reason: '${l10n.home_action_update} - ${l10n.sim_update_btn_confirm}',
    );
    if (!ok) return;

    setState(() => _isLoading = true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: theme.colorScheme.primary),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    Navigator.of(context, rootNavigator: true).pop(); // ferme loader

    setState(() => _isLoading = false);

    await showAppMessageDialog(
      context,
      title: l10n.sim_update_success_title,
      message: l10n.sim_update_success_body,
      type: AppMessageType.success,
      autoDismiss: const Duration(seconds: 2),
    );

    if (mounted) Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  //  UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final steps = [l10n.sim_update_step_1, l10n.sim_update_step_2, l10n.sim_update_step_3];
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          l10n.home_action_update,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          StepProgressBar(currentStep: _currentStep, steps: steps),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildStepView(),
            ),
          ),
          _buildNav(),
        ],
      ),
    );
  }

  Widget _buildStepView() {
    switch (_currentStep) {
      case 1:
        return StepSearchUpdate(ctrls: _ctrls, nodes: _nodes, errors: _errors);
      case 2:
        return StepEditClient(
          ctrls: _ctrls,
          nodes: _nodes,
          errors: _errors,
          frontImg: _frontImg,
          backImg: _backImg,
          onPhotoUpdate: (file, isFront) => _handlePhotoAction(isFront),
        );
      case 3:
        return StepUpdateSummary(
          ctrls: _ctrls,
          frontImg: _frontImg,
          backImg: _backImg,
        );
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 1)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : () => _goToStep(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: theme.dividerColor),
                  minimumSize: const Size.fromHeight(btnHeight),
                  shape: RoundedRectangleBorder(borderRadius: borderRadius),
                ),
                child: Text(l10n.sim_btn_prev, style: TextStyle(color: theme.colorScheme.onSurface)),
              ),
            ),
          if (_currentStep > 1) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onNext,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(btnHeight),
                shape: RoundedRectangleBorder(borderRadius: borderRadius),
                backgroundColor: theme.colorScheme.primary,
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                _currentStep == 1
                    ? l10n.sim_update_btn_search
                    : (_currentStep == 3 ? l10n.sim_update_btn_confirm : l10n.sim_btn_next),
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

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: theme.colorScheme.surface,
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: theme.colorScheme.onSurface,
            ),
          )
        ],
      ),
    );
  }
}
