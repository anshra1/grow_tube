import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/features/add/views/add_page.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_page.dart';
import 'package:levelup_tube/src/features/navigation/pages/main_scaffold.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:levelup_tube/src/features/playlist/views/edit_playlist_page.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_detail_page.dart';
import 'package:levelup_tube/src/features/playlist/views/playlists_page.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_cubit.dart';
import 'package:levelup_tube/src/features/settings/pages/settings_page.dart';

// (e.g., the playlist import flow triggered from the clipboard toast).
// Moved inside AppRouter as a static property below.

// Per-branch navigator keys — each branch maintains its own back-stack.
final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'home',
);
final GlobalKey<NavigatorState> _playlistsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'playlists',
);
final GlobalKey<NavigatorState> _settingsNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'settings',
);

CustomTransitionPage<T> _buildPageWithSlideTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    },
  );
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: 'root',
  );

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    observers: [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)],
    routes: [
      // ── Shell: wraps Home, Playlists, and Settings with the bottom nav bar ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0 — Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) {
                  final url = state.extra as String?;
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: BlocProvider(
                      create: (_) =>
                          PlaylistDetailCubit(repository: di.sl())..loadAndPlay(url),
                      child: const DashboardPage(),
                    ),
                  );
                },
              ),
            ],
          ),

          // Branch 1 — Playlists
          StatefulShellBranch(
            navigatorKey: _playlistsNavigatorKey,
            routes: [
              GoRoute(
                path: '/playlists',
                pageBuilder: (context, state) {
                  // importUrl is only present when navigating from the
                  // clipboard toast inside the shell branch (not via push above).
                  final importUrl = state.uri.queryParameters['importUrl'];
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: BlocProvider(
                      create: (_) {
                        final cubit = di.sl<PlaylistCubit>();
                        if (importUrl != null) {
                          cubit.loadAndImport(importUrl);
                        } else {
                          cubit.loadPlaylists();
                        }
                        return cubit;
                      },
                      child: const PlaylistsPage(),
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: ':id',
                    pageBuilder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      final url = state.extra as String?;
                      return _buildPageWithSlideTransition(
                        context: context,
                        state: state,
                        child: BlocProvider(
                          create: (_) =>
                              PlaylistDetailCubit(playlistId: id, repository: di.sl())
                                ..loadAndPlay(url),
                          child: const PlaylistDetailPage(),
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'editPlaylistPage',
                    pageBuilder: (context, state) {
                      final playlistModel = state.extra! as PlaylistModel;
                      return _buildPageWithSlideTransition(
                        context: context,
                        state: state,
                        child: BlocProvider(
                          create: (_) => PlaylistDetailCubit(
                            playlistId: playlistModel.id,
                            repository: di.sl(),
                          ),
                          child: EditPlaylistPage(playlistModel: playlistModel),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2 — Add
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/add',
                pageBuilder: (context, state) {
                  final tabStr = state.uri.queryParameters['tab'];
                  final initialTab = tabStr != null ? int.tryParse(tabStr) ?? 0 : 0;
                  return _buildPageWithSlideTransition(
                    context: context,
                    state: state,
                    child: AddPage(initialTab: initialTab),
                  );
                },
              ),
            ],
          ),

          // Branch 3 — Settings
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                pageBuilder: (context, state) => _buildPageWithSlideTransition(
                  context: context,
                  state: state,
                  child: const SettingsPage(),
                ),
              ),
            ],
          ),
        ],
      ),

      // ── Above-shell route: playlist import pushed from clipboard toast ──
      // Uses parentNavigatorKey: rootNavigatorKey so it renders above the
      // shell (full-screen, bottom nav bar hidden) — avoids shell branch conflicts.
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: '/playlists',
        pageBuilder: (context, state) {
          final importUrl = state.uri.queryParameters['importUrl'];
          return _buildPageWithSlideTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (_) {
                final cubit = di.sl<PlaylistCubit>();
                if (importUrl != null) {
                  cubit.loadAndImport(importUrl);
                } else {
                  cubit.loadPlaylists();
                }
                return cubit;
              },
              child: const PlaylistsPage(),
            ),
          );
        },
        routes: [
          GoRoute(
            parentNavigatorKey: rootNavigatorKey,
            path: ':id',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final url = state.extra as String?;
              return _buildPageWithSlideTransition(
                context: context,
                state: state,
                child: BlocProvider(
                  create: (_) =>
                      PlaylistDetailCubit(playlistId: id, repository: di.sl())
                        ..loadAndPlay(url),
                  child: const PlaylistDetailPage(),
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
