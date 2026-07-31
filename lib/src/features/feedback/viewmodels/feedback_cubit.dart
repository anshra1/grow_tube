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
      );
      emit(const FeedbackSuccess());
    } on Exception catch (e) {
      emit(FeedbackError('Failed to submit feedback: $e'));
    }
  }

  Future<void> fetchFeedbacks() async {
    emit(const FeedbackLoading());
    try {
      final feedbacks = await _feedbackService.getAllFeedbacks();
      emit(FeedbackAdminListLoaded(feedbacks));
    } on Exception catch (e) {
      emit(FeedbackError(e.toString()));
    }
  }

  Future<void> deleteFeedback(String id) async {
    try {
      await _feedbackService.deleteFeedback(id);
      // Refresh the list after deleting
      await fetchFeedbacks();
    } on Exception catch (e) {
      emit(FeedbackError('Failed to delete feedback: $e'));
    }
  }
}
