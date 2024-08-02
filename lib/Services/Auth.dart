import 'package:blog/Authentication/userLogin.dart';
import 'package:blog/Screens/Dashboard.dart';
import 'package:blog/Services/Database.dart';
import 'package:blog/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb ? '658979738135-d2llurejibm6rnlli6d870fpl8ach6qo.apps.googleusercontent.com' : null,
  );

  var firstController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var passwordController = TextEditingController();
  var cPasswordController = TextEditingController();

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
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
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()),
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
          await prefs.setString("id", userSnapshot.id);

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
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
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
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const userLoginScreen()));
    } catch (e) {
      if (kDebugMode) {
        print('Error during logout: $e');
      }
    }
  }
}
