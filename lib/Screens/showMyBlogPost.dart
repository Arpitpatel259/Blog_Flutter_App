// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:blog/Screens/editPostedBlog.dart';
import 'package:blog/Screens/postBlogScreen.dart';
import 'package:blog/Services/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      _futureBlogs = _dbMethods.getCurrentUserBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Blogs'),
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
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 15,
                                backgroundColor: Colors.yellow,
                                child: Icon(Icons.person, color: Colors.white),
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
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditBlogScreen(blog: blog!)),
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
                          Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 200.0,
                                child: blog['imageBase64'] != null
                                    ? Image.memory(
                                        base64Decode(blog['imageBase64']),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 200.0,
                                      )
                                    : Container(
                                        height: 200.0,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.image_outlined,
                                              size: 48),
                                        ),
                                      ),
                              ),
                              Positioned(
                                right: 16.0,
                                left: 16.0,
                                bottom: 16.0,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            BlogDetailScreen(blog: blog),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 12.0),
                                    color: Colors.black.withOpacity(0.5),
                                    // Background with opacity
                                    child: Text(
                                      blog['title'] ?? 'Blog Title',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
