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
  final TextAlign _textAlign = TextAlign.left;

  Widget? _displayImage(File? mediaFile) {
    if (mediaFile == null) {
      return Image.asset('assets/logos/blog_sample.png', fit: BoxFit.cover);
    }
    return kIsWeb
        ? Image.network(mediaFile.path,
            height: 200, width: double.infinity, fit: BoxFit.cover)
        : Image.file(File(mediaFile.path),
            height: 200, width: double.infinity, fit: BoxFit.cover);
  }

  void _applyTextStyle() {
    print(
        'Formatting applied - Bold: $_isBold, Italic: $_isItalic, Underline: $_isUnderline, Strikethrough: $_isStrikethrough');
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  @override
  void initState() {
    if (widget.isEdit) {
      _titleController = TextEditingController(text: widget.blog?['title']);
      _contentController = TextEditingController(text: widget.blog?['content']);
    }
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _UploadBlogPost() async {
    if (_mediaFile != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final name = FirebaseAuth.instance.currentUser?.displayName ??
          prefs.getString('name');
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await AuthMethods().uploadPost(name!, _titleController.text,
          _contentController.text, _mediaFile, context);
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

  void _UpdateBlogPost() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = FirebaseAuth.instance.currentUser?.displayName ??
        prefs.getString('name');

    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevents dismissal when tapping outside
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await AuthMethods().updateBlog(
      widget.blog?['id'],
      name!,
      _titleController.text,
      _contentController.text,
      _mediaFile,
      widget.blog?['imageBase64'],
      context,
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return widget.isEdit == false
        ? Scaffold(
            appBar: AppBar(
              title: const Text('Post Blogs'),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColorDark, theme.primaryColorLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.upload_sharp, color: Colors.white),
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty &&
                        _contentController.text.isNotEmpty) {
                      _UploadBlogPost();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Please write some content!'),
                        backgroundColor: Colors.teal,
                        action:
                            SnackBarAction(label: 'Dismiss', onPressed: () {}),
                      ));
                    }
                  },
                ),
                const SizedBox(width: 10.0),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                      width: double.infinity,
                      height: 200.0,
                      child: _displayImage(_mediaFile)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter your title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlign: _textAlign,
                      style: TextStyle(
                        fontWeight:
                            _isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            _isItalic ? FontStyle.italic : FontStyle.normal,
                        decoration: _isUnderline
                            ? TextDecoration.underline
                            : _isStrikethrough
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        hintText: 'Tap to write',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(Icons.format_bold,
                                color:
                                    _isBold ? iconColor : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isBold = !_isBold;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.format_italic,
                                color: _isItalic
                                    ? iconColor
                                    : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isItalic = !_isItalic;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.format_underline,
                                color: _isUnderline
                                    ? iconColor
                                    : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isUnderline = !_isUnderline;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.format_strikethrough_outlined,
                                color: _isStrikethrough
                                    ? iconColor
                                    : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isStrikethrough = !_isStrikethrough;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: const Icon(Icons.image,
                                color: Colors.orangeAccent),
                            onPressed: () async {
                              File? imageFile = await _pickImage();
                              setState(() {
                                _mediaFile = imageFile;
                              });
                            }),
                        IconButton(
                            icon: const Icon(Icons.format_list_numbered_sharp,
                                color: Colors.orangeAccent),
                            onPressed: _toggleOrderedList),
                        IconButton(
                            icon: const Icon(Icons.format_list_bulleted,
                                color: Colors.orangeAccent),
                            onPressed: _toggleBulletedList),
                        IconButton(
                            icon: const Icon(Icons.code_outlined,
                                color: Colors.orangeAccent),
                            onPressed: _insertCode),
                        IconButton(
                            icon: const Icon(Icons.format_quote_sharp,
                                color: Colors.orangeAccent),
                            onPressed: _insertQuote),
                        IconButton(
                            icon: const Icon(Icons.link,
                                color: Colors.orangeAccent),
                            onPressed: _insertLink),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Update Blogs'),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.primaryColorDark, theme.primaryColorLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.upload_sharp, color: Colors.white),
                  onPressed: () async {
                    if (_titleController.text.isNotEmpty &&
                        _contentController.text.isNotEmpty) {
                      _UpdateBlogPost();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Please write some content!'),
                        backgroundColor: Colors.teal,
                        action:
                            SnackBarAction(label: 'Dismiss', onPressed: () {}),
                      ));
                    }
                  },
                ),
                const SizedBox(width: 10.0),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 200.0,
                    child: _mediaFile == null
                        ? Image.memory(
                            base64Decode(widget.blog?['imageBase64']),
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
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter your title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      textAlign: _textAlign,
                      style: TextStyle(
                        fontWeight:
                            _isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            _isItalic ? FontStyle.italic : FontStyle.normal,
                        decoration: _isUnderline
                            ? TextDecoration.underline
                            : _isStrikethrough
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        hintText: 'Tap to write',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            icon: Icon(Icons.format_bold,
                                color:
                                    _isBold ? iconColor : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isBold = !_isBold;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.format_italic,
                                color: _isItalic
                                    ? iconColor
                                    : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isItalic = !_isItalic;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.format_underline,
                                color: _isUnderline
                                    ? iconColor
                                    : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isUnderline = !_isUnderline;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: Icon(Icons.format_strikethrough_outlined,
                                color: _isStrikethrough
                                    ? iconColor
                                    : Colors.orangeAccent),
                            onPressed: () {
                              setState(() {
                                _isStrikethrough = !_isStrikethrough;
                                _applyTextStyle();
                              });
                            }),
                        IconButton(
                            icon: const Icon(Icons.image,
                                color: Colors.orangeAccent),
                            onPressed: () async {
                              File? imageFile = await _pickImage();
                              setState(() {
                                _mediaFile = imageFile;
                              });
                            }),
                        IconButton(
                            icon: const Icon(Icons.format_list_numbered_sharp,
                                color: Colors.orangeAccent),
                            onPressed: _toggleOrderedList),
                        IconButton(
                            icon: const Icon(Icons.format_list_bulleted,
                                color: Colors.orangeAccent),
                            onPressed: _toggleBulletedList),
                        IconButton(
                            icon: const Icon(Icons.code_outlined,
                                color: Colors.orangeAccent),
                            onPressed: _insertCode),
                        IconButton(
                            icon: const Icon(Icons.format_quote_sharp,
                                color: Colors.orangeAccent),
                            onPressed: _insertQuote),
                        IconButton(
                            icon: const Icon(Icons.link,
                                color: Colors.orangeAccent),
                            onPressed: _insertLink),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  void _toggleOrderedList() {}

  void _toggleBulletedList() {}

  void _insertCode() {}

  void _insertQuote() {}

  void _insertLink() {}
}
