import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../l10n/gen/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../data/models/notification_item.dart';
import '../providers/notification_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final state = ref.watch(notificationProvider);
    final notifications = state.visibleItems;
    final isLoading = state.isLoading;
    final unreadCount = state.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications_title),
        actions: [
          if (unreadCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: unreadCount == 0
                ? null
                : () => ref.read(notificationProvider.notifier).markAllRead(),
            icon: const Icon(Icons.done_all_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Toutes'),
                  selected: !state.showUnreadOnly,
                  onSelected: (_) => ref.read(notificationProvider.notifier).setShowUnreadOnly(false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Non lues${unreadCount > 0 ? " ($unreadCount)" : ""}'),
                  selected: state.showUnreadOnly,
                  onSelected: (_) => ref.read(notificationProvider.notifier).setShowUnreadOnly(true),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
              child: Skeletonizer(
                enabled: isLoading,
                child: notifications.isEmpty && !isLoading
                    ? _NotificationsEmptyState(theme: theme, l10n: l10n)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemCount: isLoading ? 6 : notifications.length,
                        separatorBuilder: (_, __) => Divider(color: theme.dividerColor.withOpacity(0.2)),
                        itemBuilder: (context, index) {
                          if (isLoading) {
                            return const _NotificationTilePlaceholder();
                          }
                          final item = notifications[index];

                          final iconData = _iconForType(item.type);
                          final color = _colorForType(theme, item.type);

                          return ListTile(
                            onTap: () async {
                              await showDialog<void>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text(item.title),
                                  content: Text(item.body),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                              ref.read(notificationProvider.notifier).markAsRead(item.id);
                            },
                            contentPadding: EdgeInsets.zero,
                            leading: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  backgroundColor: color.withOpacity(0.12),
                                  foregroundColor: color,
                                  child: Icon(iconData),
                                ),
                                if (!item.isRead)
                                  Positioned(
                                    right: -1,
                                    top: -1,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: theme.scaffoldBackgroundColor, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w900,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              item.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)),
                            ),
                            trailing: Text(
                              item.timeLabel,
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.colorScheme.onSurface.withOpacity(0.55),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForType(NotificationType type) {
  switch (type) {
    case NotificationType.success:
      return Icons.check_circle_outline_rounded;
    case NotificationType.warning:
      return Icons.warning_amber_rounded;
    case NotificationType.error:
      return Icons.error_outline_rounded;
    case NotificationType.info:
    default:
      return Icons.info_outline_rounded;
  }
}

Color _colorForType(ThemeData theme, NotificationType type) {
  switch (type) {
    case NotificationType.success:
      return Colors.green;
    case NotificationType.warning:
      return Colors.orange;
    case NotificationType.error:
      return theme.colorScheme.error;
    case NotificationType.info:
    default:
      return theme.colorScheme.primary;
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  final ThemeData theme;
  final AppLocalizations l10n;

  const _NotificationsEmptyState({required this.theme, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 54,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.notifications_empty_title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.notifications_empty_body,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.65)),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTilePlaceholder extends StatelessWidget {
  const _NotificationTilePlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: const SizedBox(width: 18, height: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, color: theme.colorScheme.surface),
                const SizedBox(height: 6),
                Container(height: 10, color: theme.colorScheme.surface),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 28, height: 10, color: theme.colorScheme.surface),
        ],
      ),
    );
  }
}