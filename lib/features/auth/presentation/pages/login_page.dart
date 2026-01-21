import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import '../widgets/login_card.dart';
import '../widgets/red_circles_background.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();

  bool _obscure = true;
  String? _phoneError;
  String? _passError;

  @override
  void initState() {
    super.initState();
    // On récupère la valeur actuelle du provider (chargée depuis le storage)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.future).then((user) {
        if (!mounted) return;
        final savedPhone = user.phoneNumber;
        if (savedPhone.isNotEmpty) {
          _phoneCtrl.text = savedPhone;
        }
      });
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    final digits = _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');
    final pass = _passCtrl.text.trim();

    if (digits.length != 9 || !digits.startsWith('6')) {
      setState(() {
        _phoneError = "Format invalide (ex: 6XX XX XX XX)";
        _passError = null;
      });
      _phoneFocus.requestFocus();
      return;
    }

    if (pass.isEmpty) {
      setState(() {
        _phoneError = null;
        _passError = "Mot de passe requis";
      });
      _passFocus.requestFocus();
      return;
    }

    setState(() {
      _phoneError = null;
      _passError = null;
    });

    try {
      await ref.read(authProvider.notifier).signIn(digits, pass);
      if (!mounted) return;

      final user = ref.read(authProvider).asData?.value;
      if (user?.isAuthenticated == true) {
        context.go(Routes.home);
      } else {
        await showAppMessageDialog(
          context,
          title: 'Erreur',
          message: 'Authentification échouée.',
          type: AppMessageType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showAppMessageDialog(
        context,
        title: 'Erreur',
        message: e.toString(),
        type: AppMessageType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
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
                          phoneCtrl: _phoneCtrl,
                          passCtrl: _passCtrl,
                          phoneFocus: _phoneFocus,
                          passFocus: _passFocus,
                          phoneError: _phoneError,
                          passError: _passError,
                          obscure: _obscure,
                          isLoading: isLoading,
                          onPhoneChanged: (_) => setState(() => _phoneError = null),
                          onToggleObscure: () => setState(() => _obscure = !_obscure),
                          onSignIn: () => _handleSignIn(),
                          onForgotPassword: () => showAppMessageDialog(context,
                              title: 'Info',
                              message: 'Contactez l\'admin.',
                              type: AppMessageType.info),
                          onContactAdmin: () => showAppMessageDialog(context,
                              title: 'Admin',
                              message: 'Email : admin@cellcom.cm',
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
                          ' 2026 Cellcom',
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