import 'dart:io';
import 'package:flutter/material.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

class ThumbnailWidget extends StatelessWidget {
  const ThumbnailWidget({required this.playlistModel, this.localImagePath, super.key});

  final PlaylistModel playlistModel;
  final String? localImagePath;

  @override
  Widget build(BuildContext context) {
    final imagePath = localImagePath ?? playlistModel.localThumbnailPath;

    if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(imagePath),
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported, size: 64),
            );
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child:
          playlistModel.thumbnailUrl != null &&
              playlistModel.thumbnailUrl!.isNotEmpty
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
                  child: const Icon(Icons.image_not_supported, size: 64),
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
              child: const Icon(Icons.image, size: 64),
            ),
    );
  }
}
