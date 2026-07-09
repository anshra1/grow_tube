import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/dashboard_page.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_detail_page.dart';
import 'package:levelup_tube/src/features/playlist/views/playlists_page.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    observers: [TalkerRouteObserver(TalkerFlutter.init())],
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(
        path: '/playlists',
        builder: (context, state) => const PlaylistsPage(),
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
  );
}
