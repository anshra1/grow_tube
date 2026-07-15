import 'package:flutter/material.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';

class EditPlaylistPage extends StatelessWidget {
  const EditPlaylistPage({
    required this.playlistId,
    super.key,
  });

  final int playlistId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Edit Playlist'),
      ),
      body: const Center(
        child: Text('Edit Playlist UI to be implemented'),
      ),
    );
  }
}
