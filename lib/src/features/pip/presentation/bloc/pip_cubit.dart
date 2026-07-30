import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/pip/data/pip_service.dart';
import 'package:levelup_tube/src/features/pip/presentation/bloc/pip_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages Picture-in-Picture state.
///
/// Uses a simple `bool` state — `true` when in PiP, `false` otherwise.
/// Follows the same pattern as `ConnectivityCubit`.
class PipCubit extends Cubit<PipState> {
  PipCubit(this._service, this._prefs) : super(const PipState()) {
    _service.onPipChanged = ({required bool isInPipMode}) {
      _onPipChanged(isInPipMode);
    };
    final isEnabled = _prefs.getBool('pip_enabled') ?? true;
    emit(state.copyWith(isEnabled: isEnabled));
    _checkSupport();
  }

  final PipService _service;
  final SharedPreferences _prefs;

  bool _isVideoPlaying = false;
  bool _isHomeTabActive = true;

  Future<void> _checkSupport() async {
    final supported = await _service.isPipSupported();
    emit(state.copyWith(isSupported: supported));
    _updateAutoPip();
  }

  void _onPipChanged(bool isInPipMode) {
    emit(state.copyWith(isInPipMode: isInPipMode));
  }

  /// Call this to enter PiP mode (e.g. when video goes fullscreen
  /// or user navigates away while video is playing).
  Future<void> enterPipMode({int width = 16, int height = 9}) async {
    if (!state.isSupported || !state.isEnabled) return;

    final entered = await _service.enterPipMode(width: width, height: height);

    if (entered) {
      emit(state.copyWith(isInPipMode: true));
    }
  }

  Future<void> setPipEnabled({required bool enabled}) async {
    await _prefs.setBool('pip_enabled', enabled);
    emit(state.copyWith(isEnabled: enabled));
    _updateAutoPip();
  }
  // 
  // ignore: avoid_positional_boolean_parameters
  void setVideoPlaying(bool playing) {
    if (_isVideoPlaying == playing) return;
    _isVideoPlaying = playing;
    _updateAutoPip();
  }

  //
  // ignore: avoid_positional_boolean_parameters
  void setHomeTabActive(bool active) {
    if (_isHomeTabActive == active) return;
    _isHomeTabActive = active;
    _updateAutoPip();
  }

  void _updateAutoPip() {
    if (!state.isSupported) return;
    final shouldAutoEnter = _isVideoPlaying && _isHomeTabActive && state.isEnabled;
    _service.setAutoEnterPip(shouldAutoEnter);
  }

  @override
  Future<void> close() {
    _service.dispose();
    return super.close();
  }
}
