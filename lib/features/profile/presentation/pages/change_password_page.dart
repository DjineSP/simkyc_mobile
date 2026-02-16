import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import '../../../../features/auth/data/repositories/auth_repository.dart';

class ChangePasswordPage extends ConsumerStatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  ConsumerState<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends ConsumerState<ChangePasswordPage> {
  final _oldPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  
  // Focus nodes for keyboard navigation
  final _oldPassFocus = FocusNode();
  final _newPassFocus = FocusNode();
  final _confirmPassFocus = FocusNode();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isVerified = false; // Step 1 completed?

  @override
  void dispose() {
    _oldPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    _oldPassFocus.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  Future<void> _verifyOldPassword() async {
    _oldPassFocus.unfocus(); // Dismiss keyboard
    final oldPass = _oldPassCtrl.text.trim();
    if (oldPass.isEmpty) {
      await showAppMessageDialog(
        context,
        title: 'Erreur',
        message: 'Veuillez entrer votre mot de passe actuel',
        type: AppMessageType.error,
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final user = ref.read(authProvider).asData?.value;
    final login = user?.userData?.username ?? '';

    final repo = ref.read(authRepositoryProvider);
    final isValid = await repo.verifyPassword(login, oldPass);

    setState(() => _isLoading = false);

    if (isValid) {
      setState(() {
        _isVerified = true;
      });
      // Request focus on next field after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _newPassFocus.requestFocus();
      });
    } else {
       if (!mounted) return;
        await showAppMessageDialog(
          context,
          title: 'Erreur',
          message: 'Mot de passe actuel incorrect',
          type: AppMessageType.error,
        );
    }
  }

  Future<void> _verifyWithBiometrics() async {
    _oldPassFocus.unfocus();
    final available = await BiometricAuthService.instance.isDeviceSupported();
    if (!available) {
       if (!mounted) return;
       await showAppMessageDialog(
          context,
          title: 'Erreur',
          message: 'Biométrie non disponible sur cet appareil',
          type: AppMessageType.error,
        );
       return;
    }

    final authenticated = await BiometricAuthService.instance.authenticate(
      reason: 'Vérification pour changement de mot de passe',
    );

    if (authenticated) {
      setState(() {
        _isVerified = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
         _newPassFocus.requestFocus();
      });
    }
  }
  
  Future<void> _updatePassword() async {
    _newPassFocus.unfocus();
    _confirmPassFocus.unfocus();
    final newPass = _newPassCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
       await showAppMessageDialog(
        context,
        title: 'Erreur',
        message: 'Veuillez remplir tous les champs',
        type: AppMessageType.error,
      );
      return;
    }

    if (newPass != confirmPass) {
       await showAppMessageDialog(
          context,
          title: 'Erreur',
          message: 'Les mots de passe ne correspondent pas',
          type: AppMessageType.error,
        );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).updatePassword(newPass);
      if (!mounted) return;
      
      Navigator.pop(context); // Go back to profile
      
      await showAppMessageDialog(
        context,
        title: 'Succès',
        message: 'Mot de passe mis à jour avec succès',
        type: AppMessageType.success,
      );

    } catch (e) {
      if (!mounted) return;
      await showAppMessageDialog(
        context,
        title: 'Erreur',
        message: e.toString().replaceAll('Exception: ', ''),
        type: AppMessageType.error,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Changer le mot de passe'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isVerified ? 'Entrez votre nouveau mot de passe' : 'Entrez votre mot de passe actuel',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 20),
                    if (!_isVerified) ...[
                      _label('Mot de passe actuel', theme),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _oldPassCtrl,
                        focusNode: _oldPassFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _verifyOldPassword(),
                        obscureText: _obscureOld,
                        autofillHints: const [AutofillHints.password],
                        style: TextStyle(color: scheme.onSurface),
                        decoration: _inputStyle(
                          theme: theme,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          onIconTap: () => setState(() => _obscureOld = !_obscureOld),
                          isPassword: true,
                          obscure: _obscureOld,
                        ),
                      ),
                    ] else ...[                
                      _label('Nouveau mot de passe', theme),
                      const SizedBox(height: 8),
                       TextField(
                        controller: _newPassCtrl,
                        focusNode: _newPassFocus,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _confirmPassFocus.requestFocus(),
                        obscureText: _obscureNew,
                        autofillHints: const [AutofillHints.newPassword],
                        style: TextStyle(color: scheme.onSurface),
                        decoration: _inputStyle(
                          theme: theme,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          onIconTap: () => setState(() => _obscureNew = !_obscureNew),
                          isPassword: true,
                          obscure: _obscureNew,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _label('Confirmer le mot de passe', theme),
                      const SizedBox(height: 8),
                       TextField(
                        controller: _confirmPassCtrl,
                        focusNode: _confirmPassFocus,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _updatePassword(),
                        obscureText: _obscureConfirm,
                        autofillHints: const [AutofillHints.newPassword],
                        style: TextStyle(color: scheme.onSurface),
                        decoration: _inputStyle(
                          theme: theme,
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          onIconTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          isPassword: true,
                          obscure: _obscureConfirm,
                        ),
                      ),
                    ],
                    if (_isLoading) ...[
                       const SizedBox(height: 16),
                       const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isVerified
                  ? ElevatedButton(
                      onPressed: _isLoading ? null : _updatePassword,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Mettre à jour'),
                    )
                  : Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyOldPassword,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: _isLoading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Valider'),
                          ),
                        ),
                        if (biometricEnabled) ...[
                          const SizedBox(height: 16),
                          IconButton(
                            onPressed: _verifyWithBiometrics,
                            icon: const Icon(Icons.fingerprint, size: 36, color: AppColors.primary),
                            style: IconButton.styleFrom(
                              padding: const EdgeInsets.all(12),
                              backgroundColor: AppColors.primary.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface.withOpacity(0.8)
      ),
    );
  }

  InputDecoration _inputStyle({
    required ThemeData theme,
    required String hint,
    required IconData icon,
    VoidCallback? onIconTap,
    String? error,
    bool isPassword = false,
    bool obscure = false,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    return InputDecoration(
      hintText: hint,
      errorText: error,
      hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.35)),
      errorStyle: TextStyle(color: scheme.error, fontSize: 11),
      prefixIcon: Icon(icon, color: scheme.onSurface.withOpacity(0.6), size: 20),
      suffixIcon: isPassword
          ? IconButton(
        onPressed: onIconTap,
        icon: Icon(
          obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: scheme.onSurface.withOpacity(0.6),
          size: 20,
        ),
      )
          : null,
      filled: true,
      fillColor: isDark ? scheme.surface : const Color(0xFFF8FAFC),
      border: _outline(scheme.outline.withOpacity(isDark ? 0.35 : 0.2)),
      enabledBorder: _outline(scheme.outline.withOpacity(isDark ? 0.35 : 0.2)),
      focusedBorder: _outline(scheme.primary, width: 1.5),
      errorBorder: _outline(scheme.error),
      focusedErrorBorder: _outline(scheme.error, width: 1.5),
    );
  }

  OutlineInputBorder _outline(Color color, {double width = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: color, width: width));
}
