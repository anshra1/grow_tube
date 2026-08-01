import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:levelup_tube/src/core/design_system/app_radius.dart';
import 'package:levelup_tube/src/core/widgets/atoms/app_text_field.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_cubit.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_state.dart';
import 'package:toastification/toastification.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final ValueNotifier<String> _selectedCategory = ValueNotifier<String>(
    'Feature Request',
  );
  final ValueNotifier<List<File>> _attachments = ValueNotifier<List<File>>([]);

  final List<String> _categories = [
    'Feature Request',
    'Bug Report',
    'General Feedback',
    'Other',
  ];

  int _tapCount = 0;
  Timer? _tapTimer;

  void _handleTitleTap(BuildContext context) {
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      context.go('/settings/feedback/admin');
    }
    _tapTimer?.cancel();
    _tapTimer = Timer(const Duration(seconds: 1), () {
      _tapCount = 0;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    _selectedCategory.dispose();
    _attachments.dispose();
    _tapTimer?.cancel();
    super.dispose();
  }

  void _submit() {
    context.read<FeedbackCubit>().submitFeedback(
      category: _selectedCategory.value,
      description: _descriptionController.text,
      email: _emailController.text,
      attachments: _attachments.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _handleTitleTap(context),
          child: const TopHeaderText('Send Feedback'),
        ),
      ),
      body: BlocConsumer<FeedbackCubit, FeedbackState>(
        listenWhen: (previous, current) =>
            current is FeedbackSuccess || current is FeedbackError,
        listener: (context, state) {
          if (state is FeedbackSuccess) {
            toastification.show(
              context: context,
              alignment: Alignment.bottomCenter,
              type: ToastificationType.success,
              style: ToastificationStyle.fillColored,
              title: const Text('Success'),
              description: const Text('Feedback submitted successfully!'),
              autoCloseDuration: const Duration(seconds: 3),
            );
            Navigator.of(context).pop();
          } else if (state is FeedbackError) {
            toastification.show(
              context: context,
              alignment: Alignment.bottomCenter,
              type: ToastificationType.error,
              style: ToastificationStyle.fillColored,
              title: const Text('Error'),
              description: Text(state.message),
              autoCloseDuration: const Duration(seconds: 5),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is FeedbackLoading;

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                ValueListenableBuilder<String>(
                  valueListenable: _selectedCategory,
                  builder: (context, selectedCategoryValue, child) {
                    return DropdownButtonFormField<String>(
                      initialValue: selectedCategoryValue,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(value: category, child: Text(category));
                      }).toList(),
                      onChanged: isLoading
                          ? null
                          : (value) {
                              if (value != null) {
                                _selectedCategory.value = value;
                              }
                            },
                    );
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _descriptionController,
                  labelText: 'Description',
                  minLines: 5,
                  maxLines: null,
                  cornerRadius: AppRadius.roundedM,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _emailController,
                  cornerRadius: AppRadius.roundedM,
                  labelText: 'Email / Mobile No (Optional)',
                  keyboardType: TextInputType.emailAddress,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Screenshots or recordings (optional)',
                      style: Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap screenshot to edit or remove sensitive info',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<File>>(
                      valueListenable: _attachments,
                      builder: (context, attachmentsList, child) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            ...attachmentsList.map((file) {
                              final isAudio =
                                  file.path.toLowerCase().endsWith('.mp3') ||
                                  file.path.toLowerCase().endsWith('.wav') ||
                                  file.path.toLowerCase().endsWith('.m4a') ||
                                  file.path.toLowerCase().endsWith('.aac');
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withValues(alpha: .3),
                                      ),
                                      color: isAudio
                                          ? Colors.blue.withValues(alpha: .1)
                                          : null,
                                    ),
                                    child: isAudio
                                        ? const Center(
                                            child: Icon(
                                              Icons.audiotrack,
                                              size: 32,
                                              color: Colors.blue,
                                            ),
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: Image.file(file, fit: BoxFit.cover),
                                          ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: GestureDetector(
                                      onTap: () {
                                        final newList = List<File>.from(
                                          _attachments.value,
                                        )..remove(file);
                                        _attachments.value = newList;
                                      },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.cancel,
                                          color: Colors.grey[800],
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            GestureDetector(
                              onTap: () async {
                                final picker = ImagePicker();
                                final images = await picker.pickMultiImage();
                                if (images.isNotEmpty) {
                                  final newList = List<File>.from(_attachments.value)
                                    ..addAll(images.map((e) => File(e.path)));
                                  _attachments.value = newList;
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_outlined,
                                    color: Colors.black87,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                try {
                                  final result = await FilePicker.pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                      'mp3',
                                      'wav',
                                      'm4a',
                                      'aac',
                                      'ogg',
                                    ],
                                  );
                                  if (result != null &&
                                      result.files.single.path != null) {
                                    final newList = List<File>.from(_attachments.value)
                                      ..add(File(result.files.single.path!));
                                    _attachments.value = newList;
                                  }
                                } on Exception catch (e) {
                                  toastification.show(
                                    //
                                    // ignore: use_build_context_synchronously
                                    context: context,
                                    type: ToastificationType.error,
                                    style: ToastificationStyle.fillColored,
                                    title: const Text('Error'),
                                    description: Text('Could not open file picker: $e'),
                                    autoCloseDuration: const Duration(seconds: 3),
                                  );
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.audiotrack_outlined,
                                    color: Colors.black87,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  onPressed: isLoading ? null : _submit,
                  child: const Text('Submit Feedback'),
                ),
              ],
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: .4),
              alignment: Alignment.center,
              child: Card(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 16),
                      Text(
                        'Sending...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    },
  ),
    );
  }
}
