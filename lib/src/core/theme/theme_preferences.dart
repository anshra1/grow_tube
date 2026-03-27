import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  ThemePreferences(this._prefs);

  static const _key = 'theme_mode';

  final SharedPreferences _prefs;

  Future<ThemeMode> readThemeMode() async {
    final value = _prefs.getString(_key);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  Future<void> writeThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_key, value);
  }
}
