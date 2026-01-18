import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference posts =
      FirebaseFirestore.instance.collection('posts');

  Future<void> addPost(String text, String email) {
    return posts.add({
      'text': text,
      'email': email,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getPosts() {
    return posts.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> addComment(
      String postId, String comment, String email) {
    return posts
        .doc(postId)
        .collection('comments')
        .add({
      'commentText': comment,
      'commentedBy': email,
      'commentedAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getComments(String postId) {
    return posts
        .doc(postId)
        .collection('comments')
        .orderBy('commentedAt', descending: true)
        .snapshots();
  }
}
