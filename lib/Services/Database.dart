import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethod {
  Future addUser(String userId, Map<String, dynamic> userInfo) {
    return FirebaseFirestore.instance
        .collection("User")
        .doc(userId)
        .set(userInfo);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      // Get a reference to the 'User' collection
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .get();

      // Map each document snapshot to a map of its data
      final List<Map<String, dynamic>> userList = querySnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();

      return userList;
    } catch (e) {
      // Handle errors (e.g., network issues, permission errors)
      print('Error fetching user data: $e');
      return [];
    }
  }

}
