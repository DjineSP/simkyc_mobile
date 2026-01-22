import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/sim/presentation/pages/components/activation_helpers.dart';
import '../../l10n/gen/app_localizations.dart';
import '../providers/app_settings_provider.dart';
import '../providers/auth_provider.dart';
import '../../shared/widgets/app_message_dialog.dart';
import 'biometric_auth_service.dart';

enum OperationValidationMethod {
  biometric,
  password,
}

class OperationValidator {
  static Future<bool> validate(
    BuildContext context,
    WidgetRef ref, {
    required String reason,
    bool allowBiometric = true,
    bool allowPassword = true,
  }) async {
    final biometricEnabled = ref.read(biometricEnabledProvider);
    final canUseBiometric = allowBiometric && biometricEnabled;
    final canUsePassword = allowPassword;

    final method = await _chooseMethod(
      context,
      ref,
      reason: reason,
      canUseBiometric: canUseBiometric,
      canUsePassword: canUsePassword,
    );

    if (method == null) return false;

    switch (method) {
      case OperationValidationMethod.biometric:
        return _validateWithBiometric(context, reason: reason);
      case OperationValidationMethod.password:
        return _validateWithPassword(context, ref);
    }
  }

  static Future<OperationValidationMethod?> _chooseMethod(
    BuildContext context,
    WidgetRef ref, {
    required String reason,
    required bool canUseBiometric,
    required bool canUsePassword,
  }) async {
    if (!canUseBiometric && !canUsePassword) return null;

    if (canUseBiometric && !canUsePassword) {
      return OperationValidationMethod.biometric;
    }

    if (!canUseBiometric && canUsePassword) {
      return OperationValidationMethod.password;
    }

    final l10n = AppLocalizations.of(context)!;

    return showModalBottomSheet<OperationValidationMethod>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.op_validate_title,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.op_validate_subtitle,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                ),
                const SizedBox(height: 8),
                Text(
                  reason,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.65)),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => Navigator.pop(context, OperationValidationMethod.biometric),
                  icon: const Icon(Icons.fingerprint_rounded),
                  label: Text(l10n.op_validate_use_biometric),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context, OperationValidationMethod.password),
                  icon: const Icon(Icons.lock_outline_rounded),
                  label: Text(l10n.op_validate_use_password),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.common_cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<bool> _validateWithBiometric(
    BuildContext context, {
    required String reason,
  }) async {
    final ok = await BiometricAuthService.instance.authenticate(reason: reason);
    if (ok) return true;

    await showAppMessageDialog(
      context,
      title: AppLocalizations.of(context)!.common_error_title,
      message: AppLocalizations.of(context)!.op_validate_biometric_failed,
      type: AppMessageType.error,
    );

    return false;
  }

  static Future<bool> _validateWithPassword(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final focusNode = FocusNode();

    try {
      final password = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final theme = Theme.of(context);

          var obscure = true;

          return StatefulBuilder(
            builder: (context, setState) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!focusNode.hasFocus) {
                  focusNode.requestFocus();
                }
              });

              final decoration = inputDec(
                context: context,
                hint: '••••••••',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(
                    obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    size: 20,
                  ),
                ),
              );

              return AlertDialog(
                insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 6),
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: SizedBox(
                    width: 520,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelText(l10n.auth_field_password),
                        TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          obscureText: obscure,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (v) => Navigator.pop(context, v),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: decoration,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n.common_cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, controller.text),
                    child: Text(l10n.common_ok),
                  ),
                ],
              );
            },
          );
        },
      );

      if (password == null || password.isEmpty) {
        return false;
      }

      final login = ref.read(authProvider).asData?.value.login ?? '';
      if (login.isEmpty) {
        await showAppMessageDialog(
          context,
          title: l10n.common_error_title,
          message: l10n.op_validate_user_not_identified,
          type: AppMessageType.error,
        );
        return false;
      }

      final repo = ref.read(authRepositoryProvider);
      final ok = await repo.verifyPassword(login, password);
      if (ok) return true;

      await showAppMessageDialog(
        context,
        title: l10n.common_error_title,
        message: l10n.auth_error_auth_failed,
        type: AppMessageType.error,
      );

      return false;
    } finally {
      controller.dispose();
      focusNode.dispose();
    }
  }
}
