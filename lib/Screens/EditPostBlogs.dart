import 'dart:convert';
import 'dart:io';
import 'package:blog/Services/Auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class PostEditor extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? blog;

  const PostEditor({Key? key, required this.isEdit, this.blog})
      : super(key: key);

  @override
  State<PostEditor> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  bool _isBold = false,
      _isItalic = false,
      _isUnderline = false,
      _isStrikethrough = false;
  File? _mediaFile;
  String? _selectedCategory;

  @override
  void initState() {
    if (widget.isEdit) {
      _titleController = TextEditingController(text: widget.blog?['title']);
      _contentController = TextEditingController(text: widget.blog?['content']);
      _selectedCategory = widget.blog?['category'];
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget? _displayImage(String? base64String, File? mediaFile) {
    if (base64String != null) {
      // Decode Base64 string to bytes
      Uint8List bytes = base64Decode(base64String);
      // Create an Image from the bytes
      return Image.memory(
        bytes,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (mediaFile != null) {
      return kIsWeb
          ? Image.network(
              mediaFile.path,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            )
          : Image.file(
              File(mediaFile.path),
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            );
    } else {
      return Image.asset(
        'assets/logos/blog_sample.png',
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  void _uploadBlogPost() async {
    if (_mediaFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final name = FirebaseAuth.instance.currentUser?.displayName ??
          prefs.getString('name');

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await AuthMethods().uploadPost(
        name!,
        _titleController.text,
        _contentController.text,
        _mediaFile,
        context,
        category: _selectedCategory,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Please select an image!'),
        backgroundColor: Colors.teal,
        action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
      ));
    }
  }

  void _updateBlogPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = FirebaseAuth.instance.currentUser?.displayName ??
        prefs.getString('name');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await AuthMethods().updateBlog(
      widget.blog?['id'],
      name!,
      _titleController.text,
      _contentController.text,
      _mediaFile,
      widget.blog?['imageBase64'],
      context,
      category: _selectedCategory,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEdit ? 'Update Blog' : 'Post Blog',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_sharp, color: Colors.white),
            onPressed: () async {
              if (_titleController.text.isNotEmpty &&
                  _contentController.text.isNotEmpty &&
                  _selectedCategory != null) {
                widget.isEdit ? _updateBlogPost() : _uploadBlogPost();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text('Please fill all fields!'),
                  backgroundColor: Colors.teal,
                  action: SnackBarAction(label: 'Dismiss', onPressed: () {}),
                ));
              }
            },
          ),
          const SizedBox(width: 10.0),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 200.0,
                child: _displayImage(widget.blog?['imageBase64'], _mediaFile),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter your title',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[300]!),
                  ),
                ),
                items: [
                  'Tech',
                  'Lifestyle',
                  'Education',
                  'Travel',
                  'Food',
                  'God'
                ].map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contentController,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: _isUnderline
                      ? TextDecoration.underline
                      : _isStrikethrough
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                ),
                decoration: InputDecoration(
                  labelText: 'Content',
                  hintText: 'Tap to write',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[300]!),
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.format_bold,
                          color: _isBold ? Colors.blue : Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isBold = !_isBold;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.format_italic,
                          color: _isItalic ? Colors.blue : Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isItalic = !_isItalic;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.format_underline,
                          color: _isUnderline ? Colors.blue : Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isUnderline = !_isUnderline;
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.format_strikethrough_outlined,
                          color: _isStrikethrough ? Colors.blue : Colors.grey),
                      onPressed: () {
                        setState(() {
                          _isStrikethrough = !_isStrikethrough;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.image, color: Colors.orangeAccent),
                      onPressed: () async {
                        File? imageFile = await _pickImage();
                        setState(() {
                          _mediaFile = imageFile;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
