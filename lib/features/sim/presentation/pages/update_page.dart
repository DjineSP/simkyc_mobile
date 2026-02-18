import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';

import '../../../../../l10n/gen/app_localizations.dart';

import '../../../../../core/services/operation_validator.dart';
import '../../../../../core/providers/auth_provider.dart';


import '../../../../shared/widgets/app_message_dialog.dart';
import '../../../../shared/widgets/step_progress_bar.dart';
import '../../data/repositories/sim_update_repository.dart';
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
  int? _idActivationSim;
  File? _frontImg;
  File? _backImg;

  List<int>? _tryDecodeBytes(dynamic raw) {
    if (raw == null) return null;

    if (raw is List<int>) return raw;
    if (raw is List) {
      try {
        return raw.map((e) => e as int).toList();
      } catch (_) {
        return null;
      }
    }

    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty) return null;

      final base64Part = s.contains(',') ? s.split(',').last.trim() : s;
      try {
        return base64Decode(base64Part);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  Future<File?> _writeTempImage(List<int> bytes, {required String prefix}) async {
    final dir = Directory.systemTemp;
    final file = File('${dir.path}${Platform.pathSeparator}${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

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
    // 2. Localisation & Compléments
    // if (_ctrls['geo']!.text.trim().isEmpty) {
    //   return _applyError('geo', l10n.sim_update_error_geo_required);
    // }

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
    // Validation date minimale (dateJour)
    try {
        final date = DateFormat('dd/MM/yyyy').parse(_ctrls['idValidity']!.text.trim());
        final user = ref.read(authProvider).asData?.value?.userData;
        final minDate = user?.dateJour ?? DateTime.now();
        // On normalise
        final minDateNorm = DateTime(minDate.year, minDate.month, minDate.day);
        
        if (date.isBefore(minDateNorm)) {
           return _applyError('idValidity', "Date invalide (min: ${DateFormat('dd/MM/yyyy').format(minDateNorm)})");
        }
    } catch (_) {}

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
      final repo = ref.read(simUpdateRepositoryProvider);
      final data = await repo.fetchActivationByPhone(phone.replaceAll(' ', ''));

      if (!mounted) return;

      final frontRaw = data['idFront'] ?? data['idFrontImage'] ?? data['photoRecto'] ?? data['recto'] ?? data['front'];
      final backRaw = data['idBack'] ?? data['idBackImage'] ?? data['photoVerso'] ?? data['verso'] ?? data['back'];

      final frontBytes = _tryDecodeBytes(frontRaw);
      final backBytes = _tryDecodeBytes(backRaw);

      final frontFile = frontBytes == null ? null : await _writeTempImage(frontBytes, prefix: 'id_front');
      final backFile = backBytes == null ? null : await _writeTempImage(backBytes, prefix: 'id_back');

      if (!mounted) return;

      setState(() {
        final idSim = data['idActivationSim'] ?? data['iD_Activation_Sim'];
        if (idSim is int) {
          _idActivationSim = idSim;
        } else if (idSim is String) {
          _idActivationSim = int.tryParse(idSim);
        } else {
          _idActivationSim = 0;
        }
        _ctrls['firstName']!.text = (data['prenom'] ?? data['firstName'] ?? '').toString();
        _ctrls['lastName']!.text = (data['nom'] ?? data['lastName'] ?? '').toString();
        _ctrls['dob']!.text = (data['dateNaissance'] ?? data['dob'] ?? '').toString();
        _ctrls['pob']!.text = (data['lieuNaissance'] ?? data['pob'] ?? '').toString();
        final gender = data['sexe'] ?? data['gender'];
        if (gender is bool) {
          _ctrls['gender']!.text = gender ? 'Homme' : 'Femme';
        } else {
          _ctrls['gender']!.text = (gender ?? 'Homme').toString();
        }
        _ctrls['job']!.text = (data['profession'] ?? data['job'] ?? '').toString();
        _ctrls['geo']!.text = (data['adresseGeo'] ?? data['geo'] ?? '').toString();
        _ctrls['post']!.text = (data['adressePostale'] ?? data['post'] ?? '').toString();
        _ctrls['email']!.text = (data['mail'] ?? data['email'] ?? '').toString();
        _ctrls['idNature']!.text = (data['idNaturePiece'] ?? data['idNature'] ?? '').toString();
        _ctrls['idNumber']!.text = (data['numeroPiece'] ?? data['idNumber'] ?? '').toString();
        _ctrls['idValidity']!.text = (data['dateValiditePiece'] ?? data['idValidity'] ?? '').toString();

        if (frontFile != null) {
          _frontImg = frontFile;
        }
        if (backFile != null) {
          _backImg = backFile;
        }
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
          message: e.toString().replaceAll('Exception: ', ''),
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
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white, // AppColors.darkSurface hardcoded or import if available
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n.step_photo_source_title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
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
        );
      },
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

    try {
      final front = _frontImg;
      final back = _backImg;
      if (front == null || back == null) {
        throw Exception(l10n.sim_error_photo_front);
      }

      final repo = ref.read(simUpdateRepositoryProvider);

      final fields = <String, dynamic>{
        'msisdn': _ctrls['msisdnSearch']!.text.trim(),
        'nom': _ctrls['lastName']!.text.trim(),
        'prenom': _ctrls['firstName']!.text.trim(),
        'sexe': _ctrls['gender']!.text == 'Homme' || _ctrls['gender']!.text == 'Male',
        'dateNaissance': _ctrls['dob']!.text.trim(),
        'lieuNaissance': _ctrls['pob']!.text.trim(),
        'profession': _ctrls['job']!.text.trim().isEmpty ? null : _ctrls['job']!.text.trim(),
        'dateValiditePiece': _ctrls['idValidity']!.text.trim(),
        'numeroPiece': _ctrls['idNumber']!.text.trim(),
        'adressePostale': _ctrls['post']!.text.trim().isEmpty ? null : _ctrls['post']!.text.trim(),
        'telephone': _ctrls['msisdnSearch']!.text.trim(),
        'mail': _ctrls['email']!.text.trim().isEmpty ? null : _ctrls['email']!.text.trim(),
        'adresseGeo': _ctrls['geo']!.text.trim(),
        'idNaturePiece': int.tryParse(_ctrls['idNature']!.text.trim()) ?? 0,
      };

      final resp = await repo.updateClient(
        idActivationSim: _idActivationSim ?? 0,
        fields: fields,
        idFront: front,
        idBack: back,
      );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop(); // ferme loader
      setState(() => _isLoading = false);

      // Met à jour les stats depuis le serveur
      ref.read(authProvider.notifier).refreshUserStats();

      await showAppMessageDialog(
        context,
        title: l10n.sim_update_success_title,
        message: (resp['message']?.toString().isNotEmpty == true) ? resp['message'].toString() : l10n.sim_update_success_body,
        type: AppMessageType.success,
        autoDismiss: const Duration(seconds: 2),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _isLoading = false);
      await showAppMessageDialog(
        context,
        title: l10n.sim_update_error_title,
        message: e.toString().replaceAll('Exception: ', ''),
        type: AppMessageType.error,
      );
    }
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
                  side: BorderSide(color: theme.dividerColor, width: 1),
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
