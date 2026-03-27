import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:toastification/toastification.dart';

class ConnectivityToastController {
  ToastificationItem? _offlineItem;
  DateTime? _lastNudgeAt;

  bool get isOfflineVisible => _offlineItem != null;

  void showOfflinePersistent() {
    if (_offlineItem != null) return;

    final item = toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: const Text(AppStrings.networkOfflineTitle),
      description: const Text(AppStrings.networkOfflineMessage),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(days: 365),
    );

    item.pause();
    _offlineItem = item;
  }

  void dismissOffline({bool showRemoveAnimation = true}) {
    final item = _offlineItem;
    if (item == null) return;

    toastification.dismiss(item, showRemoveAnimation: showRemoveAnimation);
    _offlineItem = null;
  }

  void showOnlineToast() {
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.fillColored,
      title: const Text(AppStrings.networkOnlineTitle),
      description: const Text(AppStrings.networkOnlineMessage),
      autoCloseDuration: const Duration(seconds: 4),
      alignment: Alignment.bottomCenter,
    );
  }

  void nudgeOffline() {
    if (_offlineItem == null) return;

    final now = DateTime.now();
    if (_lastNudgeAt != null &&
        now.difference(_lastNudgeAt!) < const Duration(seconds: 1)) {
      return;
    }
    _lastNudgeAt = now;

    dismissOffline(showRemoveAnimation: false);

    final item = toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.fillColored,
      title: const Text(AppStrings.networkOfflineTitle),
      description: const Text(AppStrings.networkOfflineMessage),
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(days: 365),
      animationDuration: const Duration(milliseconds: 450),
      animationBuilder: _shakeAnimation,
    );

    item.pause();
    _offlineItem = item;
  }

  Widget _shakeAnimation(
    BuildContext context,
    Animation<double> animation,
    Alignment alignment,
    Widget child,
  ) {
    final shake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

    return AnimatedBuilder(
      animation: shake,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(shake.value, 0),
          child: child,
        );
      },
    );
  }
}
