import 'dart:convert';
import 'dart:io';

import 'package:blog/Services/Auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';

class EditBlogScreen extends StatefulWidget {
  final Map<String, dynamic> blog; // Blog data passed from previous screen

  const EditBlogScreen({Key? key, required this.blog}) : super(key: key);

  @override
  State<EditBlogScreen> createState() => _EditBlogScreenState();
}

class _EditBlogScreenState extends State<EditBlogScreen> {
  File? _mediaFile;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _authorController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.blog['title']);
    _contentController = TextEditingController(text: widget.blog['content']);
    _authorController = TextEditingController(text: widget.blog['author']);
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

  void _saveChanges() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevents dismissal when tapping outside
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await AuthMethods().updateBlog(
      widget.blog['id'],
      _authorController.text,
      _titleController.text,
      _contentController.text,
      _mediaFile,
      widget.blog['imageBase64'],
      context,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
          (Route<dynamic> route) => false,
    );
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
        title: const Text('Edit Blog'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 200.0,
                    child: _mediaFile == null
                        ? Image.memory(
                      base64Decode(widget.blog['imageBase64']),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200.0,
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
      ),
    );
  }
}