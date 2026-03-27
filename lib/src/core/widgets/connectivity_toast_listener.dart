import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/connectivity/connectivity_cubit.dart';
import 'package:levelup_tube/src/core/constants/app_strings.dart';
import 'package:toastification/toastification.dart';

class ConnectivityToastListener extends StatefulWidget {
  const ConnectivityToastListener({required this.child, super.key});

  final Widget child;

  @override
  State<ConnectivityToastListener> createState() =>
      _ConnectivityToastListenerState();
}

class _ConnectivityToastListenerState extends State<ConnectivityToastListener> {
  ConnectivityStatus _previous = ConnectivityStatus.unknown;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityStatus>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        final previous = _previous;
        _previous = state;

        if (previous == ConnectivityStatus.unknown &&
            state == ConnectivityStatus.online) {
          return;
        }

        if (state == ConnectivityStatus.offline) {
          toastification.show(
            type: ToastificationType.error,
            style: ToastificationStyle.fillColored,
            title: const Text(AppStrings.networkOfflineTitle),
            description: const Text(AppStrings.networkOfflineMessage),
            autoCloseDuration: const Duration(seconds: 4),
            alignment: Alignment.bottomCenter,
          );
          return;
        }

        if (state == ConnectivityStatus.online) {
          toastification.show(
            type: ToastificationType.success,
            style: ToastificationStyle.fillColored,
            title: const Text(AppStrings.networkOnlineTitle),
            description: const Text(AppStrings.networkOnlineMessage),
            autoCloseDuration: const Duration(seconds: 4),
            alignment: Alignment.bottomCenter,
          );
        }
      },
      child: widget.child,
    );
  }
}
