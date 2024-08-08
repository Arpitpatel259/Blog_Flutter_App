import 'dart:convert';

import 'package:blog/Screens/BlogDetailScreen.dart';
import 'package:blog/Services/Database.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _blogList = [];

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    final blogs = await _authMethods.getAllBlogs();
    setState(() {
      _blogList = blogs;
    });
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    final user = _auth.currentUser!;
    final userName = user.displayName ?? 'Anonymous';

    // Optimistically update local state
    setState(() {
      _blogList = _blogList.map((blog) {
        if (blog['id'] == blogId) {
          final List<dynamic> likes = blog['likes'] ?? [];
          final List<dynamic> likers = blog['likers'] ?? [];
          final bool newIsLiked = !isLiked;
          final List<dynamic> updatedLikes = newIsLiked
              ? [...likes, userName]
              : likes.where((name) => name != userName).toList();
          final List<dynamic> updatedLikers = newIsLiked
              ? [...likers, userName]
              : likers.where((name) => name != userName).toList();
          return {
            ...blog,
            'likes': updatedLikes,
            'likers': updatedLikers,
          };
        }
        return blog;
      }).toList();
    });

    try {
      if (isLiked) {
        // Remove like
        await _firestore.collection('Blog').doc(blogId).update({
          'likes': FieldValue.arrayRemove([userName]),
          'likers': FieldValue.arrayRemove([userName]),
        });
      } else {
        // Add like
        await _firestore.collection('Blog').doc(blogId).update({
          'likes': FieldValue.arrayUnion([userName]),
          'likers': FieldValue.arrayUnion([userName]),
        });
      }
    } catch (e) {
      print("Error updating like: $e");
      // Optionally revert the optimistic update if the error occurs
      setState(() {
        _blogList = _blogList.map((blog) {
          if (blog['id'] == blogId) {
            final List<dynamic> likes = blog['likes'] ?? [];
            final List<dynamic> likers = blog['likers'] ?? [];
            final bool revertedIsLiked = !isLiked;
            final List<dynamic> revertedLikes = revertedIsLiked
                ? likes.where((name) => name != userName).toList()
                : [...likes, userName];
            final List<dynamic> revertedLikers = revertedIsLiked
                ? likers.where((name) => name != userName).toList()
                : [...likers, userName];
            return {
              ...blog,
              'likes': revertedLikes,
              'likers': revertedLikers,
            };
          }
          return blog;
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshBlogs,
        child: ListView.builder(
          itemCount: _blogList.length,
          itemBuilder: (context, index) {
            final blog = _blogList[index];
            final Timestamp timestamp = blog['timestamp'];
            final DateTime dateTime = timestamp.toDate();
            final String formattedDate =
                DateFormat.yMMMd().add_jm().format(dateTime);
            final userName = _auth.currentUser?.displayName ?? 'Anonymous';
            final List<dynamic> likes = blog['likes'] ?? [];
            final List<dynamic> likers = blog['likers'] ?? [];
            final bool isLiked = likes.contains(userName);
            final int likeCount = likers.length;

            return GestureDetector(
              onTap: () {},
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
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      child:
                                          Icon(Icons.image_outlined, size: 48),
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
                                icon: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                ),
                                onPressed: () {
                                  _toggleLike(blog['id'], isLiked);
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
                        "$likeCount likes",
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (likers.isNotEmpty)
                        Text(
                          "Liked by: ${likers.join(', ')}",
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      const SizedBox(height: 5.0),
                      Text(
                        formattedDate,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
