import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:levelup_tube/src/features/feedback/services/feedback_service.dart';
import 'package:levelup_tube/src/features/feedback/viewmodels/feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({FeedbackService? feedbackService})
    : _feedbackService = feedbackService ?? FeedbackService(),
      super(const FeedbackInitial());

  final FeedbackService _feedbackService;

  Future<void> submitFeedback({
    required String category,
    required String description,
    String? email,
    List<File>? attachments,
  }) async {
    if (description.trim().isEmpty) {
      emit(const FeedbackError('Description cannot be empty'));
      return;
    }

    emit(const FeedbackLoading());

    try {
      await _feedbackService.submitFeedback(
        category: category,
        description: description,
        email: email,
        attachments: attachments,
      );
      if (!isClosed) {
        emit(const FeedbackSuccess());
      }
    }on Exception catch (e) {
      if (!isClosed) {
        emit(FeedbackError('Failed to submit feedback: $e'));
      }
    }
  }

  Future<void> fetchFeedbacks() async {
    emit(const FeedbackLoading());
    try {
      final feedbacks = await _feedbackService.getAllFeedbacks();
      if (!isClosed) {
        emit(FeedbackAdminListLoaded(feedbacks));
      }
    }on Exception catch (e) {
      if (!isClosed) {
        emit(FeedbackError(e.toString()));
      }
    }
  }

  Future<void> deleteFeedback(String id) async {
    try {
      await _feedbackService.deleteFeedback(id);
      if (!isClosed) {
        emit(const FeedbackSuccess());
      }
      // Refresh the list after deleting
      await fetchFeedbacks();
    }on Exception catch (e) {
      if (!isClosed) {
        emit(FeedbackError('Failed to delete feedback: $e'));
      }
    }
  }
}
