import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:levelup_tube/src/core/widgets/atoms/top_header.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_cubit.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_state.dart';

class FeedbackListPage extends StatefulWidget {
  const FeedbackListPage({super.key});

  @override
  State<FeedbackListPage> createState() => _FeedbackListPageState();
}

class _FeedbackListPageState extends State<FeedbackListPage> {
  @override
  void initState() {
    super.initState();
    context.read<FeedbackCubit>().fetchFeedbacks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TopHeaderText('Feedback Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<FeedbackCubit>().fetchFeedbacks(),
          ),
        ],
      ),
      body: BlocBuilder<FeedbackCubit, FeedbackState>(
        builder: (context, state) {
          if (state is FeedbackLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FeedbackError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (state is FeedbackAdminListLoaded) {
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
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Feedback?'),
                        content: const Text('Are you sure you want to delete this feedback?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              context.read<FeedbackCubit>().deleteFeedback(feedback.id);
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                feedback.category,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          feedback.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (feedback.email != null && feedback.email!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 4),
                          Text(
                            'Email: ${feedback.email}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                  ),
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
