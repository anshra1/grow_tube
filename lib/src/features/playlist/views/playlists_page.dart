import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/core/widgets/molecules/custom_delete_dialog.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_state.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/repositories/playlist_repository.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_state.dart';
import 'package:levelup_tube/src/features/playlist/views/edit_playlist_page.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/playlist_card.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/playlist_importing_card.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/playlist_list_shimmer.dart';
import 'package:levelup_tube/src/features/search/models/video_search_result.dart';
import 'package:levelup_tube/src/features/search/viewmodels/search_cubit.dart';
import 'package:levelup_tube/src/features/search/views/video_search_delegate.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/setting_state.dart';
import 'package:levelup_tube/src/features/settings/viewmodels/settings_cubit.dart';
import 'package:toastification/toastification.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AddCubit, AddState>(
          listener: (context, state) {
            if (state is CreatePlaylistSuccess ||
                state is ImportPlaylistSuccess ||
                state is AddVideoSuccess) {
              context.read<PlaylistCubit>().loadPlaylists();
            }
          },
        ),
        BlocListener<SettingsCubit, SettingsState>(
          listenWhen: (previous, current) {
            if (previous is SettingsLoadedState && current is SettingsLoadedState) {
              return previous.defaultPlaylistId != current.defaultPlaylistId;
            }
            return false;
          },
          listener: (context, state) {
            context.read<PlaylistCubit>().loadPlaylists();
          },
        ),
      ],
      child: AppScaffold(
        appBar: AppBar(
          title: const TopHeaderText('Playlist'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () async {
                final searchCubit = SearchCubit(repository: di.sl<PlaylistRepository>());
                final result = await showSearch(
                  context: context,
                  delegate: VideoSearchDelegate(searchCubit: searchCubit),
                );
                await searchCubit.close();

                if (result != null && context.mounted) {
                  if (result is PlaylistModel) {
                    await context.push('/playlists/${result.id}');
                  } else if (result is VideoSearchResult) {
                    final videoUrl =
                        result.video.originalUrl ??
                        'https://youtube.com/watch?v=${result.video.youtubeId}';
                    await context.push(
                      '/playlists/${result.playlistId}',
                      extra: videoUrl,
                    );
                  }
                }
              },
            ),
          ],
        ),
        body: BlocConsumer<PlaylistCubit, PlaylistState>(
          listener: (context, state) {
            if (state is PlaylistErrorState) {
              toastification.show(
                context: context,
                alignment: Alignment.bottomCenter,
                title: const Text('Error'),
                description: Text(state.message),
                type: ToastificationType.error,
                style: ToastificationStyle.flatColored,
                autoCloseDuration: const Duration(seconds: 2),
              );
            }
          },
          builder: (context, state) {
            return switch (state) {
              PlaylistInitialState() ||
              PlaylistLoadingState() => const PlaylistListShimmer(),

              PlaylistEmptyState() => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.playlist_play,
                      size: 80,
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 16),
                    Text('No playlists yet', style: context.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Create a playlist or import from YouTube',
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              PlaylistLoadedState(:final playlists) => RefreshIndicator(
                onRefresh: () => context.read<PlaylistCubit>().loadPlaylists(),
                child: _buildList(context, playlists),
              ),

              PlaylistImportingState(
                :final playlists,
                :final currentProgress,
                :final totalVideos,
                :final title,
                :final thumbnailUrl,
              ) => RefreshIndicator(
                onRefresh: () => context.read<PlaylistCubit>().loadPlaylists(),
                child: _buildList(context, playlists, importingState: state as PlaylistImportingState),
              ),

              _ => const SizedBox.shrink(),
            };
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.go('/add?tab=1'),
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.onPrimary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context, 
    List<PlaylistModel> playlists, {
    PlaylistImportingState? importingState,
  }) {
    final itemCount = playlists.length + (importingState != null ? 1 : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (importingState != null && index == 0) {
          return PlaylistImportingCard(
            title: importingState.title,
            currentProgress: importingState.currentProgress,
            totalVideos: importingState.totalVideos,
            thumbnailUrl: importingState.thumbnailUrl,
          );
        }

        final playlistIndex = importingState != null ? index - 1 : index;
        final playlist = playlists[playlistIndex];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PlaylistCard(
            playlist: playlist,
            onTap: () => context.push('/playlists/${playlist.id}'),
            onLongPress: () => _showPlaylistOptionsBottomSheet(context, playlist),
            onOptionsTap: () => _showPlaylistOptionsBottomSheet(context, playlist),
          ),
        );
      },
    );
  }

  void _showPlaylistOptionsBottomSheet(BuildContext context, PlaylistModel playlist) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(playlist.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(playlist.isPinned ? 'Unpin' : 'Pin'),
              onTap: () {
                Navigator.pop(bottomSheetContext);
                context.read<PlaylistCubit>().setPlaylistPinned(
                  playlist.id,
                  !playlist.isPinned,
                );
              },
            ),
            if (!playlist.isSystemDefault) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  // Push to the new edit page
                  final cubit = context.read<PlaylistCubit>();
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => BlocProvider.value(
                        value: cubit,
                        child: EditPlaylistPage(playlistModel: playlist),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showDeleteDialog(context, playlist);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('System Playlist'),
                subtitle: const Text('Cannot be edited or deleted.'),
                onTap: () => Navigator.pop(bottomSheetContext),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, PlaylistModel playlist) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => CustomDeleteDialog(
        title: 'Delete Playlist?',
        description: 'Are you sure you want to delete',
        highlightText: playlist.title,
        onConfirm: () {
          context.read<PlaylistCubit>().deletePlaylist(playlist.id);
          Navigator.pop(dialogContext);
        },
      ),
    );
  }
}
