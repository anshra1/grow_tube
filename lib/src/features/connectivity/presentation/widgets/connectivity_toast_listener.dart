import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart'
    as di;
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/widgets/connectivity_toast_controller.dart';

class ConnectivityToastListener extends StatefulWidget {
  const ConnectivityToastListener({required this.child, super.key});

  final Widget child;

  @override
  State<ConnectivityToastListener> createState() =>
      _ConnectivityToastListenerState();
}

class _ConnectivityToastListenerState
    extends State<ConnectivityToastListener> {
  ConnectivityStatus _previous = ConnectivityStatus.unknown;
  final ConnectivityToastController _toastController = di
      .sl<ConnectivityToastController>();
  Timer? _offlineTimer;

  @override
  void dispose() {
    _offlineTimer?.cancel();
    super.dispose();
  }

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
          _offlineTimer?.cancel();
          _offlineTimer = Timer(const Duration(seconds: 3), () {
            if (mounted && _previous == ConnectivityStatus.offline) {
              _toastController.showOfflinePersistent();
            }
          });
          return;
        }

        if (state == ConnectivityStatus.online) {
          _offlineTimer?.cancel();
          if (_toastController.isOfflineVisible) {
            _toastController..dismissOffline()
            ..showOnlineToast();
          }
        }
      },
      child: widget.child,
    );
  }
}
