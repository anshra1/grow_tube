import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/src/core/design_system/app_theme.dart';
import 'package:skill_tube/src/core/di/injection_container.dart' as di;
import 'package:skill_tube/src/core/router/app_router.dart';
import 'package:skill_tube/src/core/utils/talker_bloc_observer.dart';
import 'package:talker_flutter/talker_flutter.dart';

late final Talker talker;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Talker
  talker = TalkerFlutter.init();

  // Initialize Bloc Observer
  Bloc.observer = TalkerBlocObserver(talker: talker);

  // Initialize DI
  await di.init();

  runApp(const SkillTubeApp());
}

class SkillTubeApp extends StatelessWidget {
  const SkillTubeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Skill Tube',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF137FEC), // Primary
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        extensions: [AppColorsExtension.light],
      ),
      routerConfig: AppRouter.router,
    );
  }
}
