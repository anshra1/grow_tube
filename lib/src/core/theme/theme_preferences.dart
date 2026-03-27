import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  ThemePreferences(this._prefs);

  static const _key = 'theme_mode';

  final SharedPreferences _prefs;

  Future<ThemeMode?> readThemeMode() async {
    final value = _prefs.getString(_key);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => null,
    };
  }

  Future<void> writeThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => null,
    };

    if (value == null) {
      await _prefs.remove(_key);
      return;
    }

    await _prefs.setString(_key, value);
  }
}
