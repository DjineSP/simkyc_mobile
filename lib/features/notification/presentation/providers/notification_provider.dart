import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/notification_item.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationState {
  final List<NotificationItem> items;
  final bool isLoading;
  final String? error;
  final bool showUnreadOnly;

  const NotificationState({
    required this.items,
    required this.isLoading,
    required this.error,
    required this.showUnreadOnly,
  });

  factory NotificationState.initial() => const NotificationState(
        items: <NotificationItem>[],
        isLoading: true,
        error: null,
        showUnreadOnly: false,
      );

  int get unreadCount => items.where((e) => !e.isRead).length;

  List<NotificationItem> get visibleItems {
    if (!showUnreadOnly) return items;
    return items.where((e) => !e.isRead).toList();
  }

  NotificationState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? showUnreadOnly,
  }) {
    return NotificationState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
    );
  }
}

class NotificationNotifier extends Notifier<NotificationState> {
  @override
  NotificationState build() {
    final initial = NotificationState.initial();
    Future.microtask(refresh);
    return initial;
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final items = await repo.fetchNotifications();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setShowUnreadOnly(bool v) {
    state = state.copyWith(showUnreadOnly: v);
  }

  void markAsRead(String id) {
    final updated = state.items
        .map((e) => e.id == id ? e.copyWith(isRead: true) : e)
        .toList();
    state = state.copyWith(items: updated);
  }

  void markAllRead() {
    final updated = state.items.map((e) => e.copyWith(isRead: true)).toList();
    state = state.copyWith(items: updated);
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationProvider = NotifierProvider<NotificationNotifier, NotificationState>(() {
  return NotificationNotifier();
});
