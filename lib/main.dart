import 'dart:async';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:levelup_tube/firebase_options.dart';
import 'package:levelup_tube/src/core/design_system/app_theme.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/router/app_router.dart';
import 'package:levelup_tube/src/core/theme/theme_cubit.dart';
import 'package:levelup_tube/src/core/utils/talker_bloc_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

import 'package:levelup_tube/src/features/library/presentation/bloc/library_bloc.dart';
import 'package:levelup_tube/src/features/library/presentation/bloc/library_event.dart';

late final Talker talker;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  FlutterError.onError = (errorDetails) {
  //  FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
 //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Initialize Talker
  talker = TalkerFlutter.init();

  // Initialize Bloc Observer
  Bloc.observer = TalkerBlocObserver(talker: talker);

  // Initialize DI
  await di.init();

  runApp(const GrowTubeApp());
}

class GrowTubeApp extends StatelessWidget {
  const GrowTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<ThemeCubit>()..load(),
        ),
        BlocProvider(
          create: (context) => di.sl<LibraryBloc>()..add(const LibraryInitializedEvent()),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final effectiveMode = themeState.mode == ThemeMode.system
              ? (themeState.platformBrightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light)
              : themeState.mode;
          return MaterialApp.router(
            title: 'Grow Tube',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: effectiveMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
