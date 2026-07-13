import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/widgets/pages/app_scaffold.dart';
import 'package:levelup_tube/src/core/constants/app_icons.dart';
import 'package:levelup_tube/src/features/library/domain/entities/video.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/add_video_bottom_sheet.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/dashboard_video_list.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/dashboard_video_list_shimmer.dart';
import 'package:levelup_tube/src/features/library/presentation/pages/widgets/dashboard_video_player.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage({required this.playlistId, super.key});
  final int playlistId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlaylistDetailCubit>(
      create: (context) => PlaylistDetailCubit(
        playlistId: playlistId,
        repository: sl<PlaylistRepository>(),
      )..loadPlaylist(),
      child: const _PlaylistDetailContent(),
    );
  }
}

class _PlaylistDetailContent extends StatelessWidget {
  const _PlaylistDetailContent();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
          buildWhen: (prev, curr) =>
            curr is PlaylistDetailLoadedState ||
            curr is PlaylistDetailEmptyState,
          builder: (context, state) {
            final title = switch (state) {
              PlaylistDetailLoadedState(:final playlist) => playlist.title,
              PlaylistDetailEmptyState(:final playlist) => playlist.title,
              _ => 'Playlist',
            };
            return Text(title);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'playlist_detail_add_video_fab',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (_) => AddVideoBottomSheet(
              onAdd: (url) {
                context.read<PlaylistDetailCubit>().addVideo(url);
              },
            ),
          );
        },
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        child: const Icon(AppIcons.add),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Hero Player — REUSE DashboardVideoPlayer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
              buildWhen: (prev, curr) =>
                curr is PlaylistDetailLoadedState ||
                curr is PlaylistDetailInitialState ||
                curr is PlaylistDetailEmptyState,
              builder: (context, state) {
                return switch (state) {
                  PlaylistDetailInitialState() => AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Shimmer.fromColors(
                      baseColor: context.colorScheme.surfaceContainerHighest,
                      highlightColor: context.colorScheme.surfaceContainer,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  PlaylistDetailLoadedState() when state.heroVideo != null =>
                    DashboardVideoPlayer(
                      video: state.heroVideo!,
                      forcePlayTimestamp: state.forcePlayTimestamp,
                      onProgressUpdate: (youtubeId, positionSeconds) {
                        context.read<PlaylistDetailCubit>().updateProgress(youtubeId, positionSeconds);
                      },
                    ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
          const SizedBox(height: 16),
          // Video List — REUSE DashboardVideoList with onVideoTap override
          Expanded(
            child: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
              buildWhen: (prev, curr) =>
                curr is PlaylistDetailLoadedState ||
                curr is PlaylistDetailEmptyState ||
                curr is PlaylistDetailInitialState,
              builder: (context, state) {
                return switch (state) {
                  PlaylistDetailInitialState() => const DashboardVideoListShimmer(),
                  PlaylistDetailEmptyState() => const Center(
                    child: Text('No videos in this playlist'),
                  ),
                  PlaylistDetailLoadedState() => DashboardVideoList(
                    videos: state.videos,
                    // CRITICAL: Override onVideoTap to use PlaylistDetailCubit
                    // instead of the default LibraryBloc behavior
                    onVideoTap: (video) {
                      context.read<PlaylistDetailCubit>().selectVideo(video);
                    },
                    // Override onVideoLongPress to remove from playlist
                    // instead of deleting from library
                    onVideoLongPress: (video) {
                      _showRemoveFromPlaylistDialog(context, video);
                    },
                  ),
                  _ => const SizedBox.shrink(),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveFromPlaylistDialog(BuildContext context, Video video) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from Playlist?'),
        content: Text(
          'Remove "${video.title}" from this playlist?\n\n'
          'The video will remain in your library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<PlaylistDetailCubit>().removeVideo(video.id);
              Navigator.pop(dialogContext);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
