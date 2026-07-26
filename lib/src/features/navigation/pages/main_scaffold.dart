import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/features/clipboard/mixins/clipboard_monitor_mixin.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_cubit.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_state.dart';
import 'package:levelup_tube/src/features/clipboard/views/clipboard_playlist_prompt.dart';
import 'package:levelup_tube/src/features/clipboard/views/clipboard_video_prompt.dart';
import 'package:levelup_tube/src/features/navigation/cubit/fullscreen_video_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:toastification/toastification.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({required this.navigationShell, super.key});

  /// Provided by [StatefulShellRoute] — gives us the current branch index
  /// and the ability to switch branches while preserving state.
  final StatefulNavigationShell navigationShell;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with WidgetsBindingObserver, ClipboardMonitorMixin {
  // ---------------------------------------------------------------------------
  // ClipboardMonitorMixin overrides
  // (Mixin lives here so clipboard detection works on ALL tabs, not just Home)
  // ---------------------------------------------------------------------------

  @override
  void onClipboardUrlDetected(String url, String videoId) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Let the prompt widget draw its own background/radius
      builder: (bottomSheetContext) {
        return BlocListener<ClipboardCubit, ClipboardState>(
          listener: (context, state) {
            talker.debug('MainScaffold BlocListener: Received state $state');
            if (state is ClipboardVideoAddedState ||
                state is ClipboardNavigateToDashboardState ||
                state is ClipboardNavigateToPlaylistState) {
              Navigator.of(bottomSheetContext).pop();
            }
            if (state is ClipboardNavigateToDashboardState) {
              talker.debug('MainScaffold: Navigating to Dashboard with url ${state.url}');
              widget.navigationShell.goBranch(0);
              context.go('/', extra: state.url);
            }
            if (state is ClipboardNavigateToPlaylistState) {
              talker.debug(
                'MainScaffold: Navigating to Playlist ${state.playlistId} with url ${state.url}',
              );
              widget.navigationShell.goBranch(1);
              context.go('/playlists/${state.playlistId}', extra: state.url);
            }
            if (state is ClipboardVideoAlreadyExistsState) {
              talker.debug('MainScaffold: Showing Already Exists warning toast');
              toastification.show(
                context: context,
                type: ToastificationType.warning,
                title: const Text('Already in playlist'),
                description: const Text(
                  'This video is already in the selected playlist.',
                ),
                autoCloseDuration: const Duration(seconds: 3),
                alignment: Alignment.bottomCenter,
              );
            }
          },
          child: SafeArea(
            child: ClipboardVideoPrompt(
              url: url,
              onDismiss: () => Navigator.of(bottomSheetContext).pop(),
            ),
          ),
        );
      },
    );
  }

  @override
  void onClipboardPlaylistDetected(String url, String playlistId) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Let the prompt widget draw its own background/radius
      builder: (bottomSheetContext) {
        return SafeArea(
          child: ClipboardPlaylistPrompt(
            url: url,
            onDismiss: () => Navigator.of(bottomSheetContext).pop(),
            onImport: () {
              Navigator.of(bottomSheetContext).pop();
              // Push above the shell (full-screen, no bottom bar) using root navigator.
              // This avoids deep-link conflicts with the shell branch routing.
              context.push('/playlists?importUrl=${Uri.encodeComponent(url)}');
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _onDestinationSelected(int index) {
    if (index == 3) {
      context.read<SettingsCubit>().loadAllPlaylist();
    }
    // For all tabs, switch the shell branch preserving navigator state.
    widget.navigationShell.goBranch(
      index,
      // If the user taps the currently active tab, scroll back to top.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  // void _showAddBottomSheet() {
  //   showModalBottomSheet<void>(
  //     context: context,
  //     isScrollControlled: true,
  //     useSafeArea: true,
  //     builder: (_) => AddVideoBottomSheet(
  //       onAdd: (url) {
  //         context.read<PlaylistDetailCubit>().addVideo(url);
  //       },
  //     ),
  //   );
  // }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FullscreenVideoCubit, bool>(
        builder: (context, isFullscreen) {
          return Scaffold(
            body: widget.navigationShell,
            bottomNavigationBar: isFullscreen
                ? null
                : NavigationBar(
                    selectedIndex: _effectiveIndex,
                    onDestinationSelected: _onDestinationSelected,
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.home_outlined),
                        selectedIcon: Icon(Icons.home),
                        label: 'Home',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.playlist_play_outlined),
                        selectedIcon: Icon(Icons.playlist_play),
                        label: 'Playlists',
                      ),
                      // "Add" is an action, not a tab — visual affordance only.
                      NavigationDestination(
                        icon: Icon(Icons.add_circle_outline),
                        selectedIcon: Icon(Icons.add_circle),
                        label: 'Add',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: 'Settings',
                      ),
                    ],
                  ),
          );
        },
      );
  }

  int get _effectiveIndex => widget.navigationShell.currentIndex;
}
