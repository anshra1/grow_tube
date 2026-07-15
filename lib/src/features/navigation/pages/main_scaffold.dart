import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/mixins/clipboard_monitor_mixin.dart';
import 'package:levelup_tube/src/features/library/viewmodels/library_bloc.dart';
import 'package:levelup_tube/src/features/library/viewmodels/library_event.dart';
import 'package:levelup_tube/src/features/library/views/widgets/add_video_bottom_sheet.dart';
import 'package:levelup_tube/src/features/library/views/widgets/clipboard_playlist_prompt.dart';
import 'package:levelup_tube/src/features/library/views/widgets/clipboard_video_prompt.dart';
import 'package:levelup_tube/src/features/navigation/cubit/fullscreen_video_cubit.dart';
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
            context.read<LibraryBloc>().add(
              LibraryVideoAddedEvent(url),
            );
            toastification.dismiss(holder);
          },
          onWatch: () {
            context.read<LibraryBloc>().add(
              LibraryVideoAddedAndPlayRequested(url),
            );
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
            context.push(
              '/playlists?importUrl=${Uri.encodeComponent(url)}',
            );
          },
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _onDestinationSelected(int index) {
    // Index 2 is the "Add" action — intercept it and show a bottom sheet
    // instead of switching tabs. This is an intentional UX deviation from
    // standard tab conventions; the bottom nav item acts as an action button.
    if (index == 2) {
      _showAddBottomSheet();
      return;
    }

    // Map nav bar index → shell branch index.
    // The "Add" item at nav index 2 has no branch, so everything after it
    // is shifted by 1: nav 3 (Settings) → branch 2.
    final branchIndex = index > 2 ? index - 1 : index;

    // For all other tabs, switch the shell branch preserving navigator state.
    widget.navigationShell.goBranch(
      branchIndex,
      // If the user taps the currently active tab, scroll back to top.
      initialLocation:
          branchIndex == widget.navigationShell.currentIndex,
    );
  }

  void _showAddBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddVideoBottomSheet(
        onAdd: (url) {
          context.read<LibraryBloc>().add(
            LibraryVideoAddedEvent(url),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SettingsCubit>(
      create: (_) => sl<SettingsCubit>(),
      child: BlocListener<SettingsCubit, SettingsState>(
        // Only react when the loaded default playlist ID actually changes.
        listenWhen: (previous, current) {
          if (previous is SettingsLoadedState &&
              current is SettingsLoadedState) {
            return previous.defaultPlaylistId !=
                current.defaultPlaylistId;
          }
          return false;
        },
        listener: (context, state) {
          // Fire into LibraryBloc so the Home tab refreshes immediately.
          context.read<LibraryBloc>().add(
            const LibraryDefaultPlaylistChangedEvent(),
          );
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
      ),
    );
  }

  /// The "Add" destination (index 2) is never truly "selected" since it
  /// opens a bottom sheet instead of switching tabs. Map real branch indices
  /// to nav bar indices: branches 0,1,2 → nav items 0,1,3.
  int get _effectiveIndex {
    final branch = widget.navigationShell.currentIndex;
    return branch >= 2 ? branch + 1 : branch;
  }
}
