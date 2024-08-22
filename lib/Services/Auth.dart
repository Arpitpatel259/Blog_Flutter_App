import 'dart:convert';
import 'dart:io';
import 'package:blog/Screens/splashScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:blog/Services/Database.dart';
import 'package:blog/firebase_options.dart';
import 'package:blog/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show Uint8List, defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '658979738135-d2llurejibm6rnlli6d870fpl8ach6qo.apps.googleusercontent.com'
        : null,
  );

  var firstController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var passwordController = TextEditingController();
  var cPasswordController = TextEditingController();

  var authorController = TextEditingController();
  var titleController = TextEditingController();
  var contentController = TextEditingController();

  //getting current User
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  //To check user is logged in or not
  Future<Widget> checkIfAlreadyLogin() async {
    try {
      // Initialize Firebase
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.web,
        );
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool? isLoggedIn = prefs.getBool('isLoggedIn');

      // Return the appropriate widget based on the login status
      if (isLoggedIn == true) {
        return const MainPage();
      } else {
        return const SplashScreen();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking login status: $e');
      }
      // Return an error screen or a default screen
      return const Scaffold(
        body: Center(
          child: Text(
            'An error occurred while checking login status. Please try again.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
    }
  }

  // Google Login
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Web specific initialization
      if (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } else {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.web,
        );
      }

      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential result = await _auth.signInWithCredential(credential);

        User? user = result.user;

        if (user != null) {
          Map<String, dynamic> userInfo = {
            "email": user.email,
            "name": user.displayName,
            "imgUrl": user.photoURL,
            "id": user.uid,
          };
          await DatabaseMethod()
              .addUser(user.uid, userInfo)
              .then((value) async {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('userId', user.uid);
            await prefs.setString('email', user.email.toString());
            await prefs.setString('name', user.displayName.toString());
            await prefs.setString('imgUrl', user.photoURL.toString());

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("You Have Been Logged In Successfully!"),
                backgroundColor: Colors.teal,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Dismiss',
                  disabledTextColor: Colors.white,
                  textColor: Colors.yellow,
                  onPressed: () {},
                ),
              ),
            );

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
                (route) => false);
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing in with Google: $e');
      }
    }
  }

  //Register With Email/Password
  Future<void> registerUser(String name, String email, String mobile,
      String password, String cPassword) async {
    if (password != cPassword) {
      if (kDebugMode) {
        print('Passwords do not match');
      }
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        DatabaseMethod databaseMethod = DatabaseMethod();

        Map<String, dynamic> userInfo = {
          'id': user.uid,
          'name': name,
          'email': email,
          'mobile': mobile,
          'imgUrl': null,
          'password': password,
        };

        await databaseMethod.addUser(user.uid, userInfo);

        firstController.clear();
        emailController.clear();
        mobileController.clear();
        passwordController.clear();
        cPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  //Login with Email/Password
  Future<void> userLogin(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(userCredential.user!.uid)
            .get();

        if (userSnapshot.exists) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString("email", userSnapshot['email']);
          await prefs.setString("name", userSnapshot['name']);
          await prefs.setString("userId", userSnapshot.id);
          await prefs.setString("imgUrl", userSnapshot['imgUrl'] ?? "");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("You Have Been Logged In Successfully!"),
              backgroundColor: Colors.teal,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Dismiss',
                disabledTextColor: Colors.white,
                textColor: Colors.yellow,
                onPressed: () {},
              ),
            ),
          );

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          throw Exception("User data not found in Firestore");
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = "No User Found for that Email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong Password Provided by You";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid Email Provided by You";
      } else {
        errorMessage = "An unknown error occurred";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'An error occurred while logging in. Please try again.'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  //Reset Password Using Link
  Future<void> resetPassword(String emailId, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailId);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Password Reset Email has been sent! Please Login',
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {
              //Do whatever you want
            },
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No user found for that email.',
            ),
            backgroundColor: Colors.teal,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              disabledTextColor: Colors.white,
              textColor: Colors.yellow,
              onPressed: () {
                //Do whatever you want
              },
            ),
          ),
        );
      }
    }
  }

  //Logout Your Session
  Future<void> logout(BuildContext context) async {
    try {
      // Sign out from Google
      await _googleSignIn.signOut();

      // Clear Shared Preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false);
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }

  Future<void> uploadPost(
    String author,
    String title,
    String content,
    File? imageFile,
    BuildContext context, {
    String? category, // Added category parameter
  }) async {
    try {
      // Convert image to Base64 string
      String? imageBase64;
      if (imageFile != null) {
        imageBase64 = await _convertImageToBase64(imageFile);
      }

      // Generate a unique ID for the blog post
      String postId = FirebaseFirestore.instance.collection('Blog').doc().id;

      DatabaseMethod databaseMethod = DatabaseMethod();
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Create a Map to hold the blog post data
      Map<String, dynamic> postData = {
        'id': postId,
        'userId': prefs.getString('userId'),
        'author': author,
        'title': title,
        'content': content,
        'imageBase64': imageBase64,
        'likes': [],
        'category': category, // Include category in post data
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Call the addBlogs function to upload the blog post
      await databaseMethod.addBlogs(postId, postData);

      // Clear the text fields
      authorController.clear();
      titleController.clear();
      contentController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Blog post uploaded successfully!'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {
              // Do whatever you want
            },
          ),
        ),
      );
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload blog post: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {
              // Do whatever you want
            },
          ),
        ),
      );
    }
  }

  //Convert Image
  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  //Delete Blog Which is Post by user
  Future<void> deleteBlogByUser(BuildContext context, String blogId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('Blog').doc(blogId).delete();
    } catch (e) {}
  }

  Future<void> updateBlog(
    String blogId,
    String author,
    String title,
    String content,
    File? mediaFile,
    String existingImageBase64,
    BuildContext context, {
    String? category, // Added category parameter
  }) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      String? imageBase64 = existingImageBase64;

      if (mediaFile != null) {
        imageBase64 = await _convertImageToBase64(mediaFile);
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> postData = {
        'id': blogId,
        'userId': prefs.getString('userId'),
        'author': author,
        'title': title,
        'content': content,
        'imageBase64': imageBase64,
        'category': category, // Include category in post data
        'timestamp': FieldValue.serverTimestamp(),
      };

      await firestore.collection('Blog').doc(blogId).update(postData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Blog post updated successfully!'),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {
              // Do whatever you want
            },
          ),
        ),
      );
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating blog post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  //To show Profile images
  Widget buildProfileImage(String? base64Image) {
    if (base64Image == null || base64Image.isEmpty) {
      // Handle the case where no image is provided
      return const Icon(
        Icons.account_circle,
        size: 50,
        color: Colors.grey,
      );
    }

    // Heuristic to check if the input is a URL or Base64 string
    if (base64Image.startsWith('http') || base64Image.startsWith('https')) {
      // If it starts with http or https, treat it as a network URL
      return Image.network(
        base64Image,
        fit: BoxFit.cover,
        width: 50,
        height: 50,
      );
    } else {
      try {
        // Decode the Base64 string to bytes
        Uint8List imageBytes = base64Decode(base64Image);

        return ClipOval(
          child: Image.memory(
            imageBytes,
            fit: BoxFit.cover,
            width: 50,
            height: 50,
          ),
        );
      } catch (e) {
        // Handle errors during decoding
        print('Error decoding Base64 image: $e');
        return const Icon(
          Icons.error,
          size: 50,
          color: Colors.red,
        );
      }
    }
  }

  //Get all blogs from DB
  Future<List<Map<String, dynamic>>> getAllBlogs() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Blog')
          .orderBy('timestamp', descending: true)
          .get();

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

  //Get that blogs which is post by current user
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

  //Create comment in any blogs
  Future<void> addComment(String blogId, String commentText) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser!;
    final userName = user.displayName ?? prefs.getString('name');
    final userId = user.uid;

    try {
      // Generate a new document reference with a unique ID
      final commentDoc = _firestore
          .collection('Blog')
          .doc(blogId)
          .collection('comments')
          .doc(); // Auto-generated ID

      // Use the generated ID in the comment data
      await commentDoc.set({
        'id': commentDoc.id, // Ensure this is the auto-generated ID
        'userName': userName,
        'commentText': commentText,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Handle any errors that occur during the add operation
      print('Error adding comment: $e');
    }
  }

  //Create a count of comment
  Future<int> countComments(String blogId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // Get all documents in the comments collection for the specified blog
      QuerySnapshot snapshot = await firestore
          .collection('Blog')
          .doc(blogId)
          .collection('comments')
          .get();

      // Return the count of documents in the snapshot
      return snapshot.docs.length;
    } catch (e) {
      print('Error counting comments: $e');
      return 0;
    }
  }

  Future<void> savePost(String userId, Map<String, dynamic> blog) async {
    try {
      final savedPostsRef = _firestore
          .collection('User')
          .doc(userId)
          .collection('SavedPosts') // Ensure this matches across all methods
          .doc(blog['id']);

      final savedPostSnapshot = await savedPostsRef.get();

      if (savedPostSnapshot.exists) {
        await savedPostsRef.delete();
      } else {
        await savedPostsRef.set(blog);
      }
    } catch (e) {
      print('Error saving post: $e');
    }
  }

  Future<bool> isPostSaved(String userId, String postId) async {
    try {
      final savedPostSnapshot = await _firestore
          .collection('User')
          .doc(userId)
          .collection('SavedPosts') // Ensure consistency here too
          .doc(postId)
          .get();
      return savedPostSnapshot.exists;
    } catch (e) {
      // Consider logging the error here
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSavedPosts(
      String userId, BuildContext context) async {
    try {
      final savedPostsRef = _firestore
          .collection('User')
          .doc(userId)
          .collection('SavedPosts'); // Ensure consistency

      final querySnapshot = await savedPostsRef.get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to retrieve saved posts: $e')),
      );
      return [];
    }
  }
}
