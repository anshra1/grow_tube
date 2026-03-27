import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/theme/theme_preferences.dart';

@immutable
class ThemeState {
  const ThemeState({
    required this.mode,
    required this.platformBrightness,
  });

  final ThemeMode mode;
  final Brightness platformBrightness;

  ThemeState copyWith({
    ThemeMode? mode,
    Brightness? platformBrightness,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      platformBrightness: platformBrightness ?? this.platformBrightness,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeState &&
        other.mode == mode &&
        other.platformBrightness == platformBrightness;
  }

  @override
  int get hashCode => Object.hash(mode, platformBrightness);
}

class ThemeCubit extends Cubit<ThemeState> with WidgetsBindingObserver {
  ThemeCubit(this._preferences)
      : super(
          ThemeState(
            mode: ThemeMode.values.byName(
              WidgetsBinding.instance.platformDispatcher.platformBrightness.name,
            ),
            platformBrightness:
                WidgetsBinding.instance.platformDispatcher.platformBrightness,
          ),
        ) {
    WidgetsBinding.instance.addObserver(this);
  }

  final ThemePreferences _preferences;

  Future<void> load() async {
    final storedMode = await _preferences.readThemeMode();
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    emit(
      state.copyWith(
        mode: storedMode ?? ThemeMode.values.byName(brightness.name),
        platformBrightness: brightness,
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _preferences.writeThemeMode(mode);
    emit(state.copyWith(mode: mode));
  }

  Future<void> cycleThemeMode() async {
    final next = switch (state.mode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => ThemeMode.light,
    };
    await setThemeMode(next);
  }

  @override
  void didChangePlatformBrightness() {
    final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    emit(
      state.copyWith(
        platformBrightness: brightness,
        mode: ThemeMode.values.byName(brightness.name),
      ),
    );
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    return super.close();
  }
}
