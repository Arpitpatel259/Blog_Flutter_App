import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late SharedPreferences logindata;
  late String userId; // Added for userId

  var email = "";
  var name = "";
  var enrollment = "";
  var mobileno = "";
  var organization = "";
  late String profileImageUrl = ""; // Holds the current profile image URL

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    logindata = await SharedPreferences.getInstance();
    userId = logindata.getString("userId") ?? ""; // Initialize userId
    name = logindata.getString("name") ?? "";
    email = logindata.getString("email") ?? "";
    enrollment = logindata.getString("enrollment") ?? "";
    mobileno = logindata.getString("mobile") ?? "";
    organization = logindata.getString("organization") ?? "";

    // Retrieve the profile image URL from SharedPreferences
    profileImageUrl = logindata.getString("imgUrl") ?? "";

    setState(() {});
  }

  File? _imageFile;

  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Call function to upload image to Firebase Storage
      await _uploadProfileImage();
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'CustomFont',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (profileImageUrl.isNotEmpty
                              ? NetworkImage(profileImageUrl)
                              : AssetImage('assets/images/logo.png')
                          as ImageProvider),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildProfileItem('Name', name),
                      buildProfileItem('Email', email),
                      buildProfileItem('Mobile No', mobileno),
                      buildProfileItem('Enrollment ID', enrollment),
                      buildProfileItem('Organization', organization),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'About App',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'CustomFont',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showAppInfoDialog(context);
                        },
                        icon: const Icon(Icons.info),
                        label: const Text(
                          'App Information',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontFamily: 'CustomFont',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontFamily: 'CustomFont',
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontSize: 18)),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfileImage() async {
    String fileName = userId + '_profile.jpg'; // Unique file name for the user's profile image
    Reference storageRef =
    FirebaseStorage.instance.ref().child('profile_images/$fileName');

    try {
      // Upload image to Firebase Storage
      UploadTask uploadTask = storageRef.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      // Get download URL from snapshot
      String downloadURL = await snapshot.ref.getDownloadURL();

      // Update profile image URL in SharedPreferences
      logindata.setString("imgUrl", downloadURL);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image uploaded successfully')),
      );

      setState(() {
        profileImageUrl = downloadURL; // Update current profile image URL in the widget
      });
    } catch (e) {
      print('Error uploading profile image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile image')),
      );
    }
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('App Information'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Version: 1.0.0'),
                Text('Developer: Kanudo Creation'),
                Text('Description: This app is built for day-to-day communication between users and clients.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}