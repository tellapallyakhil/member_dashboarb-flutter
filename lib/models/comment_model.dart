import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String text;
  final String email;
  final Timestamp createdAt;

  Comment({
    required this.text,
    required this.email,
    required this.createdAt,
  });

  factory Comment.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      text: data['commentText'],
      email: data['commentedBy'],
      createdAt: data['commentedAt'],
    );
  }
}
