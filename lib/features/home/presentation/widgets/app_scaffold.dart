import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import 'bottom_nav_bar.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final bool showFab;
  final VoidCallback? onFabTap;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentIndex,
    required this.onNavTap,
    this.showFab = true,
    this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Transparent pour voir la couleur de l'AppBar
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        // Utilise la couleur de fond du thème (Gris clair ou Slate profond)
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leadingWidth: 100,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Image.asset(
              'assets/images/cellcom_logo_full_light.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorBuilder: (_, __, ___) => const Icon(Icons.business, color: Colors.white),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          actions: [
            IconButton(
              onPressed: () => context.push(Routes.notifications),
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => onNavTap(3), // Redirige vers l'onglet Profil
                child: const CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0x33FFFFFF),
                  child: Text(
                    'PT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: body, // Pas de SafeArea ici si on veut que le contenu touche les bords ou soit géré par les pages

        floatingActionButton: showFab
            ? FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: onFabTap ?? () {},
          shape: const CircleBorder(), // Important pour le design notched
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        )
            : null,
        floatingActionButtonLocation: showFab ? FloatingActionButtonLocation.centerDocked : null,

        bottomNavigationBar: BottomNavBar(
          currentIndex: currentIndex,
          onTap: onNavTap,
          withFabNotch: showFab,
        ),
      ),
    );
  }
}