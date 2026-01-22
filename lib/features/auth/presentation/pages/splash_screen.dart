import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

// Correction des imports vers ton architecture template
import '../../../../app/routing/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../l10n/gen/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final user = await ref.read(authProvider.future);
      if (!mounted) return;

      final biometricEnabled = ref.read(biometricEnabledProvider);
      if (user.isAuthenticated && biometricEnabled) {
        final ok = await BiometricAuthService.instance.authenticate(
          reason: 'Veuillez vous authentifier pour continuer',
        );
        if (!mounted) return;

        if (ok) {
          context.go(Routes.home);
        } else {
          context.go(Routes.login);
        }
        return;
      }

      if (user.isAuthenticated && ref.read(authProvider.notifier).getRememberMe()) {
        context.go(Routes.login);
        return;
      }

      context.go(Routes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Utilise ta couleur primary ou une couleur spécifique dans AppColors
          Container(color: AppColors.primary),
          const _RedCirclesBackground(),
          Positioned(
            top: -20,
            right: -30,
            child: Opacity(
              opacity: 0.30,
              child: Image.asset(
                'assets/images/tour_relais.png',
                height: size.height * 0.55,
                fit: BoxFit.contain,
                // Protection si l'image n'est pas encore là
                errorBuilder: (context, error, stackTrace) => const SizedBox(),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 100),
                    Image.asset(
                      'assets/images/cellcom_logo_full_light.png',
                      height: 90,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 90, color: Colors.white),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.splash_subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 36),
                    const SpinKitFadingCircle(
                      color: Colors.white,
                      size: 46,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Les sous-widgets restent identiques mais on enlève "const" des listes si nécessaire
class _RedCirclesBackground extends StatelessWidget {
  const _RedCirclesBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(left: -90, bottom: -100, child: _Circle(size: 260, opacity: 0.18)),
        Positioned(left: 100, bottom: 40, child: _Circle(size: 220, opacity: 0.16)),
        Positioned(right: -100, top: 140, child: _Circle(size: 340, opacity: 0.14)),
      ],
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;
  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}