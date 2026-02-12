import 'package:flutter/material.dart';

class AppKeyboardDismiss extends StatelessWidget {
  const AppKeyboardDismiss({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
