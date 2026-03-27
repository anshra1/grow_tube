import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:levelup_tube/src/core/services/connectivity/internet_connection_service.dart';

enum ConnectivityStatus { unknown, online, offline }

class ConnectivityCubit extends Cubit<ConnectivityStatus>
    with WidgetsBindingObserver {
  ConnectivityCubit(this._service) : super(ConnectivityStatus.unknown) {
    WidgetsBinding.instance.addObserver(this);
  }

  final InternetConnectionService _service;
  StreamSubscription<InternetStatus>? _subscription;

  Future<void> initialize() async {
    await _refreshStatus();
    _subscribe();
  }

  Future<void> _refreshStatus() async {
    final hasAccess = await _service.hasInternetAccess;
    emit(hasAccess ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _service.onStatusChange.listen((status) {
      final next = status == InternetStatus.connected
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline;
      if (next != state) {
        emit(next);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshStatus();
      _subscribe();
    } else if (state == AppLifecycleState.paused) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  @override
  Future<void> close() {
    WidgetsBinding.instance.removeObserver(this);
    _subscription?.cancel();
    return super.close();
  }
}
