import 'package:flutter/material.dart';
import 'package:simkyc_mobile/l10n/gen/app_localizations.dart';

import '../../../../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool withFabNotch;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.withFabNotch = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BottomAppBar(
      color: theme.colorScheme.surface,
      shape: withFabNotch ? const CircularNotchedRectangle() : null,
      notchMargin: withFabNotch ? 8 : 0,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.dividerColor.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavItem(
                    icon: currentIndex == 0
                        ? Icons.home_rounded
                        : Icons.home_outlined,
                    label: l10n.home_nav_home,
                    active: currentIndex == 0,
                    onTap: () => onTap(0),
                  ),
                  _NavItem(
                    icon: currentIndex == 1
                        ? Icons.history_rounded
                        : Icons.history_outlined,
                    label: l10n.home_nav_history,
                    active: currentIndex == 1,
                    onTap: () => onTap(1),
                  ),

                  // Espace pour le FAB
                  if (withFabNotch) const SizedBox(width: 40),

                  _NavItem(
                    icon: currentIndex == 2
                        ? Icons.bar_chart_rounded
                        : Icons.bar_chart_outlined,
                    label: l10n.home_nav_reports,
                    active: currentIndex == 2,
                    onTap: () => onTap(2),
                  ),
                  _NavItem(
                    icon: currentIndex == 3
                        ? Icons.person_rounded
                        : Icons.person_outline,
                    label: l10n.home_nav_profile,
                    active: currentIndex == 3,
                    onTap: () => onTap(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final color = active
        ? AppColors.primary
        : theme.colorScheme.onSurface.withOpacity(0.4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                color: color,
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
