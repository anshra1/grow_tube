import 'package:flutter/material.dart';
import 'package:skill_tube/src/core/constants/app_strings.dart';
import 'package:skill_tube/src/core/design_system/app_sizes.dart';
import 'package:skill_tube/src/core/utils/extensions/context_extensions.dart';

class AddVideoBottomSheet extends StatefulWidget {
  const AddVideoBottomSheet({required this.onAdd, super.key});

  final ValueChanged<String> onAdd;

  @override
  State<AddVideoBottomSheet> createState() => _AddVideoBottomSheetState();
}

class _AddVideoBottomSheetState extends State<AddVideoBottomSheet> {
  final _controller = TextEditingController();

  void _submit() {
    final url = _controller.text.trim();
    if (url.isNotEmpty) {
      widget.onAdd(url);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSizes.p24,
        right: AppSizes.p24,
        top: AppSizes.p24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.dashboardAddVideo,
            style: context.textTheme.headlineSmall?.copyWith(
              color: context.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          gapH24,
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: AppStrings.dashboardYoutubeUrl,
              hintText: AppStrings.dashboardYoutubeUrlHint,
              border: const OutlineInputBorder(),
              labelStyle: TextStyle(color: context.colorScheme.onSurfaceVariant),
              hintStyle: TextStyle(color: context.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
            onSubmitted: (_) => _submit(),
            autofocus: true,
            style: TextStyle(color: context.colorScheme.onSurface),
          ),
          gapH24,
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
            ),
            child: const Text(AppStrings.dashboardAddToLibrary),
          ),
          gapH24,
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
