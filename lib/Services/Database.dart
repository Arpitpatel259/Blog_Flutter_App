// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DatabaseMethod {
  Future addUser(String userId, Map<String, dynamic> userInfo) {
    return FirebaseFirestore.instance
        .collection("User")
        .doc(userId)
        .set(userInfo);
  }

  Future<List<Map<String, dynamic>>> getAllBlogs() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Blog').get();

      final List<Map<String, dynamic>> blogList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      print(blogList);
      return blogList;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching blog data: $e');
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCurrentUserBlogs() async {
    try {
      // Get the current user's ID
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('No user is currently signed in.');
        return [];
      }
      final userId = user.uid;

      // Query Firestore to get only the blogs where the 'userId' field matches the current user's ID
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Blog')
          .where('userId', isEqualTo: userId)
          .get();

      // Map the documents to a list of blog data
      final List<Map<String, dynamic>> blogList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return blogList;
    } catch (e) {
      print('Error fetching blog data: $e');
      return [];
    }
  }

  Future addBlogs(String userId, Map<String, dynamic> userInfo) {
    return FirebaseFirestore.instance
        .collection("Blog")
        .doc(userId)
        .set(userInfo);
  }
}
