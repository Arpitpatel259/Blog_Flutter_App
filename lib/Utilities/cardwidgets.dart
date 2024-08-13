import 'package:blog/Services/Auth.dart';
import 'package:blog/Services/Database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Screens/BlogDetailScreen.dart';

class BlogList extends StatefulWidget {
  const BlogList({super.key});

  @override
  State<BlogList> createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  final DatabaseMethod _databaseMethod = DatabaseMethod();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _blogList = [];
  final Map<String, String> _profileImages = {};
  AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    _refreshBlogs();

  }

  Future<void> _refreshBlogs() async {
    final blogs = await _databaseMethod.getAllBlogs();
    setState(() {
      _blogList = blogs;
    });
    // Fetch profile images after blogs are loaded
    for (var blog in blogs) {
      await _getImage(blog['userId']);
    }
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    final prefs = await SharedPreferences.getInstance();
    String userName =
        prefs.getString('name') ?? 'Anonymous'; // Provide a fallback value

    // Optimistically update local state
    setState(() {
      _blogList = _blogList.map((blog) {
        if (blog['id'] == blogId) {
          final List<dynamic> likes = blog['likes'] ?? [];
          final bool newIsLiked = !isLiked;
          final List<dynamic> updatedLikes = newIsLiked
              ? [...likes, userName]
              : likes.where((name) => name != userName).toList();
          return {
            ...blog,
            'likes': updatedLikes,
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
        });
      } else {
        // Add like
        await _firestore.collection('Blog').doc(blogId).update({
          'likes': FieldValue.arrayUnion([userName]),
        });
      }
    } catch (e) {
      // Optionally revert the optimistic update if the error occurs
      setState(() {
        _blogList = _blogList.map((blog) {
          if (blog['id'] == blogId) {
            final List<dynamic> likes = blog['likes'] ?? [];
            final bool revertedIsLiked = !isLiked;
            final List<dynamic> revertedLikes = revertedIsLiked
                ? likes.where((name) => name != userName).toList()
                : [...likes, userName];
            return {
              ...blog,
              'likes': revertedLikes,
            };
          }
          return blog;
        }).toList();
      });
    }
  }

  Future<void> _getImage(String userId) async {
    if (_profileImages.containsKey(userId)) {
      return; // Image already fetched
    }

    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();

    if (userSnapshot.exists) {
      setState(() {
        _profileImages[userId] = userSnapshot['imgUrl'];
      });
    }
  }

  Future<void> _addComment(String blogId, String commentText) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final user = _auth.currentUser!;
    final userName = user.displayName ?? prefs.getString('name');
    final userId = user.uid;

    try {
      await _firestore
          .collection('Blog')
          .doc(blogId)
          .collection('comments')
          .add({
        'userName': userName,
        'commentText': commentText,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  void _showCommentBottomSheet(String blogId) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              // Set to min to dynamically adjust
              children: [
                Flexible(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('Blog')
                        .doc(blogId)
                        .collection('comments')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No comments yet.'));
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        // Allows the list to take only needed space
                        physics: const NeverScrollableScrollPhysics(),
                        // Prevents scrolling within the bottom sheet
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final commentData =
                              comments[index].data() as Map<String, dynamic>;
                          final userName =
                              commentData['userName'] ?? 'Anonymous';
                          final commentText = commentData['commentText'] ?? '';

                          // Check if timestamp exists and is not null
                          final timestamp = commentData['timestamp'];
                          final DateTime? dateTime = timestamp != null
                              ? (timestamp as Timestamp).toDate()
                              : null;
                          final String formattedDate = dateTime != null
                              ? DateFormat.yMMMd().format(dateTime)
                              : '';

                          // Get author image
                          final String? authorId = commentData['userId'];
                          final String? authorImage = _profileImages[authorId];

                          return ListTile(
                            leading: ClipOval(
                              child: Container(
                                color: Colors.blueGrey,
                                child: authorImage != null
                                    ? Image.network(
                                        authorImage,
                                        fit: BoxFit.cover,
                                        width: 50,
                                        height: 50,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Provide a fallback icon if the image fails to load
                                          return const Icon(
                                            Icons.account_circle,
                                            size: 50,
                                            color: Colors.white,
                                          );
                                        },
                                      )
                                    : const Icon(
                                        Icons.account_circle,
                                        size: 50,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            title: Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              commentText,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            trailing: Text(
                              formattedDate,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your comment',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        if (commentController.text.isNotEmpty) {
                          _addComment(blogId, commentController.text);
                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
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

            // Asynchronous SharedPreferences retrieval
            return FutureBuilder<SharedPreferences>(
              future: SharedPreferences.getInstance(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final prefs = snapshot.data!;
                final String userName = prefs.getString('name') ?? 'Anonymous';
                final List<dynamic> likes = blog['likes'] ?? [];
                final bool isLiked = likes.contains(userName);
                final int likeCount = likes.length;

                // Get author image
                final String authorId = blog['userId'];
                final String? authorImage = _profileImages[authorId];

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
                                  ClipOval(
                                    child: authMethods
                                        .buildProfileImage(authorImage),
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
                          Text(
                            blog['title'] ?? 'Blog Title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlogDetailScreen(
                                        blog: blog, image: authorImage),
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
                                      color:
                                          isLiked ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () {
                                      _toggleLike(blog['id'], isLiked);
                                    },
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.mode_comment_outlined),
                                    onPressed: () {
                                      _showCommentBottomSheet(blog['id']);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.send_outlined),
                                    onPressed: () {
                                      Share.share(
                                          '${blog['title']}\nRead more at: ${blog['content']}');
                                    },
                                  ),
                                ],
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.bookmark_border_outlined),
                                onPressed: () {},
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
                          const SizedBox(height: 5.0),
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
          },
        ),
      ),
    );
  }
}
