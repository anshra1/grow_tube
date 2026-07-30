import 'package:flutter/services.dart';

/// Service that wraps the native PiP MethodChannel.
///
/// This communicates with `com.ansh.levelup_tube/pip` registered
/// in `MainActivity.kt`. The native side is already configured —
/// this Dart service can be shipped later via Shorebird OTA.
class PipService {
  PipService() {
    _channel.setMethodCallHandler(_handleNativeCall);
  }

  static const _channel = MethodChannel('com.ansh.levelup_tube/pip');

  /// Stream controller is not used here to keep it lightweight.
  /// The cubit will set this callback.
  void Function({required bool isInPipMode})? onPipChanged;

  /// Enters Picture-in-Picture mode with the given aspect ratio.
  /// Returns `true` if PiP was entered successfully.
  Future<bool> enterPipMode({int width = 16, int height = 9}) async {
    final result = await _channel.invokeMethod<bool>(
      'enterPipMode',
      {'width': width, 'height': height},
    );
    return result ?? false;
  }

  /// Sets whether the app should seamlessly auto-enter PiP mode.
  // ignore: avoid_positional_boolean_parameters
  Future<void> setAutoEnterPip(bool enabled) async {
    try {
      await _channel.invokeMethod('setAutoEnterPip', {'enabled': enabled});
    } on PlatformException catch (_) {}
  }

  /// Checks whether the device supports PiP (Android 8.0+).
  Future<bool> isPipSupported() async {
    final result = await _channel.invokeMethod<bool>('isPipSupported');
    return result ?? false;
  }

  /// Checks whether the app is currently in PiP mode.
  Future<bool> isPipActive() async {
    final result = await _channel.invokeMethod<bool>('isPipActive');
    return result ?? false;
  }

  /// Handles calls coming from the native side (e.g. PiP state changes).
  Future<void> _handleNativeCall(MethodCall call) async {
    if (call.method == 'onPipChanged') {
      final isInPip = call.arguments as bool;
      onPipChanged?.call(isInPipMode: isInPip);
    }
  }

  /// Cleans up the handler.
  void dispose() {
    onPipChanged = null;
    _channel.setMethodCallHandler(null);
  }
}
