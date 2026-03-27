import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/connectivity/connectivity_cubit.dart';
import 'package:levelup_tube/src/core/connectivity/connectivity_toast_controller.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;

class ConnectivityToastListener extends StatefulWidget {
  const ConnectivityToastListener({required this.child, super.key});

  final Widget child;

  @override
  State<ConnectivityToastListener> createState() =>
      _ConnectivityToastListenerState();
}

class _ConnectivityToastListenerState extends State<ConnectivityToastListener> {
  ConnectivityStatus _previous = ConnectivityStatus.unknown;
  final ConnectivityToastController _toastController =
      di.sl<ConnectivityToastController>();

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
          _toastController.showOfflinePersistent();
          return;
        }

        if (state == ConnectivityStatus.online) {
          _toastController.dismissOffline();
          _toastController.showOnlineToast();
        }
      },
      child: widget.child,
    );
  }
}
