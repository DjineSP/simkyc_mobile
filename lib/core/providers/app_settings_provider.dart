import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// L'état reste identique
class AppSettingsState {
  final ThemeMode themeMode;
  final Locale locale;

  AppSettingsState({required this.themeMode, required this.locale});

  AppSettingsState copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

// CORRECTION : Utilise 'Notifier' avec le type de ton état
class AppSettingsNotifier extends Notifier<AppSettingsState> {
  @override
  AppSettingsState build() {
    // Initialisation
    final theme = StorageService.instance.read('theme');
    final lang = StorageService.instance.read('lang');

    return AppSettingsState(
      themeMode: _getTheme(theme),
      locale: Locale(lang ?? 'fr'),
    );
  }

  ThemeMode _getTheme(String? theme) {
    if (theme == 'dark') return ThemeMode.dark;
    if (theme == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  void updateTheme(ThemeMode mode) {
    // 'state' est maintenant reconnu car on hérite de Notifier<AppSettingsState>
    state = state.copyWith(themeMode: mode);
    StorageService.instance.write('theme', mode.name);
  }

  void updateLocale(Locale locale) {
    state = state.copyWith(locale: locale);
    StorageService.instance.write('lang', locale.languageCode);
  }
}

// CORRECTION : Le Provider doit correspondre à la classe
// On utilise NotifierProvider (sans le .autoDispose pour garder les réglages en mémoire)
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettingsState>(() {
  return AppSettingsNotifier();
});

class BiometricSettingsNotifier extends Notifier<bool> {
  static const _kBiometricEnabledKey = 'biometric_enabled';

  @override
  bool build() {
    final v = StorageService.instance.read(_kBiometricEnabledKey);
    return v == 'true';
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await StorageService.instance.write(
      _kBiometricEnabledKey,
      enabled ? 'true' : 'false',
    );
  }
}

final biometricEnabledProvider = NotifierProvider<BiometricSettingsNotifier, bool>(() {
  return BiometricSettingsNotifier();
});