import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/app_settings_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../app/routing/app_router.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(authProvider).asData?.value;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.primary,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // CARTE AGENT
              Skeletonizer(
                enabled: _isLoading,
                child: _buildUserCard(theme, l10n, user?.phoneNumber?? ''),
              ),
              const SizedBox(height: 24),

              _sectionTitle(l10n.profile_section_app, theme),
              _buildOptionsGroup(theme, [
                _ProfileOption(
                  icon: Icons.language,
                  title: l10n.profile_option_lang,
                  subtitle: l10n.profile_option_lang_desc,
                  onTap: () => _showLanguageDialog(context, ref),
                ),
                _ProfileOption(
                  icon: settings.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  title: l10n.profile_option_theme,
                  subtitle: l10n.profile_option_theme_desc,
                  onTap: () => _toggleTheme(ref),
                ),
                _ProfileOption(
                  icon: Icons.notifications_none_rounded,
                  title: l10n.profile_option_notif,
                  subtitle: l10n.profile_option_notif_desc,
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),
              _sectionTitle(l10n.profile_section_security, theme),
              _buildOptionsGroup(theme, [
                _ProfileOption(
                  icon: Icons.lock_outline_rounded,
                  title: l10n.profile_option_security_pass,
                  subtitle: l10n.profile_option_security_pass_desc,
                  onTap: () {},
                ),
                _ProfileOption(
                  icon: Icons.history_toggle_off_rounded,
                  title: l10n.profile_option_last_login,
                  subtitle: l10n.profile_option_last_login_desc,
                ),
              ]),

              const SizedBox(height: 24),
              _sectionTitle(l10n.profile_section_about, theme),
              _buildOptionsGroup(theme, [
                _ProfileOption(
                  icon: Icons.info_outline_rounded,
                  title: l10n.profile_option_about_title,
                  subtitle: l10n.profile_option_about_desc,
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.profile_option_lang),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Français"),
              trailing: currentLocale.languageCode == 'fr' ? const Icon(Icons.check_rounded) : null,
              onTap: () {
                ref.read(appSettingsProvider.notifier).updateLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("English"),
              trailing: currentLocale.languageCode == 'en' ? const Icon(Icons.check_rounded) : null,
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

  Widget _buildUserCard(ThemeData theme, var l10n, String phone) {
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
                  'Pafing Tedy',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: theme.colorScheme.onSurface),
                ),
                Text(l10n.profile_agent_id('AGT-00123'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                Text(l10n.profile_role('Back Office'), style: const TextStyle(fontSize: 12, color: AppColors.muted)),
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

  const _ProfileOption({required this.icon, required this.title, required this.subtitle, this.onTap});

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
            if (onTap != null) const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
          ],
        ),
      ),
    );
  }
}