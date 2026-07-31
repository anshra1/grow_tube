import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:levelup_tube/src/core/widgets/atoms/buttons/app_primary_button.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_cubit.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_state.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedCategory = 'Feature Request';

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
    _tapTimer?.cancel();
    super.dispose();
  }

  void _submit() {
    context.read<FeedbackCubit>().submitFeedback(
      category: _selectedCategory,
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback submitted successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is FeedbackError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is FeedbackLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(value: category, child: Text(category));
                  }).toList(),
                  onChanged: isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  minLines: 5,
                  maxLines: null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(),
                  ),
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
