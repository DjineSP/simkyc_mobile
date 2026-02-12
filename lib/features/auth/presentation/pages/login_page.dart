import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import '../widgets/login_card.dart';
import '../widgets/red_circles_background.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _loginFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  bool _rememberMe = false;
  String? _loginError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    // On récupère la valeur actuelle du provider (chargée depuis le storage)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.future).then((user) {
        if (!mounted) return;
        final rememberMe = ref.read(authProvider.notifier).getRememberMe();
        final savedLogin = user.login;
        setState(() => _rememberMe = rememberMe);
        if (rememberMe && savedLogin.isNotEmpty) {
          _loginCtrl.text = savedLogin;
        }
      });
    });
  }

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    _loginFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final l10n = AppLocalizations.of(context)!;
    final login = _loginCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (login.isEmpty) {
      setState(() {
        _loginError = l10n.auth_error_invalid_phone;
        _passError = null;
      });
      _loginFocus.requestFocus();
      return;
    }

    if (pass.isEmpty) {
      setState(() {
        _loginError = null;
        _passError = l10n.auth_error_password_required;
      });
      _passFocus.requestFocus();
      return;
    }

    setState(() {
      _loginError = null;
      _passError = null;
    });

    try {
      await ref.read(authProvider.notifier).signIn(login, pass, rememberMe: _rememberMe);
      if (!mounted) return;

      final user = ref.read(authProvider).asData?.value;
      if (user?.isAuthenticated == true) {
        context.go(Routes.home);
      } else {
        await showAppMessageDialog(
          context,
          title: l10n.common_error_title,
          message: l10n.auth_error_auth_failed,
          type: AppMessageType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showAppMessageDialog(
        context,
        title: l10n.common_error_title,
        message: e.toString(),
        type: AppMessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final size = MediaQuery.of(context).size;

    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // Suppression du SafeArea ici pour permettre au fond de remplir tout l'écran
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Fond transparent pour voir notre rouge
          // Sur le rouge Cellcom, on veut toujours des icônes blanches (Light)
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark, // Pour iOS
        ),
        child: Stack(
          children: [
            // 1. Le fond qui remplit TOUT l'écran
            _buildBackground(size, theme),

            // 2. Le contenu protégé par le SafeArea
            SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: LoginCard(
                          loginCtrl: _loginCtrl,
                          passCtrl: _passCtrl,
                          loginFocus: _loginFocus,
                          passFocus: _passFocus,
                          loginError: _loginError,
                          passError: _passError,
                          obscure: _obscure,
                          isLoading: isLoading,
                          onLoginChanged: (_) => setState(() => _loginError = null),
                          rememberMe: _rememberMe,
                          onRememberMeChanged: (v) => setState(() => _rememberMe = v),
                          onToggleObscure: () => setState(() => _obscure = !_obscure),
                          onSignIn: () => _handleSignIn(),
                          onForgotPassword: () => showAppMessageDialog(context,
                              title: l10n.common_info_title,
                              message: l10n.auth_forgot_password_dialog_body,
                              type: AppMessageType.info),
                          onContactAdmin: () => showAppMessageDialog(context,
                              title: l10n.auth_contact_admin_dialog_title,
                              message: l10n.auth_contact_admin_dialog_body,
                              type: AppMessageType.info),
                        ),
                      ),
                    ),
                  ),
                  if (!keyboardOpen)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          l10n.auth_footer,
                          style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurface.withOpacity(0.5)
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(Size size, ThemeData theme) {
    return Column(
      children: [
        Expanded(
          flex: 38,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: AppColors.primary),
              const RedCirclesBackground(),
              Opacity(
                opacity: 0.18,
                child: Image.asset('assets/images/tour_relais.png', fit: BoxFit.contain),
              ),
            ],
          ),
        ),
        Expanded(
            flex: 62,
            child: ColoredBox(color: theme.scaffoldBackgroundColor)
        ),
      ],
    );
  }
}