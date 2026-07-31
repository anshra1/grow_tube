import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/config/app_config.dart';
import 'package:levelup_tube/src/core/design_system/app_theme.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/router/app_router.dart';
import 'package:levelup_tube/src/core/services/logging_service/talker_bloc_observer.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/widgets/pages/startup_error_app.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/app_update/widgets/app_update_listener.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/widgets/connectivity_toast_listener.dart';
import 'package:levelup_tube/src/features/navigation/cubit/fullscreen_video_cubit.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_cubit.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:toastification/toastification.dart';

late final Talker talker;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize global talker early so services like MigrationService can use it
  talker = TalkerFlutter.init();

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    }
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }

    return true;
  };

  // Initialize DI
  try {
    await di.init();
  } on AppConfigurationException catch (e, st) {
    await FirebaseCrashlytics.instance.recordError(
      e,
      st,
      reason: 'Failed to initialize DI',
    );
    runApp(
      StartupErrorApp(
        title: 'Configuration Error',
        message: e.userMessage,
        debugDetails: e.debugMessage,
      ),
    );
    return;
  }

  // Initialize Bloc Observer
  Bloc.observer = TalkerBlocObserver(talker: talker);

  runApp(const LevelUp());
}

class LevelUp extends StatelessWidget {
  const LevelUp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      config: const ToastificationConfig(maxToastLimit: 1),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<ThemeCubit>()..load()),
          BlocProvider(create: (context) => di.sl<ConnectivityCubit>()..initialize()),
          BlocProvider(create: (context) => FullscreenVideoCubit()),
          BlocProvider(create: (context) => di.sl<PipCubit>()),
          BlocProvider(create: (context) => di.sl<SettingsCubit>()),
          BlocProvider(create: (context) => di.sl<ClipboardCubit>()),
          BlocProvider(create: (context) => di.sl<AddCubit>()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'LevelUp',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeState.mode,
              routerConfig: AppRouter.router,
              builder: (context, child) {
                return _DismissKeyboardOnTap(
                  child: ConnectivityToastListener(
                    child: AppUpdateListener(child: child ?? const SizedBox.shrink()),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DismissKeyboardOnTap extends StatelessWidget {
  const _DismissKeyboardOnTap({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: child,
    );
  }
}
