import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/views/edit_playlist_page_widgets/edit_icon_widget.dart';
import 'package:levelup_tube/src/features/playlist/views/edit_playlist_page_widgets/thumbnail_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class EditPlaylistPage extends StatefulWidget {
  const EditPlaylistPage({required this.playlistModel, super.key});

  final PlaylistModel playlistModel;

  @override
  State<EditPlaylistPage> createState() => _EditPlaylistPageState();
}

class _EditPlaylistPageState extends State<EditPlaylistPage> {
  int? imageFilePath;



Future<String> saveImageToLocalStorage(File imageFile) async {
  final directory = await getApplicationDocumentsDirectory();
  final uuid = const Uuid().v4();
  final filePath = '${directory.path}/thumbnails/$uuid.jpg';

  // Create directory if it doesn't exist
  final file = File(filePath);
  await file.parent.create(recursive: true);

  // Copy the image file to the new path
  await imageFile.copy(filePath);
  return filePath;
}

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                // Thumbnail with placeholder
                ThumbnailWidget(playlistModel: widget.playlistModel),
                // Edit icon in bottom-right
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: EditIcon(
                    onTap: () {
                      // Handle edit thumbnail action
                    },
                  ),
                ),
              ],
            ),
            const Gap(32),
            TextField(
              decoration: InputDecoration(
                labelText: 'Playlist Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const Gap(32),
            AppPrimaryButton(
              onPressed: () {
                // Handle save action
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
