import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:levelup_tube/src/core/extensions/context_extensions.dart';

class AddPlaylistBottomSheet extends StatefulWidget {
  const AddPlaylistBottomSheet({
    required this.onCreateCustom,
    required this.onImport,
    super.key,
  });

  final ValueChanged<String> onCreateCustom;
  final ValueChanged<String> onImport;

  @override
  State<AddPlaylistBottomSheet> createState() => _AddPlaylistBottomSheetState();
}

class _AddPlaylistBottomSheetState extends State<AddPlaylistBottomSheet> {
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  int _selectedTab = 0; // 0 = Custom, 1 = Import

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add Playlist',
            style: context.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          // Material 3 SegmentedButton for tab toggle
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Create Custom'),
                icon: Icon(Icons.create),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Import YouTube'),
                icon: Icon(Icons.download),
              ),
            ],
            selected: {_selectedTab},
            onSelectionChanged: (selection) {
              setState(() => _selectedTab = selection.first);
            },
          ),
          const Gap(16),
          // Conditional input based on selected tab
          if (_selectedTab == 0) ...[
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'e.g. Machine Learning, Flutter Basics',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (_) => _submitCustom(),
            ),
            const Gap(24),
            FilledButton(
              onPressed: _submitCustom,
              child: const Text('Create Playlist'),
            ),
          ] else ...[
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'YouTube Playlist URL',
                hintText: 'https://youtube.com/playlist?list=...',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              onSubmitted: (_) => _submitImport(),
            ),
            const Gap(24),
            FilledButton(
              onPressed: _submitImport,
              child: const Text('Import Playlist'),
            ),
          ],
          const Gap(24),
        ],
      ),
    );
  }

  void _submitCustom() {
    final name = _nameController.text.trim();
    if (name.isNotEmpty) {
      widget.onCreateCustom(name);
      Navigator.pop(context);
    }
  }

  void _submitImport() {
    final url = _urlController.text.trim();
    if (url.isNotEmpty) {
      widget.onImport(url);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
}
