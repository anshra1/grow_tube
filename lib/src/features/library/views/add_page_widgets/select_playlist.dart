import 'package:flutter/material.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

class SelectPlaylist extends StatelessWidget {
  const SelectPlaylist({
    required this.selectedPlaylistIdNotifier,
    required this.playlists,
    super.key,
  });

  final ValueNotifier<int?> selectedPlaylistIdNotifier;
  final List<PlaylistModel> playlists;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<int?>(
      valueListenable: selectedPlaylistIdNotifier,
      builder: (context, selectedPlaylistId, child) {
        return DropdownButtonFormField<int>(
          initialValue: selectedPlaylistId,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
          onChanged: (value) {
            selectedPlaylistIdNotifier.value = value;
          },
          items: playlists.map((playlist) {
            return DropdownMenuItem(
              value: playlist.id,
              child: Text(playlist.title),
            );
          }).toList(),
        );
      },
    );
  }
}
