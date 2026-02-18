import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/gen/app_localizations.dart';

class LoginCard extends StatelessWidget {
  final TextEditingController loginCtrl;
  final TextEditingController passCtrl;
  final FocusNode loginFocus;
  final FocusNode passFocus;
  final String? loginError;
  final String? passError;
  final String? generalError;
  final bool obscure;
  final bool isLoading;
  final Function(String) onLoginChanged;
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;

  const LoginCard({
    super.key,
    required this.loginCtrl,
    required this.passCtrl,
    required this.loginFocus,
    required this.passFocus,
    this.loginError,
    this.passError,
    this.generalError,
    required this.obscure,
    this.isLoading = false,
    required this.onLoginChanged,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onToggleObscure,
    required this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: isDark ? Border.all(color: theme.colorScheme.outline.withOpacity(0.1)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(theme, l10n),
          const SizedBox(height: 28),

          _label(l10n.auth_field_login, theme),
          const SizedBox(height: 8),
          TextField(
            controller: loginCtrl,
            focusNode: loginFocus,
            onChanged: onLoginChanged,
            keyboardType: TextInputType.text,
            style: TextStyle(color: scheme.onSurface),
            decoration: _inputStyle(
              theme: theme,
              hint: l10n.auth_field_login,
              icon: Icons.person_outline,
              error: loginError,
            ),
          ),

          const SizedBox(height: 12),

          _label(l10n.auth_field_password, theme),
          const SizedBox(height: 8),
          TextField(
            controller: passCtrl,
            focusNode: passFocus,
            obscureText: obscure,
            style: TextStyle(color: scheme.onSurface),
            decoration: _inputStyle(
              theme: theme,
              hint: '••••••••',
              icon: Icons.lock_outline,
              error: passError,
              onIconTap: onToggleObscure,
              isPassword: true,
              obscure: obscure,
            ),
          ),
          if (generalError != null) ...[
            const SizedBox(height: 12),
            Text(
              generalError!,
              style: TextStyle(
                color: scheme.error,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
          ] else ...[
            const SizedBox(height: 12),
          ],

          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (v) => onRememberMeChanged(v ?? false),
              ),
              Expanded(
                child: Text(
                  l10n.auth_remember_me,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(
            child: ElevatedButton(
              onPressed: isLoading ? null : onSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l10n.auth_button_submit, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),



          const SizedBox(height: 20),


        ],
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

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipOval(
                child: Image.asset(
                  'assets/images/cellcom_logo_red.png',
                  width: 44, height: 44, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.business, color: AppColors.red, size: 40),
                )
            ),
            const SizedBox(width: 12),
            Text(
              l10n.app_name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.red),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          l10n.auth_login_subtitle,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface
          ),
        ),
      ],
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