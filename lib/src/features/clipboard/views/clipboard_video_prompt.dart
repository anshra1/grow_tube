import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/main.dart';
import 'package:levelup_tube/src/core/constants/app_icons.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_cubit.dart';
import 'package:levelup_tube/src/features/clipboard/viewmodels/clipboard_state.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/playlist_selector.dart';

class ClipboardVideoPrompt extends StatefulWidget {
  const ClipboardVideoPrompt({required this.url, required this.onDismiss, super.key});

  final String url;
  final VoidCallback onDismiss;

  @override
  State<ClipboardVideoPrompt> createState() => _ClipboardVideoPromptState();
}

class _ClipboardVideoPromptState extends State<ClipboardVideoPrompt> {
  @override
  void initState() {
    super.initState();
    context.read<ClipboardCubit>().loadPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return BlocBuilder<ClipboardCubit, ClipboardState>(
      buildWhen: (previous, current) {
        talker.debug(
          'ClipboardVideoPrompt buildWhen: previous=$previous, current=$current',
        );
        return current is ClipboardPlaylistsLoadedState ||
            current is ClipboardLoadingState ||
            current is ClipboardInitial;
      },
      builder: (context, state) {
        talker.debug('ClipboardVideoPrompt builder: state=$state');
        final playlists = state is ClipboardPlaylistsLoadedState
            ? state.playlists
            : <PlaylistModel>[];
        final selectedId = state is ClipboardPlaylistsLoadedState
            ? state.selectedPlaylistId
            : null;
        final defaultId = state is ClipboardPlaylistsLoadedState
            ? state.defaultPlaylistId
            : null;
        final isLoading = state is ClipboardLoadingState || state is ClipboardInitial;

        return Container(
          padding: const EdgeInsets.only(
            left: AppSizes.p16,
            right: AppSizes.p16,
            bottom: AppSizes.p24,
            top: AppSizes.p8,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSizes.p24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.p16),
                  decoration: BoxDecoration(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(AppSizes.p2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF0000).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: const Icon(AppIcons.play, color: Color(0xFFFF0000)),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'YouTube Link Detected',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Watch now or add it to your list.',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onDismiss,
                    style: IconButton.styleFrom(
                      backgroundColor: colors.surfaceContainerHigh,
                      foregroundColor: colors.onSurfaceVariant,
                    ),
                    icon: const Icon(Icons.close_rounded),
                    iconSize: 20,
                  ),
                ],
              ),
              const Gap(16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p12,
                  vertical: AppSizes.p12,
                ),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                  borderRadius: AppRadius.roundedL,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: AppIconSizes.sm,
                      color: colors.primary,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        widget.url,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(12),

              // Playlist selector
              if (isLoading)
                const LinearProgressIndicator()
              else if (playlists.isNotEmpty)
                PlaylistSelector(
                  playlists: playlists,
                  selectedId: selectedId,
                  defaultId: defaultId,
                  onChanged: (id) => context.read<ClipboardCubit>().selectPlaylist(id),
                ),
              const Gap(16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        talker.debug('ClipboardVideoPrompt: Add to List button pressed');
                        context.read<ClipboardCubit>().addToPlaylist(widget.url);
                      },
                      icon: const Icon(AppIcons.add),
                      label: const Text(
                        'Add to List',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: colors.onSurface,
                        side: BorderSide(color: colors.outline),
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedL,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        talker.debug('ClipboardVideoPrompt: Watch Now button pressed');
                        context.read<ClipboardCubit>().watchNow(widget.url);
                      },
                      icon: const Icon(AppIcons.play),
                      label: const Text('Watch Now'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.roundedL,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
