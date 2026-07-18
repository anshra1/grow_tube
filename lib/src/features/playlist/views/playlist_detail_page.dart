import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:levelup_tube/src/core/constants/app_icons.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/add_video_bottom_sheet.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/video_list_with_player.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_state.dart';

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage({required this.playlistId, super.key});
  final int? playlistId;

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
        title: BlocSelector<PlaylistDetailCubit, PlaylistDetailState, String?>(
          selector: (state) {
            return switch (state) {
              PlaylistDetailLoaded(:final videosState) =>
                videosState.playlist.title,
              PlaylistDetailEmpty(:final playlist) => playlist.title,
              _ => null,
            };
          },
          builder: (context, title) {
            return Text(title ?? 'Playlist');
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'playlist_detail_add_video_fab',
        onPressed: () {
          showModalBottomSheet<void>(
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
      body: BlocBuilder<PlaylistDetailCubit, PlaylistDetailState>(
        builder: (context, state) {
          return switch (state) {
            PlaylistDetailInitial() || PlaylistDetailLoading() =>
              const VideoListWithPlayer(isLoading: true, isEmpty: false),
            PlaylistDetailEmpty() => const VideoListWithPlayer(
              isLoading: false,
              isEmpty: true,
              emptyWidget: Center(child: Text('No videos in this playlist')),
            ),
            PlaylistDetailLoaded() => _LoadedPlaylistBody(),
            PlaylistDetailError(:final message) => Center(child: Text(message)),
          };
        },
      ),
    );
  }

  void _showVideoOptionsBottomSheet(BuildContext context, Video video) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                video.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
              title: Text(video.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                context.read<PlaylistDetailCubit>().setVideoPinned(
                  video.id,
                  !video.isPinned,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_remove),
              title: const Text('Remove from Playlist'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                _showRemoveFromPlaylistDialog(context, video);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveFromPlaylistDialog(BuildContext context, Video video) {
    showDialog<void>(
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

class _LoadedPlaylistBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Use BlocSelector for each independent part of the state
    final videosState = context
        .select<PlaylistDetailCubit, PlaylistVideosState?>(
          (cubit) => cubit.state is PlaylistDetailLoaded
              ? (cubit.state as PlaylistDetailLoaded).videosState
              : null,
        );
    final heroVideoState = context.select<PlaylistDetailCubit, HeroVideoState?>(
      (cubit) => cubit.state is PlaylistDetailLoaded
          ? (cubit.state as PlaylistDetailLoaded).heroVideoState
          : null,
    );

    if (videosState == null || heroVideoState == null) {
      return const SizedBox.shrink();
    }

    return VideoListWithPlayer(
      isLoading: false,
      isEmpty: false,
      videos: videosState.videos,
      heroVideo: heroVideoState.heroVideo,
      forcePlayTimestamp: heroVideoState.forcePlayTimestamp,
      onVideoTap: (video) {
        context.read<PlaylistDetailCubit>().selectVideo(video);
      },
      onVideoLongPress: (video) {
        context
            .findAncestorWidgetOfExactType<_PlaylistDetailContent>()!
            ._showRemoveFromPlaylistDialog(context, video);
      },
      onOptionsTap: (video) {
        context
            .findAncestorWidgetOfExactType<_PlaylistDetailContent>()!
            ._showVideoOptionsBottomSheet(context, video);
      },
      onProgressUpdate: (playlistVideoId, positionSeconds) {
        context.read<PlaylistDetailCubit>().updateProgress(
          playlistVideoId,
          positionSeconds,
        );
      },
    );
  }
}
