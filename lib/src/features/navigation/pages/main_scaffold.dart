import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/mixins/clipboard_monitor_mixin.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/clipboard_playlist_prompt.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/clipboard_video_prompt.dart';
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
    toastification.showCustom(
      context: context,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 10),
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      builder: (context, holder) {
        return ClipboardVideoPrompt(
          url: url,
          onDismiss: () => toastification.dismiss(holder),
          onAdd: () {
            context.read<PlaylistDetailCubit>().addVideo(url);
            toastification.dismiss(holder);
          },
          onWatch: () {
            context.read<PlaylistDetailCubit>().addAndPlayVideo(url);
            toastification.dismiss(holder);
          },
        );
      },
    );
  }

  @override
  void onClipboardPlaylistDetected(String url, String playlistId) {
    toastification.showCustom(
      context: context,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 10),
      animationBuilder: (context, animation, alignment, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
      builder: (context, holder) {
        return ClipboardPlaylistPrompt(
          url: url,
          onDismiss: () => toastification.dismiss(holder),
          onImport: () {
            toastification.dismiss(holder);
            // Push above the shell (full-screen, no bottom bar) using root navigator.
            // This avoids deep-link conflicts with the shell branch routing.
            context.push('/playlists?importUrl=${Uri.encodeComponent(url)}');
          },
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
    return BlocListener<SettingsCubit, SettingsState>(
      // Only react when the loaded default playlist ID actually changes.
      listenWhen: (previous, current) {
        if (previous is SettingsLoadedState && current is SettingsLoadedState) {
          return previous.defaultPlaylistId != current.defaultPlaylistId;
        }
        return false;
      },
      listener: (context, state) {
        context.read<PlaylistDetailCubit>().onDefaultPlaylistChanged();
      },
      child: BlocBuilder<FullscreenVideoCubit, bool>(
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
      ),
    );
  }

  int get _effectiveIndex => widget.navigationShell.currentIndex;
}
