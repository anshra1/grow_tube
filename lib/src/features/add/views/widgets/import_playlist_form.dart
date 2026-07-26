import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_button_state.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_state.dart';

class ImportPlaylistForm extends StatefulWidget {
  const ImportPlaylistForm({
    required this.urlController,
    super.key,
  });

  final TextEditingController urlController;

  @override
  State<ImportPlaylistForm> createState() => _ImportPlaylistFormState();
}

class _ImportPlaylistFormState extends State<ImportPlaylistForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AddCubit, AddState>(
      builder: (context, state) {
        final isAdding = state is AddLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget.urlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'YouTube Playlist URL',
                hintText: 'https://youtube.com/playlist?list=...',
                prefixIcon: const Icon(Icons.link),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const Gap(32),
            ListenableBuilder(
              listenable: widget.urlController,
              builder: (context, child) {
                final isEnabled = widget.urlController.text.trim().isNotEmpty && !isAdding;

                AppButtonState buttonState;
                if (isAdding) {
                  buttonState = AppButtonState.loading;
                } else if (isEnabled) {
                  buttonState = AppButtonState.enabled;
                } else {
                  buttonState = AppButtonState.disabled;
                }

                return AppPrimaryButton(
                  state: buttonState,
                  onPressed: isEnabled
                      ? () {
                          context.read<AddCubit>().importPlaylist(
                                widget.urlController.text.trim(),
                              );
                        }
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Text(
                    'Import Playlist',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
