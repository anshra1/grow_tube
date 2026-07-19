import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/library/views/dashboard_widgets/dashboard_video_list_shimmer.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_state.dart';
import 'package:levelup_tube/src/features/playlist/views/edit_playlist_page.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/add_playlist_bottom_sheet.dart';
import 'package:levelup_tube/src/features/playlist/views/playlist_page_widgets/playlist_card.dart';
import 'package:toastification/toastification.dart';

class PlaylistsPage extends StatelessWidget {
  const PlaylistsPage({this.importUrl, super.key});

  final String? importUrl;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlaylistCubit>(
      create: (context) {
        final cubit = sl<PlaylistCubit>();
        if (importUrl != null) {
          cubit.loadAndImport(importUrl!);
        } else {
          cubit.loadPlaylists();
        }
        return cubit;
      },
      child: const _PlaylistsPageContent(),
    );
  }
}

class _PlaylistsPageContent extends StatelessWidget {
  const _PlaylistsPageContent();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('My Playlists'),
        leading: const BackButton(),
      ),
      body: BlocConsumer<PlaylistCubit, PlaylistState>(
        listener: (context, state) {
          if (state is PlaylistErrorState) {
            toastification.show(
              context: context,
              title: const Text('Error'),
              description: Text(state.message),
              type: ToastificationType.error,
              style: ToastificationStyle.flatColored,
              autoCloseDuration: const Duration(seconds: 4),
            );
          }
        },
        builder: (context, state) {
          return switch (state) {
            PlaylistInitialState() || PlaylistLoadingState() =>
              const DashboardVideoListShimmer(),

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
                  Text(
                    'No playlists yet',
                    style: context.textTheme.titleLarge,
                  ),
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
              onRefresh: () =>
                  context.read<PlaylistCubit>().loadPlaylists(),
              child: _buildList(context, playlists),
            ),

            PlaylistImportingState(
              :final playlists,
              :final message,
            ) =>
              Column(
                children: [
                  const LinearProgressIndicator(),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(message),
                  ),
                  Expanded(child: _buildList(context, playlists)),
                ],
              ),

            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlaylistBottomSheet(context),
        backgroundColor: context.colorScheme.primary,
        foregroundColor: context.colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<PlaylistModel> playlists,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 80),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PlaylistCard(
            playlist: playlist,
            onTap: () => context.push('/playlists/${playlist.id}'),
            onLongPress: playlist.isSystemDefault
                ? null
                : () => _showDeleteDialog(context, playlist),
            onOptionsTap: () =>
                _showPlaylistOptionsBottomSheet(context, playlist),
          ),
        );
      },
    );
  }

  void _showPlaylistOptionsBottomSheet(
    BuildContext context,
    PlaylistModel playlist,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                playlist.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
              ),
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
                  Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          EditPlaylistPage(playlistModel: playlist),
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

  void _showAddPlaylistBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AddPlaylistBottomSheet(
        onCreateCustom: (title) {
          context.read<PlaylistCubit>().createPlaylist(title);
        },
        onImport: (url) {
          context.read<PlaylistCubit>().importPlaylist(url);
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    PlaylistModel playlist,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        insetPadding: const EdgeInsets.all(AppSizes.p16),
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.roundedXL,
        ),
        backgroundColor: context.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Delete Playlist?',
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Are you sure you want to delete ?',
          style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSizes.p16,
          0,
          AppSizes.p16,
          AppSizes.p16,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<PlaylistCubit>().deletePlaylist(
                playlist.id,
              );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: context.colorScheme.error,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
