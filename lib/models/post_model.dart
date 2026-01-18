import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String text;
  final String email;
  final Timestamp createdAt;

  Post({
    required this.id,
    required this.text,
    required this.email,
    required this.createdAt,
  });

  factory Post.fromDoc(DocumentSnapshot doc){
    final data = doc.data() as Map<String,dynamic>;
    return Post(
      id: doc.id,
      text: data['text'],
      email: data['email'],
      createdAt: data['createdAt'],
    );
  }
}
