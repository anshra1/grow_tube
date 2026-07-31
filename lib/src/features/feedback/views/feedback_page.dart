import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
    _tapTimer?.cancel();
    super.dispose();
  }

  void _submit() {
    context.read<FeedbackCubit>().submitFeedback(
      category: _selectedCategory.value,
      description: _descriptionController.text,
      email: _emailController.text,
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

          return SingleChildScrollView(
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
                AppPrimaryButton(
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Feedback'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
