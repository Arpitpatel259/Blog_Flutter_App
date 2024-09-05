// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:blog/Screens/EditPostBlogs.dart';
import 'package:blog/Services/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'BlogDetailScreen.dart';

class showMyBlogPost extends StatefulWidget {
  const showMyBlogPost({super.key});

  @override
  State<showMyBlogPost> createState() => _showMyBlogPostState();
}

class _showMyBlogPostState extends State<showMyBlogPost> {
  Future<List<Map<String, dynamic>>>? _futureBlogs;
  final AuthMethods _authMethods = AuthMethods();
  late SharedPreferences pref;

  String? userId;
  String? profileImageUrl;
  String? name;
  String? email;
  File? _mediaFile;
  int? commentCount;

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      _futureBlogs = _authMethods.getCurrentUserBlogs();
    });

    userId = pref.getString("userId") ?? "";
    name = pref.getString("name") ?? "";
    email = pref.getString("email") ?? "";
    profileImageUrl = pref.getString("imgUrl") ?? "";
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> _uploadProfileImage(File? image) async {
    String userId = pref.getString("userId") ?? "";

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

  Widget buildBlogRow(String blogId) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.mode_comment_outlined,
            color: Colors.black87,
          ),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                return SizedBox(
                  height: 400,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Comments',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Blog')
                              .doc(blogId)
                              .collection('comments')
                              .orderBy('timestamp', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Center(
                                  child: Text('No comments available.'));
                            }

                            return ListView(
                              children: snapshot.data!.docs.map((doc) {
                                var data = doc.data() as Map<String, dynamic>;
                                return ListTile(
                                  title: Text(data['userName'] ?? 'Anonymous'),
                                  subtitle:
                                      Text(data['commentText'] ?? 'No comment'),
                                  trailing: Text(
                                      data['timestamp'].toDate().toString()),
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        FutureBuilder<int>(
          future: _authMethods.countComments(blogId),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            return Text(
              "${snapshot.data}",
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout_sharp,
              color: Colors.white,
            ),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Alert!'),
                    content: const Text('Are you want to logout..'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () async {
                          await pref.clear();
                          _authMethods.logout(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBlogs,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Card(
                elevation: 4, // Shadow effect
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Rounded corners
                ),
                margin: const EdgeInsets.all(16), // Margin around the card
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          File? imageFile = await _pickImage();
                          if (imageFile != null) {
                            setState(() {
                              _mediaFile = imageFile;
                            });
                            await _uploadProfileImage(_mediaFile);
                          }
                        },
                        child: ClipOval(
                          clipBehavior: Clip.hardEdge,
                          child: SizedBox(
                            width: 80,
                            height: 80,
                            child:
                                _authMethods.buildProfileImage(profileImageUrl),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              name ?? 'No Name Provided',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Spacing between name and email
                            Text(
                              email ?? 'No Email Provided',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "My Blogs.",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _futureBlogs,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                        child: Text('Error fetching blog data'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('You haven\'t posted any blogs!'));
                  } else {
                    final blogList = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: blogList.length,
                      itemBuilder: (context, index) {
                        final blog = blogList[index];
                        final Timestamp timestamp = blog['timestamp'];
                        final DateTime dateTime = timestamp.toDate();
                        final String formattedDate =
                            DateFormat.yMMMd().add_jm().format(dateTime);

                        final List<dynamic> likers = blog['likes'] ?? [];
                        final int likeCount = likers.length;

                        final authorImage = pref.getString('imgUrl');

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15), // Rounded corners
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ClipOval(
                                      child: _authMethods.buildProfileImage(authorImage),
                                    ),
                                    const SizedBox(width: 12), // Increased spacing for better alignment
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            blog['author'] ?? 'Unknown Author',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16, // Slightly larger font for emphasis
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: Colors.blueAccent,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => PostEditor(
                                                  isEdit: true,
                                                  blog: blog,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.redAccent,
                                          onPressed: () {
                                            _authMethods.deleteBlogByUser(context, blog['id']);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Blog Deleted Successfully.'),
                                                backgroundColor: Colors.teal,
                                                behavior: SnackBarBehavior.floating,
                                                action: SnackBarAction(
                                                  label: 'Dismiss',
                                                  textColor: Colors.yellow,
                                                  onPressed: () {},
                                                ),
                                              ),
                                            );
                                            _refreshBlogs();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  blog['title'] ?? 'Blog Title',
                                  style: const TextStyle(
                                    fontSize: 20, // Larger title font for emphasis
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlogDetailScreen(
                                          blog: blog,
                                          image: authorImage,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      blog['content'] ?? 'Blog Content',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400, // Normal weight for content
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis, // Ellipsis for long content
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            likeCount > 0 ? Icons.favorite : Icons.favorite_border,
                                            color: likeCount > 0 ? Colors.red : Colors.grey,
                                          ),
                                          onPressed: () {},
                                        ),
                                        Text(
                                          "$likeCount",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    buildBlogRow(blog['id']),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.share_outlined,
                                        color: Colors.black87,
                                      ),
                                      onPressed: () {
                                        _authMethods.shareMessage(
                                          blog['title'],
                                          blog['content'],
                                          blog['author'],
                                          blog['timestamp'],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      fontSize: 12, // Smaller font for date
                                      color: Colors.grey, // Grey color for subtle appearance
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
