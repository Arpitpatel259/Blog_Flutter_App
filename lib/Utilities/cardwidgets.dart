import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Services/Auth.dart';
import '../Screens/BlogDetailScreen.dart';

class BlogList extends StatefulWidget {
  const BlogList({super.key});

  @override
  State<BlogList> createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _blogList = [];
  List<Map<String, dynamic>> _filteredBlogList = [];
  bool _isLoading = false;
  final Map<String, String> _profileImages = {};
  String _selectedCategory = 'All'; // Initially show all categories
  final List<String> _categories = [
    'All',
    'Tech',
    'Lifestyle',
    'Education',
    'Travel',
    'Food',
    'God'
  ];

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      _isLoading = true;
    });

    final blogs = await _authMethods.getAllBlogs();
    setState(() {
      _blogList = blogs;
      _filterBlogs();
    });

    for (var blog in blogs) {
      await _getImage(blog['userId']);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterBlogs() {
    setState(() {
      if (_selectedCategory == 'All') {
        _filteredBlogList = _blogList;
      } else {
        _filteredBlogList = _blogList
            .where((blog) => blog['category'] == _selectedCategory)
            .toList();
      }
    });
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    final prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('name') ?? 'Anonymous';

    // Optimistically update local state
    setState(() {
      _filteredBlogList = _filteredBlogList.map((blog) {
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
      // Update Firestore based on the new like status
      if (isLiked) {
        // Remove like from Firestore
        await _firestore.collection('Blog').doc(blogId).update({
          'likes': FieldValue.arrayRemove([userName]),
        });
      } else {
        // Add like to Firestore
        await _firestore.collection('Blog').doc(blogId).update({
          'likes': FieldValue.arrayUnion([userName]),
        });
      }
    } catch (e) {
      // If there's an error, revert the optimistic update
      setState(() {
        _filteredBlogList = _filteredBlogList.map((blog) {
          if (blog['id'] == blogId) {
            final List<dynamic> likes = blog['likes'] ?? [];
            final List<dynamic> revertedLikes = isLiked
                ? [...likes, userName]
                : likes.where((name) => name != userName).toList();
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
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final commentData =
                              comments[index].data() as Map<String, dynamic>;
                          final userName =
                              commentData['userName'] ?? 'Anonymous';
                          final commentText = commentData['commentText'] ?? '';

                          final timestamp = commentData['timestamp'];
                          final DateTime? dateTime = timestamp != null
                              ? (timestamp as Timestamp).toDate()
                              : null;
                          final String formattedDate = dateTime != null
                              ? DateFormat.yMMMd().format(dateTime)
                              : '';

                          final String? authorId = commentData['userId'];
                          final String? authorImage = _profileImages[authorId];

                          return ListTile(
                            leading: ClipOval(
                              child: Container(
                                color: Colors.blueGrey,
                                child:
                                    _authMethods.buildProfileImage(authorImage),
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
                      onPressed: () async {
                        if (commentController.text.isNotEmpty) {
                          await _authMethods.addComment(
                            blogId,
                            commentController.text,
                          );
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
      appBar: AppBar(
        title: const Text(
          'Blogs',
          style: TextStyle(color: Colors.white),
        ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshBlogs,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories.map((category) {
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (bool selected) {
                                setState(() {
                                  _selectedCategory = category;
                                  _filterBlogs(); // Filter the blogs based on the selected category
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filteredBlogList.isEmpty
                        ? const Center(
                            child:
                                Text('No posts available for this category.'))
                        : ListView.builder(
                            itemCount: _filteredBlogList.length,
                            itemBuilder: (context, index) {
                              final blog = _filteredBlogList[index];
                              final Timestamp timestamp = blog['timestamp'];
                              final DateTime dateTime = timestamp.toDate();
                              final String formattedDate =
                                  DateFormat.yMMMd().add_jm().format(dateTime);

                              return FutureBuilder<SharedPreferences>(
                                future: SharedPreferences.getInstance(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }
                                  final prefs = snapshot.data!;
                                  final String userName =
                                      prefs.getString('name') ?? 'Anonymous';
                                  final List<dynamic> likes =
                                      blog['likes'] ?? [];
                                  final bool isLiked = likes.contains(userName);
                                  final int likeCount = likes.length;

                                  final String authorId = blog['userId'];
                                  final String? authorImage =
                                      _profileImages[authorId];

                                  return GestureDetector(
                                    onTap: () {},
                                    child: Card(
                                      color: Colors.grey[200],
                                      margin: const EdgeInsets.all(8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    ClipOval(
                                                      child: _authMethods
                                                          .buildProfileImage(
                                                              authorImage),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          blog['author'] ??
                                                              'Unknown',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.black87,
                                                          ),
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
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          BlogDetailScreen(
                                                              blog: blog,
                                                              image:
                                                                  authorImage),
                                                    ),
                                                  );
                                                },
                                                child: Text(
                                                  blog['content'] ??
                                                      'Blog Content',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        isLiked
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                        color: isLiked
                                                            ? Colors.red
                                                            : Colors.blueGrey,
                                                      ),
                                                      onPressed: () {
                                                        _toggleLike(blog['id'],
                                                            isLiked);
                                                      },
                                                    ),
                                                    Row(
                                                      children: [
                                                        IconButton(
                                                          icon: const Icon(
                                                            Icons
                                                                .mode_comment_outlined,
                                                            color:
                                                                Colors.blueGrey,
                                                          ),
                                                          onPressed: () {
                                                            _authMethods
                                                                .countComments(
                                                                    blog['id']);
                                                            _showCommentBottomSheet(
                                                                blog['id']);
                                                          },
                                                        ),
                                                        FutureBuilder<int>(
                                                          future: _authMethods
                                                              .countComments(
                                                                  blog['id']),
                                                          builder: (BuildContext
                                                                  context,
                                                              AsyncSnapshot<int>
                                                                  snapshot) {
                                                            if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error: ${snapshot.error}');
                                                            }

                                                            return Text(
                                                              "${snapshot.data}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14.0,
                                                                color: Colors
                                                                    .black87,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.send_outlined,
                                                        color: Colors.blueGrey,
                                                      ),
                                                      onPressed: () {
                                                        Share.share(
                                                            '${blog['title']}\nRead more at: ${blog['content']}');
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: FutureBuilder<bool>(
                                                    future: _authMethods
                                                        .isPostSaved(
                                                            blog['userId'],
                                                            blog['id']),
                                                    // Check if the post is saved
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot.hasData &&
                                                          snapshot.data ==
                                                              true) {
                                                        return const Icon(
                                                          Icons.bookmark,
                                                          color:
                                                              Colors.blueGrey,
                                                        ); // Filled bookmark if saved
                                                      } else {
                                                        return const Icon(
                                                          Icons
                                                              .bookmark_border_outlined,
                                                          color:
                                                              Colors.blueGrey,
                                                        ); // Outlined bookmark if not saved
                                                      }
                                                    },
                                                  ),
                                                  onPressed: () async {
                                                    final pref =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    final userId = pref
                                                        .getString('userId')
                                                        .toString();
                                                    await _authMethods.savePost(
                                                        userId, blog);
                                                    setState(
                                                        () {}); // Trigger a rebuild to refresh the bookmark icon
                                                  },
                                                ),
                                              ],
                                            ),
                                            Text(
                                              likeCount == 1
                                                  ? '$likeCount Like'
                                                  : '$likeCount Likes',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 14.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 5.0),
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black87,
                                              ),
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
                ],
              ),
            ),
    );
  }
}
