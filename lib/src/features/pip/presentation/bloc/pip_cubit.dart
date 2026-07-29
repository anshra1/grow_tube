import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/pip/data/pip_service.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_state.dart';

/// Manages Picture-in-Picture state.
///
/// Uses a simple `bool` state — `true` when in PiP, `false` otherwise.
/// Follows the same pattern as `ConnectivityCubit`.
class PipCubit extends Cubit<PipState> {
  PipCubit(this._service) : super(const PipState()) {
    _service.onPipChanged = ({required bool isInPipMode}) {
      _onPipChanged(isInPipMode);
    };
    _checkSupport();
  }

  final PipService _service;

  Future<void> _checkSupport() async {
    final supported = await _service.isPipSupported();
    emit(state.copyWith(isSupported: supported));
  }

  void _onPipChanged(bool isInPipMode) {
    emit(state.copyWith(isInPipMode: isInPipMode));
  }

  /// Call this to enter PiP mode (e.g. when video goes fullscreen
  /// or user navigates away while video is playing).
  Future<void> enterPipMode({int width = 16, int height = 9}) async {
    if (!state.isSupported) return;

    final entered = await _service.enterPipMode(width: width, height: height);

    if (entered) {
      emit(state.copyWith(isInPipMode: true));
    }
  }

  @override
  Future<void> close() {
    _service.dispose();
    return super.close();
  }
}
