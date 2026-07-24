import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/library/models/video.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/video_list_with_player.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_detail_state.dart';

class PlaylistDetailPage extends StatelessWidget {
  const PlaylistDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaylistDetailCubit, PlaylistDetailState>(
      listenWhen: (previous, current) => current is PlaylistDetailError,
      listener: (context, state) {
        if (state is PlaylistDetailError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      buildWhen: (previous, current) => current is! VideoAddPlaylistSuccessState,
      builder: (context, state) {
        String? title;
        if (state is PlaylistDetailLoaded) {
          title = state.videosState.playlist.title;
        } else if (state is PlaylistDetailEmpty) {
          title = state.playlist.title;
        }

        Widget body = const SizedBox.shrink();

        if (state is PlaylistDetailInitial || state is PlaylistDetailLoading) {
          body = const VideoListWithPlayer(isLoading: true, isEmpty: false);
        } else if (state is PlaylistDetailEmpty) {
          body = const VideoListWithPlayer(
            isLoading: false,
            isEmpty: true,
            emptyWidget: Center(child: Text('No videos in this playlist')),
          );
        } else if (state is PlaylistDetailLoaded) {
          body = _LoadedPlaylistBody();
        }

        return AppScaffold(
          appBar: AppBar(
            title: Text(
              title ?? 'Playlist',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                fontWeight: FontWeight.w600,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            // actions: const [Icon(Icons.edit)],
            // TODO(dev): add later go to edit page with dropdown option to open edit icon when click on
          ),
          body: body,
        );
      },
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
              leading: Icon(video.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
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
    final videosState = context.select<PlaylistDetailCubit, PlaylistVideosState?>(
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
            .findAncestorWidgetOfExactType<PlaylistDetailPage>()!
            ._showRemoveFromPlaylistDialog(context, video);
      },
      onOptionsTap: (video) {
        context
            .findAncestorWidgetOfExactType<PlaylistDetailPage>()!
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
