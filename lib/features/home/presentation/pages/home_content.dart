import 'package:flutter/material.dart'; // Colors
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../providers/home_provider.dart';

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final state = ref.watch(homeDashboardProvider);
    final isLoading = state.isLoading;
    final data = state.data;

    final displayName = isLoading ? BoneMock.name : (data?.displayName ?? '');
    final roleLabel = isLoading ? BoneMock.words(1) : (data?.roleLabel ?? '');

    final actions = [
      _ActionData(
        title: l10n.home_action_activation,
        subtitle: l10n.home_desc_activation,
        icon: Icons.inventory_2_outlined,
        route: Routes.simActivation,
      ),
      _ActionData(
        title: l10n.home_action_reactivation,
        subtitle: l10n.home_desc_reactivation,
        icon: Icons.restart_alt_rounded,
        route: Routes.simReactivation,
      ),
      _ActionData(
        title: l10n.home_action_update,
        subtitle: l10n.home_desc_update,
        icon: Icons.update_rounded,
        route: Routes.simUpdate,
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        // Rafraichir les stats utilisateur depuis le serveur
        await ref.read(authProvider.notifier).refreshUserStats();
        // Rafraichir le dashboard si nécessaire (actuellement via riverpod ça se fait tout seul si auth change)
        return ref.read(homeDashboardProvider.notifier).refresh();
      },
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    state.error!,
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Text(
                l10n.home_greeting,
                style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.5)
                ),
              ),
              const SizedBox(height: 4),

              Skeletonizer(
                enabled: isLoading,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    _buildRoleBadge(roleLabel, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              
              // STATS KPIs
              Skeletonizer(
                enabled: isLoading,
                child: Column(
                  children: [
                    // Main KPI: Activations
                    SizedBox(
                      width: double.infinity,
                      child: _KpiCard(
                        title: l10n.home_action_activation, 
                        value: isLoading ? '0000' : (data?.totalActivations.toString() ?? '0'), 
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Secondary KPIs
                    Row(
                      children: [
                        Expanded(
                          child: _KpiCard(
                            title: l10n.home_action_reactivation, 
                            value: isLoading ? '0000' : (data?.totalReactivations.toString() ?? '0'), 
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _KpiCard(
                          title: l10n.home_action_update, 
                          value: isLoading ? '0000': (data?.totalUpdates.toString() ?? '0'), 
                          color: Colors.orange,
                        )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                l10n.home_section_actions,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              Column(
                children: actions.map((a) => _ActionTile(
                  title: a.title,
                  subtitle: a.subtitle,
                  icon: a.icon,
                  onTap: () => context.push(a.route!),
                )).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.green.withOpacity(0.2) : const Color(0xFFE8F7EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: isDark ? Colors.greenAccent : const Color(0xFF1F7A3F),
        ),
      ),
    );
  }
}

// Composants de support (KPI & Tiles)
class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? color;

  const _KpiCard({
    required this.title, 
    required this.value, 
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = color ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value, 
            style: TextStyle(
              fontSize: 32, 
              fontWeight: FontWeight.w900,
              color: primaryColor,
              height: 1.0,
            )
          ),
          const SizedBox(height: 8),
          Text(
            title, 
            style: TextStyle(
              fontSize: 13, 
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title, 
    required this.subtitle, 
    required this.icon, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

class _ActionData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? route;
  final Color? color;
  _ActionData({required this.title, required this.subtitle, required this.icon, this.route, this.color});
}