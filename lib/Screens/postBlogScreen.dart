import 'dart:io';

import 'package:blog/Services/Auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class PostBlogScreen extends StatefulWidget {
  @override
  State<PostBlogScreen> createState() => _PostBlogScreenState();
}

class _PostBlogScreenState extends State<PostBlogScreen> {
  File? _mediaFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  late TextEditingController _authorController = TextEditingController();

  late SharedPreferences logindata;
  late bool newuser;

  int i = 3;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    logindata = await SharedPreferences.getInstance();
    setState(() {
      newuser = (logindata.getBool('isLoggedIn') ?? false);
      _authorController =
          TextEditingController(text: logindata.getString("name") ?? "");
      print(_authorController);
    });
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  void fun() async {
    File? imageFile = await _pickImage();
    setState(() {
      _mediaFile = imageFile;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Blogs', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.upload_sharp,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_authorController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty) {
                if (_mediaFile != null) {
                  await Future.delayed(Duration(seconds: 2));

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    // Prevents dismissal when tapping outside
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  await AuthMethods().uploadPost(
                      _authorController.text,
                      _titleController.text,
                      _contentController.text,
                      _mediaFile,
                      context);
                  await Future.delayed(Duration(seconds: 2));

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (Route<dynamic> route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Please select relevent Image!',
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
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                      'Please fill up all details!',
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
            },
          ),
          const SizedBox(width: 10.0),
        ],
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 200.0,
                            child: _mediaFile == null
                                ? Image.asset(
                                    'assets/logos/blog_sample.png',
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(_mediaFile!.path),
                                    height: 200.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            left: 8.0,
                            bottom: 8.0,
                            child: GestureDetector(
                              onTap: fun,
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                color: Colors.black54,
                                size: 30.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
