// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:blog/Screens/EditPostBlogs.dart';
import 'package:blog/Services/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/Database.dart';
import 'BlogDetailScreen.dart';

class showMyBlogPost extends StatefulWidget {
  const showMyBlogPost({super.key});

  @override
  State<showMyBlogPost> createState() => _showMyBlogPostState();
}

class _showMyBlogPostState extends State<showMyBlogPost> {
  Future<List<Map<String, dynamic>>>? _futureBlogs;
  final DatabaseMethod _dbMethods = DatabaseMethod();
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late SharedPreferences pref;

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      _futureBlogs = _dbMethods.getCurrentUserBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueGrey, Colors.blueGrey],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBlogs,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureBlogs,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching blog data'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('You haven\'t post any blogs!'));
            } else {
              final blogList = snapshot.data!;
              return ListView.builder(
                itemCount: blogList.length,
                itemBuilder: (context, index) {
                  final blog = blogList[index];
                  final Timestamp timestamp = blog['timestamp'];
                  final DateTime dateTime = timestamp.toDate();
                  final String formattedDate =
                      DateFormat.yMMMd().add_jm().format(dateTime);

                  final authorImage =
                      _auth.currentUser?.photoURL ?? pref.getString('imgUrl');

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipOval(
                                child:
                                    _authMethods.buildProfileImage(authorImage),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      blog['author'] ?? 'Unknown',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.red),
                                    onPressed: () {
                                      print("Edit Clicked");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PostEditor(
                                                isEdit: true, blog: blog)),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      print("Delete Clicked");
                                      _authMethods.deleteBlogByUser(
                                          context, blog['id']);
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
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
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
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 12.0),
                              color: Colors.black.withOpacity(0.5),
                              child: Text(
                                blog['content'] ?? 'Blog Title',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 5,
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.center,
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
                                    icon: const Icon(Icons.favorite_border),
                                    onPressed: () {
                                      print("Favourite Clicked");
                                    },
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.mode_comment_outlined),
                                    onPressed: () {
                                      print("Comment Clicked");
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send_outlined),
                                    onPressed: () {
                                      print("Share Clicked");
                                    },
                                  ),
                                ],
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.bookmark_border_outlined),
                                onPressed: () {
                                  print("Saved Clicked");
                                },
                              ),
                            ],
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                                fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
