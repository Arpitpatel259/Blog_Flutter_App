import 'dart:convert';

import 'package:blog/Screens/BlogDetailScreen.dart';
import 'package:blog/Services/Database.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BlogList extends StatefulWidget {
  const BlogList({super.key});

  @override
  _BlogListState createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  late Future<List<Map<String, dynamic>>> _futureBlogs;
  final DatabaseMethod _authMethods = DatabaseMethod();

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      _futureBlogs = _authMethods.getAllBlogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              return const Center(child: Text('No blogs available'));
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
                  return GestureDetector(
                    onTap: () {
                      // Handle card tap, e.g., navigate to a detailed view
                    },
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 15,
                                      backgroundColor: Colors.yellow,
                                      child: Icon(Icons.person,
                                          color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          blog['author'] ?? 'Unknown',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
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
                                      icon: const Icon(Icons.mode_comment_outlined),
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
                                  icon: const Icon(Icons.bookmark_border_outlined),
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
