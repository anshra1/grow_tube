import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:levelup_tube/src/core/design_system/app_sizes.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/playlist/models/playlist_model.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_cubit.dart';
import 'package:levelup_tube/src/features/playlist/viewmodels/playlist_state.dart';
import 'package:levelup_tube/src/features/playlist/views/edit_playlist_page_widgets/edit_icon_widget.dart';
import 'package:levelup_tube/src/features/playlist/views/edit_playlist_page_widgets/thumbnail_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

class EditPlaylistPage extends StatefulWidget {
  const EditPlaylistPage({required this.playlistModel, super.key});

  final PlaylistModel playlistModel;

  @override
  State<EditPlaylistPage> createState() => _EditPlaylistPageState();
}

class _EditPlaylistPageState extends State<EditPlaylistPage> {
  late final ValueNotifier<String?> _imageNotifier;
  late TextEditingController _titleController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.playlistModel.title);
    _imageNotifier = ValueNotifier(widget.playlistModel.localThumbnailPath);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final path = await saveImageToLocalStorage(image);
        _imageNotifier.value = path;
      } on Exception catch (e) {
        if (mounted) {
          toastification.show(
            context: context,
            title: const Text('Error'),
            description: Text('Failed to save image: $e'),
            type: ToastificationType.error,
          );
        }
      }
    }
  }

  Future<String> saveImageToLocalStorage(XFile imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final uuid = const Uuid().v4();
    final filePath = '${directory.path}/thumbnails/$uuid.jpg';

    // Create directory if it doesn't exist
    final file = File(filePath);
    await file.parent.create(recursive: true);

    // Copy the image file to the new path using XFile.saveTo
    await imageFile.saveTo(filePath);
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PlaylistCubit, PlaylistState>(
      listenWhen: (previous, current) =>
          current is PlaylistUpdateSuccessState || current is PlaylistErrorState,
      listener: (context, state) {
        if (state is PlaylistUpdateSuccessState) {
          toastification.show(
            context: context,
            alignment: Alignment.bottomCenter,
            title: const Text('Success'),
            description: const Text('Playlist updated successfully'),
            type: ToastificationType.success,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 3),
          );
          Navigator.pop(context);
        } else if (state is PlaylistErrorState) {
          toastification.show(
            context: context,
            alignment: Alignment.bottomCenter,
            title: const Text('Error'),
            description: Text(state.message),
            type: ToastificationType.error,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 4),
          );
        }
      },
      builder: (context, state) {
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
                ValueListenableBuilder<String?>(
                  valueListenable: _imageNotifier,
                  builder: (context, imagePath, child) {
                    return Stack(
                      children: [
                        ThumbnailWidget(
                          playlistModel: widget.playlistModel,
                          localImagePath: imagePath,
                        ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: EditIcon(onTap: _pickImage),
                        ),
                      ],
                    );
                  },
                ),
                const Gap(32),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Playlist Title',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const Gap(32),
                ListenableBuilder(
                  listenable: Listenable.merge([_titleController, _imageNotifier]),
                  builder: (context, child) {
                    final hasChanges =
                        _titleController.text != widget.playlistModel.title ||
                        _imageNotifier.value != widget.playlistModel.localThumbnailPath;
                    return AppPrimaryButton(
                      onPressed: hasChanges
                          ? () {
                              context.read<PlaylistCubit>().updatePlaylistDetails(
                                widget.playlistModel.id,
                                title: _titleController.text,
                                localThumbnailPath: _imageNotifier.value,
                              );
                            }
                          : null,
                      child: const Text('Save'),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
