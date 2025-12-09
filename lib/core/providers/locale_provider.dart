import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  static const String _localeKey = 'app_locale';
  
  LocaleNotifier() : super(null) {
    _loadLocale();
  }

  /// Load the saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);
      if (languageCode != null) {
        state = Locale(languageCode);
      }
    } catch (e) {
      // If there's an error loading preferences, just use system default
      state = null;
    }
  }

  /// Set the locale and persist it
  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // If there's an error saving, the locale will still be set for this session
      debugPrint('Error saving locale preference: $e');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) => LocaleNotifier(),
);
