import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  FeedbackModel({
    required this.id,
    required this.category,
    required this.description,
    this.email,
    this.createdAt,
  });

  factory FeedbackModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Document data was null');
    }

    return FeedbackModel(
      id: doc.id,
      category: data['category'] as String? ?? 'General Feedback',
      description: data['description'] as String? ?? '',
      email: data['email'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
  final String id;
  final String category;
  final String description;
  final String? email;
  final DateTime? createdAt;
}
