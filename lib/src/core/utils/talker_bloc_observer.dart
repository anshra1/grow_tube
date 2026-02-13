import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skill_tube/main.dart';
import 'package:talker_flutter/talker_flutter.dart';

class TalkerBlocObserver extends BlocObserver {
  TalkerBlocObserver({
    required this.talker,
  });

  final Talker talker;

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    talker.logCustom(
      TalkerLog(
        'EVENT: ${bloc.runtimeType} -> $event',
        logLevel: LogLevel.debug,
      ),
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    talker.logCustom(
      TalkerLog(
        'TRANSITION: ${bloc.runtimeType} -> ${transition.currentState} to ${transition.nextState}',
        logLevel: LogLevel.debug,
      ),
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    talker.handle(error, stackTrace, 'BLOC ERROR: ${bloc.runtimeType}');
  }
}
