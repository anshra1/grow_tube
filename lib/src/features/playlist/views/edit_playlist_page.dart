import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

class EditPlaylistPage extends StatelessWidget {
  const EditPlaylistPage({required this.playlistModel, super.key});

  final PlaylistModel playlistModel;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Playlist',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p8),
        child: Column(
          children: [
            Stack(
              children: [
                // Thumbnail with placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: playlistModel.thumbnailUrl != null && playlistModel.thumbnailUrl!.isNotEmpty
                      ? Image.network(
                          playlistModel.thumbnailUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              width: double.infinity,
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 64,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 64,
                          ),
                        ),
                ),
                // Edit icon in bottom-right
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
