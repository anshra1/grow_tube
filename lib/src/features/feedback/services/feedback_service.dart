import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:levelup_tube/src/core/di/injection_container.dart' as di;
import 'package:levelup_tube/src/core/services/logging_service/app_logger.dart';
import 'package:levelup_tube/src/features/feedback/models/feedback_model.dart';

class FeedbackService {
  FeedbackService({FirebaseFirestore? firestore, AppLogger? appLogger})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _appLogger = appLogger ?? di.sl<AppLogger>();

  final FirebaseFirestore _firestore;
  final AppLogger _appLogger;

  Future<void> submitFeedback({
    required String category,
    required String description,
    String? email,
  }) async {
    try {
      await _firestore.collection('feedbacks').add({
        'category': category,
        'description': description.trim(),
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e, stackTrace) {
      _appLogger.handle(e, stackTrace, 'FeedbackService: Firebase error [${e.code}]');

      throw Exception(e.message ?? 'An unexpected error occurred');
    } on Exception catch (e, stackTrace) {
      _appLogger.handle(e, stackTrace, 'FeedbackService: Error submitting feedback');
      throw Exception('An unexpected error occurred.');
    }
  }

  Future<List<FeedbackModel>> getAllFeedbacks() async {
    try {
      final snapshot = await _firestore
          .collection('feedbacks')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(FeedbackModel.fromFirestore).toList();
    } on FirebaseException catch (e, stackTrace) {
      _appLogger.handle(
        e,
        stackTrace,
        'FeedbackService: Firebase error fetching feedbacks [${e.code}]',
      );

      throw Exception(e.message ?? 'An error occurred while fetching feedback.');
    } on Exception catch (e, stackTrace) {
      _appLogger.handle(e, stackTrace, 'FeedbackService: Error fetching feedbacks');
      throw Exception('An unexpected error occurred while fetching feedback.');
    }
  }

  Future<void> deleteFeedback(String id) async {
    try {
      await _firestore.collection('feedbacks').doc(id).delete();
    } on FirebaseException catch (e, stackTrace) {
      _appLogger.handle(
        e,
        stackTrace,
        'FeedbackService: Firebase error deleting feedback [${e.code}]',
      );
      throw Exception(e.message ?? 'An error occurred while deleting feedback.');
    } on Exception catch (e, stackTrace) {
      _appLogger.handle(e, stackTrace, 'FeedbackService: Error deleting feedback');
      throw Exception('An unexpected error occurred while deleting feedback.');
    }
  }
}
