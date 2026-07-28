import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/router/app_router.dart';
import 'package:levelup_tube/src/features/app_update/services/app_update_service.dart';
import 'package:levelup_tube/src/features/app_update/widgets/update_dialog.dart';

class AppUpdateListener extends StatefulWidget {
  const AppUpdateListener({required this.child, super.key});

  final Widget child;

  @override
  State<AppUpdateListener> createState() => _AppUpdateListenerState();
}

class _AppUpdateListenerState extends State<AppUpdateListener> with WidgetsBindingObserver {
  late final AppUpdateService _updateService;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _updateService = sl<AppUpdateService>();
    WidgetsBinding.instance.addObserver(this);
    _checkUpdate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkUpdate();
    }
  }

  Future<void> _checkUpdate() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final status = await _updateService.checkUpdate();
      if (!mounted) return;

      if (status == UpdateStatus.hardUpdate || status == UpdateStatus.softUpdate) {
        final isHardUpdate = status == UpdateStatus.hardUpdate;
        
        final dialogContext = AppRouter.rootNavigatorKey.currentContext;
        if (dialogContext == null) return;

        final result = await showDialog<bool>(
          // 
          // ignore: use_build_context_synchronously
          context: dialogContext,
          barrierDismissible: !isHardUpdate,
          builder: (context) => UpdateDialog(
            isHardUpdate: isHardUpdate,
            storeUrl: _updateService.storeUrl,
          ),
        );

        if (result ?? false) {
          await _updateService.skipUpdate(_updateService.latestAppVersion);
        }
      }
    } finally {
      if (mounted) {
        _isChecking = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
