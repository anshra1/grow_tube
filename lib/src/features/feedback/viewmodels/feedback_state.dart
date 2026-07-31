import 'package:levelup_tube/src/features/feedback/models/feedback_model.dart';

abstract class FeedbackState {
  const FeedbackState();
}

class FeedbackInitial extends FeedbackState {
  const FeedbackInitial();
}

class FeedbackLoading extends FeedbackState {
  const FeedbackLoading();
}

class FeedbackSuccess extends FeedbackState {
  const FeedbackSuccess();
}

class FeedbackError extends FeedbackState {
  const FeedbackError(this.message);
  final String message;
}

class FeedbackAdminListLoaded extends FeedbackState {
  const FeedbackAdminListLoaded(this.feedbacks);
  final List<FeedbackModel> feedbacks;
}
