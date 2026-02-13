import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:skill_tube/src/core/di/injection_container.dart' as di;
import 'package:skill_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:skill_tube/src/features/library/presentation/pages/dashboard/dashboard_page.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    observers: [TalkerRouteObserver(TalkerFlutter.init())],
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider(
          create: (_) => di.sl<LibraryBloc>(),
          child: const DashboardPage(),
        ),
      ),
    ],
  );
}
