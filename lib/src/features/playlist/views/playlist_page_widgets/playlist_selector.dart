import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';

class PlaylistSelector extends StatelessWidget {
  const PlaylistSelector({
    required this.playlists,
    required this.selectedId,
    required this.onChanged,
    this.defaultId,
    super.key,
  });

  final List<PlaylistModel> playlists;
  final int? selectedId;
  final int? defaultId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    if (playlists.isEmpty) return const SizedBox.shrink();

    final colors = context.colorScheme;
    final selectedPlaylist = selectedId != null
        ? playlists.firstWhere((p) => p.id == selectedId, orElse: () => playlists.first)
        : playlists.first;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showPlaylistBottomSheet(context),
        borderRadius: AppRadius.roundedL,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p16,
            vertical: AppSizes.p12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: colors.outlineVariant),
            borderRadius: AppRadius.roundedL,
          ),
          child: Row(
            children: [
              Icon(Icons.playlist_play_rounded, color: colors.onSurfaceVariant),
              const Gap(12),
              Expanded(
                child: Text(
                  selectedPlaylist.title,
                  style: context.textTheme.bodyLarge?.copyWith(color: colors.onSurface),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.arrow_drop_down_rounded, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  void _showPlaylistBottomSheet(BuildContext context) {
    final colors = context.colorScheme;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Gap(16),
              Container(
                height: 4,
                width: 32,
                decoration: BoxDecoration(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),
              Text(
                'Select Playlist',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (listContext, index) {
                    final p = playlists[index];
                    final isSelected = p.id == selectedId;
                    final isDefault = p.id == defaultId;
                    return ListTile(
                      leading: Icon(
                        isDefault ? Icons.star_rounded : Icons.folder_rounded,
                        color: isDefault ? colors.primary : colors.onSurfaceVariant,
                      ),
                      title: Text(
                        p.title,
                        style: context.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? colors.primary : colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle_rounded, color: colors.primary)
                          : null,
                      onTap: () {
                        onChanged(p.id);
                        Navigator.pop(bottomSheetContext);
                      },
                    );
                  },
                ),
              ),
              const Gap(16),
            ],
          ),
        );
      },
    );
  }
}
