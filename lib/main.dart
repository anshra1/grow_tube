import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/config/app_config.dart';
import 'package:levelup_tube/src/core/connectivity/connectivity_cubit.dart';
import 'package:levelup_tube/src/core/design_system/app_theme.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/router/app_router.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/utils/talker_bloc_observer.dart';
import 'package:levelup_tube/src/core/widgets/connectivity_toast_listener.dart';
import 'package:levelup_tube/src/core/widgets/startup_error_app.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';

import 'package:levelup_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_event.dart';

late final Talker talker;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };

  // Initialize Talker
  talker = TalkerFlutter.init();

  // Initialize Bloc Observer
  Bloc.observer = TalkerBlocObserver(talker: talker);

  // Initialize DI
  try {
    await di.init();
  } on AppConfigurationException catch (e) {
    runApp(
      StartupErrorApp(
        title: 'Configuration Error',
        message: e.userMessage,
        debugDetails: e.debugMessage,
      ),
    );
    return;
  }

  runApp(const GrowTubeApp());
}

class GrowTubeApp extends StatelessWidget {
  const GrowTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => di.sl<ThemeCubit>()..load(),
          ),
          BlocProvider(
            create: (context) => di.sl<ConnectivityCubit>()..initialize(),
          ),
          BlocProvider(
            create: (context) =>
                di.sl<LibraryBloc>()..add(const LibraryInitializedEvent()),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'LevelUp Tube',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeState.mode,
              routerConfig: AppRouter.router,
              builder: (context, child) {
                return ConnectivityToastListener(
                  child: child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
