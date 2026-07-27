## Autoplay Next Video Feature
Implement a feature that automatically plays the next video in a playlist when the current video finishes, alongside a settings toggle to enable/disable it.

## User Review Required
None.

## Open Questions
- Does looping back to the first video when the last video finishes match your exact expected behavior? (My plan includes looping to the beginning).

## Proposed Changes
---
### Settings ViewModels
Adding the state and cubit logic to manage the autoplay setting globally via `SharedPreferences`.

#### [MODIFY] `lib/src/features/settings/viewmodels/setting_state.dart`
*(Already partially completed)* Add `isAutoplayEnabled` property to `SettingsLoadedState`.

#### [MODIFY] `lib/src/features/settings/viewmodels/settings_cubit.dart`
Inject `SharedPreferences` and add a `toggleAutoplay` method.
```dart
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repository, this._prefs) : super(const SettingsInitialState());

  final PlaylistRepository _repository;
  final SharedPreferences _prefs;
  static const _autoplayKey = 'is_autoplay_enabled';
  
  // ... update loadAllPlaylist to read _prefs.getBool(_autoplayKey) ?? true
  
  Future<void> toggleAutoplay(bool isEnabled) async {
    final currentState = state;
    if (currentState is! SettingsLoadedState) return;

    await _prefs.setBool(_autoplayKey, isEnabled);
    emit(currentState.copyWith(isAutoplayEnabled: isEnabled));
  }
}
```

#### [MODIFY] `lib/src/core/di/injection_container.dart`
Update `SettingsCubit` registration to include `sl()`.
```dart
-    ..registerFactory(() => SettingsCubit(sl()))
+    ..registerFactory(() => SettingsCubit(sl(), sl()))
```

---
### Settings UI
Adding the switch toggle on the settings page.

#### [MODIFY] `lib/src/features/settings/pages/settings_page.dart`
Add a "Playback" section with a `SwitchListTile`.
```dart
          // ── Playback Section ──────────────────────────────────────────
          const SectionHeader(title: 'Playback'),
          SliverToBoxAdapter(
            child: SettingsCard(
              child: BlocBuilder<SettingsCubit, SettingsState>(
                builder: (context, state) {
                  final isEnabled = state is SettingsLoadedState ? state.isAutoplayEnabled : true;
                  return SwitchListTile(
                    title: const Text('Autoplay Next Video'),
                    subtitle: const Text('Automatically play the next video in the playlist'),
                    value: isEnabled,
                    onChanged: state is SettingsLoadedState 
                        ? (val) => context.read<SettingsCubit>().toggleAutoplay(val) 
                        : null,
                  );
                },
              ),
            ),
          ),
```

---
### Playlist Logic & Player
Updating the playlist cubit to know how to play the next video, and the player to trigger it.

#### [MODIFY] `lib/src/features/playlist/viewmodels/playlist_detail_cubit.dart`
Inject `SharedPreferences` to instantly check if autoplay is enabled. Add `playNextVideo()`.
```dart
  PlaylistDetailCubit({required PlaylistRepository repository, required SharedPreferences prefs, this.playlistId})
    : _repository = repository,
      _prefs = prefs,
...
  Future<void> playNextVideo() async {
    final autoplay = _prefs.getBool('is_autoplay_enabled') ?? true;
    if (!autoplay) return;

    final currentState = state;
    if (currentState is PlaylistDetailLoaded) {
      final videos = currentState.videosState.videos;
      if (videos.isEmpty) return;

      final heroId = currentState.heroVideoState.heroVideo?.id ?? _selectedHeroId;
      if (heroId == null) return;

      final currentIndex = videos.indexWhere((v) => v.id == heroId);
      if (currentIndex != -1) {
        if (currentIndex + 1 < videos.length) {
          await selectVideo(videos[currentIndex + 1]);
        } else {
          // Loop back to start
          await selectVideo(videos.first);
        }
      }
    }
  }
```

#### [MODIFY] `lib/src/core/router/app_router.dart`
Update router to provide `prefs: di.sl()` to `PlaylistDetailCubit` everywhere it's instantiated.

#### [MODIFY] `lib/src/features/library/views/dashboard_widgets/dashboard_video_player.dart`
Trigger the new method when `PlayerState.ended` happens.
```dart
      if (value.playerState == PlayerState.ended) {
        _playlistDetailCubit.playNextVideo();
      }
```

## Verification Plan
### Manual Verification
1. Open the App and go to Settings.
2. Toggle "Autoplay Next Video" on/off to verify the UI updates and persists correctly.
3. Open a playlist, scrub near the end of a video, and wait for it to finish.
4. If Autoplay is ON, the next video should start automatically.
5. If Autoplay is OFF, playback should simply stop.
