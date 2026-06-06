import 'dart:convert';
import 'dart:io';
import 'package:blog/Model/bloglist_model.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class PostEditor extends StatefulWidget {
  final bool isEdit;
  final BlogModel? blog;

  const PostEditor({Key? key, required this.isEdit, this.blog})
      : super(key: key);

  @override
  State<PostEditor> createState() => _PostEditorState();
}

class _PostEditorState extends State<PostEditor> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  File? _mediaFile;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.isEdit ? widget.blog?.title : '');
    _contentController = TextEditingController(text: widget.isEdit ? widget.blog?.content : '');
    _selectedCategory = widget.isEdit ? widget.blog?.category : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview() {
    if (_mediaFile != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.file(_mediaFile!, height: 240, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: IconButton.filled(
              onPressed: () => setState(() => _mediaFile = null),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              style: IconButton.styleFrom(backgroundColor: Colors.black45),
            ),
          ),
        ],
      );
    } else if (widget.isEdit && widget.blog?.imageBase64 != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.memory(base64Decode(widget.blog!.imageBase64!), height: 240, width: double.infinity, fit: BoxFit.cover),
      );
    } else {
      return GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: kInputFill,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kInputBorder, width: 2, style: BorderStyle.none),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add_photo_alternate_rounded, size: 40, color: kPrimaryColor),
              ),
              const SizedBox(height: 12),
              Text('Add a cover image', style: kLabelStyle.copyWith(color: kPrimaryColor)),
              const SizedBox(height: 4),
              Text('Resolution: 16:9 recommended', style: kBodyStyle.copyWith(fontSize: 12)),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _mediaFile = File(pickedFile.path));
    }
  }

  void _submitPost() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: kErrorColor,
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final name = FirebaseAuth.instance.currentUser?.displayName ?? prefs.getString('name');

    showDialog(
      context: context, 
      barrierDismissible: false, 
      builder: (context) => const Center(child: CircularProgressIndicator(color: kPrimaryColor))
    );

    if (widget.isEdit) {
      await AuthMethods().updateBlog(
        widget.blog!.id!, 
        name!, 
        _titleController.text, 
        _contentController.text, 
        _mediaFile, 
        widget.blog!.imageBase64!, 
        context, 
        category: _selectedCategory
      );
    } else {
      if (_mediaFile == null) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an image')));
        }
        return;
      }
      await AuthMethods().uploadPost(name!, _titleController.text, _contentController.text, _mediaFile, context, category: _selectedCategory);
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const MainPage()), (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Story' : 'New Story'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Publish'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImagePreview(),
            const SizedBox(height: 32),
            Text('Story Category', style: kLabelStyle),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: _inputDecoration(hint: 'Select a category'),
              items: ['Tech', 'Lifestyle', 'Education', 'Travel', 'Food', 'God']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextLight),
              dropdownColor: kSurfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            const SizedBox(height: 24),
            Text('Title', style: kLabelStyle),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              style: kHeadingStyle.copyWith(fontSize: 22),
              maxLines: null,
              decoration: _inputDecoration(hint: 'Enter a catchy title...'),
            ),
            const SizedBox(height: 24),
            Text('Content', style: kLabelStyle),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: null,
              minLines: 10,
              style: kBodyStyle.copyWith(fontSize: 16, height: 1.6),
              decoration: _inputDecoration(hint: 'Tell your story here...'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: kBodyStyle.copyWith(color: kTextLight),
      filled: true,
      fillColor: kInputFill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide.none
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: BorderSide.none
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16), 
        borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)
      ),
    );
  }
}
