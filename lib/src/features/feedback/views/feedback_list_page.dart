import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/core/widgets/molecules/custom_delete_dialog.dart';
import 'package:levelup_tube/src/core/widgets/template/app_scaffold.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_cubit.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_state.dart';
import 'package:levelup_tube/src/features/feedback/views/widgets/feedback_details_widget.dart';
import 'package:toastification/toastification.dart';

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({super.key});

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  final ValueNotifier<String?> expandedFeedbackNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    context.read<FeedbackCubit>().fetchFeedbacks();
  }

  @override
  void dispose() {
    expandedFeedbackNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const TopHeaderText('Feedback Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FeedbackCubit>().fetchFeedbacks(),
          ),
        ],
      ),
      body: BlocConsumer<FeedbackCubit, FeedbackState>(
        listenWhen: (previous, current) =>
            current is FeedbackError || current is FeedbackSuccess,
        listener: (context, state) {
          if (state is FeedbackError) {
            toastification.show(
              context: context,
              type: ToastificationType.error,
              style: ToastificationStyle.fillColored,
              title: const Text('Error'),
              description: Text(state.message),
              autoCloseDuration: const Duration(seconds: 3),
            );
          } else if (state is FeedbackSuccess) {
            toastification.show(
              context: context,
              type: ToastificationType.success,
              style: ToastificationStyle.fillColored,
              title: const Text('Success'),
              description: const Text('Operation completed successfully'),
              autoCloseDuration: const Duration(seconds: 3),
            );
          }
        },
        buildWhen: (previous, current) => current is FeedbackAdminListLoaded,
        builder: (context, state) {
          if (state is FeedbackAdminListLoaded) {
            final feedbacks = state.feedbacks;

            if (feedbacks.isEmpty) {
              return const Center(child: Text('No feedback found.'));
            }

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];
                final dateStr = feedback.createdAt != null
                    ? DateFormat.yMMMd().add_Hm().format(feedback.createdAt!)
                    : 'Unknown date';

                return GestureDetector(
                  onLongPress: () {
                    showDialog<void>(
                      context: context,
                      builder: (context) => CustomDeleteDialog(
                        title: 'Delete Feedback?',
                        description: 'Are you sure you want to delete this feedback?',
                        onConfirm: () {
                          Navigator.pop(context);
                          context.read<FeedbackCubit>().deleteFeedback(feedback.id);
                        },
                      ),
                    );
                  },
                  child: ValueListenableBuilder<String?>(
                    valueListenable: expandedFeedbackNotifier,
                    builder: (context, expandedId, child) {
                      return CardWidget(
                        feedback: feedback,
                        dateStr: dateStr,
                        isExpanded: expandedId == feedback.id,
                        onTap: () {
                          if (expandedFeedbackNotifier.value == feedback.id) {
                            expandedFeedbackNotifier.value = null;
                          } else {
                            expandedFeedbackNotifier.value = feedback.id;
                          }
                        },
                      );
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
