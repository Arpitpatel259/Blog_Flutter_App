import 'dart:convert';
import 'dart:io';

import 'package:blog/Services/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late String userId;
  late String profileImageUrl;
  late String name;
  late String email;

  AuthMethods authMethods = AuthMethods();
  File? _mediaFile;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    logindata = await SharedPreferences.getInstance();
    userId = logindata.getString("userId") ?? "";
    name = logindata.getString("name") ?? "";
    email = logindata.getString("email") ?? "";
    profileImageUrl = logindata.getString("imgUrl") ?? "";

    setState(() {});
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> _uploadProfileImage(File? image) async {
    String userId = logindata.getString("userId") ?? "";

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is not set.')),
      );
      return;
    }

    if (image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image file selected.')),
      );
      return;
    }

    try {
      String base64Image = await _convertImageToBase64(image);

      await FirebaseFirestore.instance.collection('User').doc(userId).update({
        'imgUrl': base64Image,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('imgUrl', base64Image);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image uploaded successfully')),
      );

      setState(() {
        profileImageUrl = base64Image;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to upload profile image')),
      );
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: GestureDetector(
                onTap: () async {
                  File? imageFile = await _pickImage();
                  setState(() async {
                    _mediaFile = imageFile;
                    await _uploadProfileImage(_mediaFile);
                  });
                },
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: profileImageUrl.isNotEmpty
                      ? MemoryImage(base64Decode(profileImageUrl))
                      : null,
                  child: profileImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              email,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                primary: Colors.blueGrey,
                onPrimary: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Edit Profile'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        const Text(
                          'About App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        IconButton(
                          onPressed: () {
                            _showAppInfoDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            onPrimary: Colors.white,
                          ),
                          icon: const Icon(Icons.info_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                Text(
                    'Description: This app is built for day-to-day communication between users and clients.'),
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
