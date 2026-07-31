import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_button_state.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_cubit.dart';
import 'package:levelup_tube/src/features/add/viewmodels/add_state.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';
import 'package:uuid/uuid.dart';

class CreatePlaylistForm extends StatefulWidget {
  const CreatePlaylistForm({
    required this.nameController,
    required this.imageNotifier,
    super.key,
  });

  final TextEditingController nameController;
  final ValueNotifier<String?> imageNotifier;

  @override
  State<CreatePlaylistForm> createState() => _CreatePlaylistFormState();
}

class _CreatePlaylistFormState extends State<CreatePlaylistForm> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (!mounted) return;
      try {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
          compressQuality: 80,
          maxWidth: 1280,
          maxHeight: 720,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Theme.of(context).colorScheme.onPrimary,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: true,
            ),
            IOSUiSettings(
              title: 'Crop Image',
              aspectRatioLockEnabled: true,
              resetAspectRatioEnabled: false,
              aspectRatioPickerButtonHidden: true,
            ),
          ],
        );

        if (croppedFile != null) {
          final path = await saveImageToLocalStorage(XFile(croppedFile.path));
          widget.imageNotifier.value = path;
        }
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

    final file = File(filePath);
    await file.parent.create(recursive: true);

    await imageFile.saveTo(filePath);
    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AddCubit, AddState>(
      listenWhen: (previous, current) => current is CreatePlaylistSuccess,
      buildWhen: (previous, current) =>
          current is AddLoading ||
          current is CreatePlaylistSuccess ||
          current is AddError,
      listener: (context, state) {
        if (state is CreatePlaylistSuccess) {
          widget.imageNotifier.value = null;
        }
      },
      builder: (context, state) {
        final isAdding = state is AddLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _pickImage,
                child: ValueListenableBuilder<String?>(
                  valueListenable: widget.imageNotifier,
                  builder: (context, imagePath, child) {
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        image: imagePath != null
                            ? DecorationImage(
                                image: FileImage(File(imagePath)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: imagePath == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 32, color: theme.colorScheme.onSurfaceVariant),
                                const Gap(8),
                                Text(
                                  'Cover\n(optional)',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                ],
                              )
                            : null,
                        ),
                      );
                  },
                ),
              ),
            ),
            const Gap(24),
            TextField(
              controller: widget.nameController,
              decoration: InputDecoration(
                labelText: 'Playlist Name',
                hintText: 'e.g. Machine Learning Basics',
                prefixIcon: const Icon(Icons.edit_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
            ),
            const Gap(32),
            ListenableBuilder(
              listenable: widget.nameController,
              builder: (context, child) {
                final isEnabled = widget.nameController.text.trim().isNotEmpty && !isAdding;

                AppButtonState buttonState;
                if (isAdding) {
                  buttonState = AppButtonState.loading;
                } else if (isEnabled) {
                  buttonState = AppButtonState.enabled;
                } else {
                  buttonState = AppButtonState.disabled;
                }

                return AppPrimaryButton(
                  state: buttonState,
                  onPressed: isEnabled
                      ? () {
                          context.read<AddCubit>().createPlaylist(
                                widget.nameController.text.trim(),
                                localThumbnailPath: widget.imageNotifier.value,
                              );
                        }
                      : null,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: const Text(
                    'Create Playlist',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
