// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  Future addUser(String userId, Map<String, dynamic> userInfo) {
    return FirebaseFirestore.instance
        .collection("User")
        .doc(userId)
        .set(userInfo);
  }

  Future addBlogs(String userId, Map<String, dynamic> userInfo) {
    return FirebaseFirestore.instance
        .collection('Blog')
        .doc(userId)
        .set(userInfo);
  }
}
