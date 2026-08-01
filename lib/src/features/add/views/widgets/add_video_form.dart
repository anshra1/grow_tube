import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_button_state.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_state.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/playlist_selector.dart';
import 'package:shimmer/shimmer.dart';

class AddVideoForm extends StatefulWidget {
  const AddVideoForm({
    required this.urlController,
    required this.selectedPlaylistIdNotifier,
    super.key,
  });

  final TextEditingController urlController;
  final ValueNotifier<int?> selectedPlaylistIdNotifier;

  @override
  State<AddVideoForm> createState() => _AddVideoFormState();
}

class _AddVideoFormState extends State<AddVideoForm> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AddCubit, AddState>(
      listenWhen: (previous, current) => current is AddInitial,
      buildWhen: (previous, current) =>
          current is AddInitial ||
          current is AddLoading ||
          current is AddVideoSuccess ||
          current is AddError,
      listener: (context, state) {
        if (state is AddInitial &&
            widget.selectedPlaylistIdNotifier.value == null &&
            state.defaultPlaylistId != null) {
          widget.selectedPlaylistIdNotifier.value = state.defaultPlaylistId;
        }
      },
      builder: (context, state) {
        final isAdding = state is AddLoading;

        List<PlaylistModel>? playlists;
        if (state is AddInitial) {
          playlists = state.playlists;
        } else if (context.read<AddCubit>().state is AddInitial) {
          playlists = (context.read<AddCubit>().state as AddInitial).playlists;
        }

        final isLoadingPlaylists = playlists == null;

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
            if (isLoadingPlaylists)
              Shimmer.fromColors(
                baseColor: theme.colorScheme.surfaceContainerHighest,
                highlightColor: theme.colorScheme.surface,
                child: Container(
                  height: 60, // approximate height of dropdown
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )
            else
              ValueListenableBuilder<int?>(
                valueListenable: widget.selectedPlaylistIdNotifier,
                builder: (context, selectedPlaylistId, child) {
                  return PlaylistSelector(
                    playlists: playlists!,
                    selectedId: selectedPlaylistId,
                    onChanged: (value) {
                      widget.selectedPlaylistIdNotifier.value = value;
                    },
                  );
                },
              ),
            const Gap(32),
            ValueListenableBuilder<int?>(
              valueListenable: widget.selectedPlaylistIdNotifier,
              builder: (context, selectedPlaylistId, child) {
                return ListenableBuilder(
                  listenable: widget.urlController,
                  builder: (context, child) {
                    final effectivePlaylistId = selectedPlaylistId ??
                        (playlists?.isNotEmpty ?? false ? playlists!.first.id : null);

                    final isEnabled = widget.urlController.text.trim().isNotEmpty &&
                        effectivePlaylistId != null &&
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
                                effectivePlaylistId,
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
                );
              },
            ),
          ],
        );
      },
    );
  }
}
