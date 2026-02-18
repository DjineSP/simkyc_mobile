import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../../l10n/gen/app_localizations.dart';
import '../../../../../core/constants/app_colors.dart';
import '../components/activation_helpers.dart';

class StepPhotoUpload extends StatefulWidget {
  final File? frontImage;
  final File? backImage;
  final Function(File? file, bool isFront) onPhotoCaptured;

  // Nouveaux paramètres pour gérer les erreurs comme les autres sections
  final String? frontError;
  final String? backError;

  const StepPhotoUpload({
    super.key,
    this.frontImage,
    this.backImage,
    required this.onPhotoCaptured,
    this.frontError,
    this.backError,
  });

  @override
  State<StepPhotoUpload> createState() => _StepPhotoUploadState();
}

class _StepPhotoUploadState extends State<StepPhotoUpload> {
  final ImagePicker _picker = ImagePicker();

  void _showSourcePicker(BuildContext context, bool isFront) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
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
                    onTap: () {
                      Navigator.pop(context);
                      _processAction(ImageSource.camera, isFront);
                    },
                  ),
                  _SourceOption(
                    icon: Icons.photo_library_rounded,
                    label: l10n.step_photo_source_gallery,
                    onTap: () {
                      Navigator.pop(context);
                      _processAction(ImageSource.gallery, isFront);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processAction(ImageSource source, bool isFront) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source, imageQuality: 80);
      if (photo == null) return;

      if (!mounted) return;
      final theme = Theme.of(context);
      final l10n = AppLocalizations.of(context)!;
      final primary = theme.colorScheme.primary;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: photo.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: l10n.step_photo_crop_title,
            toolbarColor: primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: primary,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: l10n.step_photo_crop_title, aspectRatioLockEnabled: false),
        ],
      );

      if (croppedFile != null) {
        widget.onPhotoCaptured(File(croppedFile.path), isFront);
      }
    } catch (e) {
      debugPrint("Erreur Photo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelText(l10n.step_photo_docs_label),
        const SizedBox(height: 16),

        // RECTO
        _UploadBox(
          title: l10n.step_photo_front_title,
          subtitle: widget.frontImage != null
              ? l10n.step_photo_subtitle_edit
              : l10n.step_photo_subtitle_capture,
          icon: widget.frontImage != null ? Icons.check_circle : Icons.upload_rounded,
          imageFile: widget.frontImage,
          errorText: widget.frontError, // Passage de l'erreur
          onTap: () => _showSourcePicker(context, true),
        ),

        const SizedBox(height: 20),

        // VERSO
        _UploadBox(
          title: l10n.step_photo_back_title,
          subtitle: widget.backImage != null
              ? l10n.step_photo_subtitle_edit
              : l10n.step_photo_subtitle_capture,
          icon: widget.backImage != null ? Icons.check_circle : Icons.upload_rounded,
          imageFile: widget.backImage,
          errorText: widget.backError, // Passage de l'erreur
          onTap: () => _showSourcePicker(context, false),
        ),

        const SizedBox(height: 24),
        _InfoNote(),
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final File? imageFile;
  final String? errorText;
  final VoidCallback onTap;

  const _UploadBox({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageFile,
    this.errorText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isUploaded = imageFile != null;
    final bool hasError = errorText != null;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = hasError
        ? theme.colorScheme.error
        : (isUploaded ? Colors.green.withOpacity(0.5) : theme.colorScheme.outline.withOpacity(0.35));
    final bgColor = isDark ? theme.colorScheme.surface : const Color(0xFFF8FAFC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                // Si erreur -> Rouge, Si Uploadé -> Vert, Sinon -> Gris Border
                color: borderColor,
                width: (isUploaded || hasError) ? 1.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageFile != null) Image.file(imageFile!, fit: BoxFit.cover),
                  if (imageFile != null)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary,
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ),
                    )
                  else
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, color: hasError ? theme.colorScheme.error : theme.colorScheme.onSurface.withOpacity(0.35), size: 30),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: hasError ? theme.colorScheme.error : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: hasError
                                ? theme.colorScheme.error.withOpacity(0.7)
                                : theme.colorScheme.onSurface.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  if (isUploaded)
                    const Positioned(top: 10, right: 10, child: Icon(Icons.check_circle, color: Colors.green, size: 22)),
                ],
              ),
            ),
          ),
        ),
        // Affichage du message d'erreur sous la box si besoin
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: TextStyle(color: theme.colorScheme.error, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({required this.icon, required this.label, required this.onTap});

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
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.step_photo_info_note,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}