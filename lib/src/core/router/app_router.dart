import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard_page.dart';
import 'package:levelup_tube/src/features/navigation/presentation/pages/main_scaffold.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_detail_page.dart';
import 'package:levelup_tube/src/features/playlist/views/playlists_page.dart';
import 'package:levelup_tube/src/features/settings/presentation/pages/settings_page.dart';
import 'package:talker_flutter/talker_flutter.dart';

// Root navigator key — used for pushes that appear above the shell
// (e.g., the playlist import flow triggered from the clipboard toast).
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

// Per-branch navigator keys — each branch maintains its own back-stack.
final GlobalKey<NavigatorState> _homeNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _playlistsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'playlists');
final GlobalKey<NavigatorState> _settingsNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    observers: [TalkerRouteObserver(TalkerFlutter.init())],
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
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Branch 1 — Playlists
          StatefulShellBranch(
            navigatorKey: _playlistsNavigatorKey,
            routes: [
              GoRoute(
                path: '/playlists',
                builder: (context, state) {
                  // importUrl is only present when navigating from the
                  // clipboard toast inside the shell branch (not via push above).
                  final importUrl = state.uri.queryParameters['importUrl'];
                  return PlaylistsPage(importUrl: importUrl);
                },
                routes: [
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final id = int.parse(state.pathParameters['id']!);
                      return PlaylistDetailPage(playlistId: id);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 2 — Settings
          StatefulShellBranch(
            navigatorKey: _settingsNavigatorKey,
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // ── Above-shell route: playlist import pushed from clipboard toast ──
      // Uses parentNavigatorKey: _rootNavigatorKey so it renders above the
      // shell (full-screen, bottom nav bar hidden) — avoids shell branch conflicts.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/playlists',
        builder: (context, state) {
          final importUrl = state.uri.queryParameters['importUrl'];
          return PlaylistsPage(importUrl: importUrl);
        },
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: ':id',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return PlaylistDetailPage(playlistId: id);
            },
          ),
        ],
      ),
    ],
  );
}
