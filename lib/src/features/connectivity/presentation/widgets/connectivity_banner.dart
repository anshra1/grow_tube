import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/features/connectivity/presentation/bloc/connectivity_cubit.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  ConnectivityStatus _previousStatus = ConnectivityStatus.unknown;
  bool _showBanner = false;
  bool _isOffline = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, ConnectivityStatus>(
      listenWhen: (previous, current) => previous != current,
      listener: (context, state) {
        final previous = _previousStatus;
        _previousStatus = state;

        if (state == ConnectivityStatus.offline) {
          _hideTimer?.cancel();
          setState(() {
            _showBanner = true;
            _isOffline = true;
          });
        } else if (state == ConnectivityStatus.online && previous == ConnectivityStatus.offline) {
          // Transitioned from offline to online
          setState(() {
            _showBanner = true;
            _isOffline = false;
          });
          
          // Hide after 3 seconds
          _hideTimer?.cancel();
          _hideTimer = Timer(const Duration(seconds: 3), () {
            if (mounted) {
              setState(() {
                _showBanner = false;
              });
            }
          });
        } else if (state == ConnectivityStatus.online && previous == ConnectivityStatus.unknown) {
           // Initial app launch, online, do nothing
           setState(() {
             _showBanner = false;
           });
        }
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.topCenter,
        curve: Curves.easeInOut,
        child: _showBanner
            ? Container(
                width: double.infinity,
                color: _isOffline ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  _isOffline ? 'No connection' : 'Back online',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }
}
