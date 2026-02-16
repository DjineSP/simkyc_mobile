import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';


import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../app/routing/app_router.dart';
import '../../../../shared/widgets/app_message_dialog.dart';
import 'change_password_page.dart';


class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  Future<void> _toggleBiometric(BuildContext context, WidgetRef ref, bool enable) async {
    if (!enable) {
      await ref.read(biometricEnabledProvider.notifier).setEnabled(false);
      return;
    }

    final isSupported = await BiometricAuthService.instance.isDeviceSupported();
    if (!mounted) return;

    if (!isSupported) {
      await showAppMessageDialog(
        context,
        title: AppLocalizations.of(context)!.common_error_title,
        message: 'Cet appareil ne supporte pas l\'authentification biométrique.',
        type: AppMessageType.error,
      );
      await ref.read(biometricEnabledProvider.notifier).setEnabled(false);
      return;
    }

    final available = await BiometricAuthService.instance.getAvailableBiometrics();
    if (!mounted) return;

    if (available.isEmpty) {
      await showAppMessageDialog(
        context,
        title: AppLocalizations.of(context)!.common_error_title,
        message: 'Aucune biométrie n\'est configurée. Ajoutez une empreinte (ou FaceID) dans les réglages du téléphone.',
        type: AppMessageType.error,
      );
      await ref.read(biometricEnabledProvider.notifier).setEnabled(false);
      return;
    }

    final ok = await BiometricAuthService.instance.authenticate(
      reason: 'Activer l’empreinte digitale',
    );
    if (!mounted) return;

    if (!ok) {
      final code = BiometricAuthService.instance.lastErrorCode;
      final msg = (code == 'biometricHardwareTemporarilyUnavailable')
          ? 'Le capteur biométrique est temporairement indisponible. Réessayez dans quelques secondes.'
          : 'Authentification biométrique échouée ou annulée.';
      await showAppMessageDialog(
        context,
        title: AppLocalizations.of(context)!.common_error_title,
        message: msg,
        type: AppMessageType.error,
      );
    }

    await ref.read(biometricEnabledProvider.notifier).setEnabled(ok);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).asData?.value;
    final userData = user?.userData;
    final settings = ref.watch(appSettingsProvider);
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
             // Replaces the undefined method call with a valid refresh call
             await ref.refresh(authProvider.future);
          },
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // CARTE AGENT
              _buildUserCard(
                theme,
                l10n,
                '', // unused phone/login param
                fullName: userData?.username ?? 'Utilisateur',
                agentId: userData?.idUser ?? '',
                roleLabel: 'Agent', 
              ),
              const SizedBox(height: 24),

              _sectionTitle(l10n.profile_section_app, theme),
              _buildOptionsGroup(theme, [
                _ProfileOption(
                  icon: Icons.language,
                  title: l10n.profile_option_lang,
                  subtitle: l10n.profile_option_lang_desc,
                  showArrow: false,
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                _ProfileOption(
                  icon: settings.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  title: l10n.profile_option_theme,
                  subtitle: l10n.profile_option_theme_desc,
                  showArrow: false,
                  onTap: () => _toggleTheme(ref),
                ),

              ]),

              const SizedBox(height: 24),
              _sectionTitle(l10n.profile_section_security, theme),
              _buildOptionsGroup(theme, [
                _ProfileOption(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.profile_option_security_pass,
                  subtitle: l10n.profile_option_security_pass_desc,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
                    );
                  },
                ),
                _ProfileToggleOption(
                  icon: Icons.fingerprint_rounded,
                  title: 'Empreinte digitale',
                  subtitle: biometricEnabled
                      ? 'Activée'
                      : 'Désactivée',
                  value: biometricEnabled,
                  onChanged: (v) => _toggleBiometric(context, ref, v),
                ),

              ]),



              const SizedBox(height: 32),
              _buildLogoutButton(l10n),
            ],
          ),
        ),
      ),
    );
  }

  // --- LOGIQUE DES ACTIONS ---

  void _toggleTheme(WidgetRef ref) {
    final current = ref.read(appSettingsProvider).themeMode;
    final next = current == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    ref.read(appSettingsProvider.notifier).updateTheme(next);
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.read(appSettingsProvider).locale;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        surfaceTintColor: Colors.transparent, // Remove M3 tint
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          l10n.profile_option_lang,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Français", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              trailing: currentLocale.languageCode == 'fr' 
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) 
                  : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                ref.read(appSettingsProvider.notifier).updateLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("English", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              trailing: currentLocale.languageCode == 'en' 
                  ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) 
                  : null,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                ref.read(appSettingsProvider.notifier).updateLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE CONSTRUCTION ---

  Widget _buildUserCard(
    ThemeData theme,
    var l10n,
    String phone, {
    required String fullName,
    required String agentId,
    required String roleLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface),
                ),
                Text(l10n.profile_agent_id(agentId), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                Text(l10n.profile_role(roleLabel), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.7)),
      ),
    );
  }

  Widget _buildOptionsGroup(ThemeData theme, List<Widget> options) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: Column(children: options),
    );
  }

  Widget _buildLogoutButton(var l10n) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.profile_logout),
              content: Text(l10n.profile_logout_dialog_body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.profile_logout_cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.profile_logout_confirm),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          await ref.read(authProvider.notifier).logout();
          if (!mounted) return;
          context.go(Routes.login);
        },
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
        label: Text(l10n.profile_logout, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
      ),
    );
  }
}


class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),

      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: theme.colorScheme.onSurface)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            ),
            if (onTap != null && showArrow) const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileToggleOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ProfileToggleOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}