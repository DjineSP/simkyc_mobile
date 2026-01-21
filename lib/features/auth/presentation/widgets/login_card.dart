import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/phone_formatter.dart';
import '../../../../l10n/gen/app_localizations.dart';

class LoginCard extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final TextEditingController passCtrl;
  final FocusNode phoneFocus;
  final FocusNode passFocus;
  final String? phoneError;
  final String? passError;
  final bool obscure;
  final bool isLoading;
  final Function(String) onPhoneChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onSignIn;
  final VoidCallback onForgotPassword;
  final VoidCallback onContactAdmin;

  const LoginCard({
    super.key,
    required this.phoneCtrl,
    required this.passCtrl,
    required this.phoneFocus,
    required this.passFocus,
    this.phoneError,
    this.passError,
    required this.obscure,
    this.isLoading = false,
    required this.onPhoneChanged,
    required this.onToggleObscure,
    required this.onSignIn,
    required this.onForgotPassword,
    required this.onContactAdmin,
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

          _label(l10n.auth_field_phone, theme),
          const SizedBox(height: 8),
          TextField(
            controller: phoneCtrl,
            focusNode: phoneFocus,
            onChanged: onPhoneChanged,
            keyboardType: TextInputType.phone,
            style: TextStyle(color: scheme.onSurface),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, PhoneFormatter()],
            decoration: _inputStyle(
              theme: theme,
              hint: '6XX XX XX XX',
              icon: Icons.phone_outlined,
              error: phoneError,
            ),
          ),

          const SizedBox(height: 20),

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

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onForgotPassword,
              child: Text(
                l10n.auth_forgot_password,
                style: TextStyle(fontSize: 12, color: scheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 54,
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

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.auth_no_account,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurface.withOpacity(0.6),
                ),
              ),
              TextButton(
                onPressed: onContactAdmin,
                child: Text(
                  l10n.auth_contact_admin,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
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
            const Text(
              'Cellcom',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.red),
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