import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/features/clipboard/mixins/clipboard_monitor_mixin.dart';
import 'package:levelup_tube/src/features/clipboard/mixins/share_intent_monitor_mixin.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_cubit.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_state.dart';
import 'package:levelup_tube/src/features/clipboard/views/clipboard_playlist_prompt.dart';
import 'package:levelup_tube/src/features/clipboard/views/clipboard_video_prompt.dart';
import 'package:levelup_tube/src/features/navigation/cubit/fullscreen_video_cubit.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_cubit.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_state.dart';
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
    with WidgetsBindingObserver, ClipboardMonitorMixin, ShareIntentMonitorMixin {
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
            if (state is ClipboardVideoAddedState ||
                state is ClipboardNavigateToDashboardState ||
                state is ClipboardNavigateToPlaylistState) {
              Navigator.of(bottomSheetContext).pop();
            }
            if (state is ClipboardNavigateToDashboardState) {
              widget.navigationShell.goBranch(0);
              context.go('/', extra: state.url);
            }
            if (state is ClipboardNavigateToPlaylistState) {
              widget.navigationShell.goBranch(1);
              context.go('/playlists/${state.playlistId}', extra: state.url);
            }
            if (state is ClipboardVideoAlreadyExistsState) {
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

  @override
  void onShareUrlDetected(String url, String videoId) {
    // Route exactly to the clipboard handler
    onClipboardUrlDetected(url, videoId);
  }

  @override
  void onSharePlaylistDetected(String url, String playlistId) {
    // Route exactly to the clipboard handler
    onClipboardPlaylistDetected(url, playlistId);
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _onDestinationSelected(int index) {
    if (index == 3) {
      context.read<SettingsCubit>().loadAllPlaylist();
    }
    
    context.read<PipCubit>().setHomeTabActive(index == 0);

    // For all tabs, switch the shell branch preserving navigator state.
    widget.navigationShell.goBranch(
      index,
      // If the user taps the currently active tab, scroll back to top.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PipCubit, PipState>(
      listenWhen: (previous, current) => !previous.isInPipMode && current.isInPipMode,
      listener: (context, pipState) {
        if (pipState.isInPipMode && widget.navigationShell.currentIndex != 0) {
          widget.navigationShell.goBranch(0);
        }
      },
      child: BlocBuilder<PipCubit, PipState>(
        builder: (context, pipState) {
          return BlocBuilder<FullscreenVideoCubit, bool>(
            builder: (context, isFullscreen) {
              final hideNavigation = isFullscreen || pipState.isInPipMode;
            return Scaffold(
              body: widget.navigationShell,
              bottomNavigationBar: hideNavigation
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
      },
      ),
    );
  }

  int get _effectiveIndex => widget.navigationShell.currentIndex;
}
