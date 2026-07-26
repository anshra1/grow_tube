import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_button_state.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_state.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

class AddVideoForm extends StatefulWidget {
  const AddVideoForm({
    required this.urlController,
    super.key,
  });

  final TextEditingController urlController;

  @override
  State<AddVideoForm> createState() => _AddVideoFormState();
}

class _AddVideoFormState extends State<AddVideoForm> {
  final ValueNotifier<int?> _selectedPlaylistIdNotifier = ValueNotifier<int?>(null);

  @override
  void dispose() {
    _selectedPlaylistIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<AddCubit, AddState>(
      builder: (context, state) {
        final isAdding = state is AddLoading;
        List<PlaylistModel> playlists = [];
        
        if (state is AddInitial) {
          playlists = state.playlists;
          if (_selectedPlaylistIdNotifier.value == null && state.defaultPlaylistId != null) {
            _selectedPlaylistIdNotifier.value = state.defaultPlaylistId;
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: widget.urlController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'YouTube URL',
                hintText: 'https://youtube.com/watch?v=...',
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
            const Gap(24),
            ValueListenableBuilder<int?>(
              valueListenable: _selectedPlaylistIdNotifier,
              builder: (context, selectedPlaylistId, child) {
                return DropdownButtonFormField<int>(
                  value: selectedPlaylistId,
                  decoration: InputDecoration(
                    labelText: 'Select Playlist',
                    prefixIcon: const Icon(Icons.playlist_play),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  ),
                  onChanged: (value) {
                    _selectedPlaylistIdNotifier.value = value;
                  },
                  items: playlists.map((playlist) {
                    return DropdownMenuItem(
                      value: playlist.id,
                      child: Text(playlist.title),
                    );
                  }).toList(),
                );
              },
            ),
            const Gap(32),
            ListenableBuilder(
              listenable: Listenable.merge([
                widget.urlController,
                _selectedPlaylistIdNotifier,
              ]),
              builder: (context, child) {
                final isEnabled = widget.urlController.text.trim().isNotEmpty &&
                    _selectedPlaylistIdNotifier.value != null &&
                    !isAdding;

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
                          context.read<AddCubit>().addVideoToPlaylist(
                                _selectedPlaylistIdNotifier.value!,
                                widget.urlController.text.trim(),
                              );
                        }
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Text(
                    'Add Video',
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
