import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';
import 'package:skill_tube/src/core/widgets/app_keyboard_dismiss.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.useSafeArea = true,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    var content = body;

    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    return AppKeyboardDismiss(
      child: Scaffold(
        appBar: appBar,
        backgroundColor: context.colorScheme.surface,
        body: content,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
