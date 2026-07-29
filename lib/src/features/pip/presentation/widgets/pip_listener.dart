import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_cubit.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_state.dart';

/// A widget that listens to PiP state changes and calls back
/// so the parent can show/hide UI accordingly.
///
/// Usage:
/// ```dart
/// PipListener(
///   onPipEntered: () {
///     // Hide controls, show minimal video UI
///   },
///   onPipExited: () {
///     // Restore full UI
///   },
///   child: YourVideoPlayerWidget(),
/// )
/// ```
class PipListener extends StatelessWidget {
  const PipListener({
    required this.child,
    super.key,
    this.onPipEntered,
    this.onPipExited,
  });

  final Widget child;
  final VoidCallback? onPipEntered;
  final VoidCallback? onPipExited;

  @override
  Widget build(BuildContext context) {
    return BlocListener<PipCubit, PipState>(
      listenWhen: (previous, current) =>
          previous.isInPipMode != current.isInPipMode,
      listener: (context, state) {
        if (state.isInPipMode) {
          onPipEntered?.call();
        } else {
          onPipExited?.call();
        }
      },
      child: child,
    );
  }
}
