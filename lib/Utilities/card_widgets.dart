import 'package:blog/Model/bloglist_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Authentication/authentication.dart';
import '../Screens/blog_details_screen.dart';
import 'constant.dart';

class BlogList extends StatefulWidget {
  const BlogList({super.key});

  @override
  State<BlogList> createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  final AuthMethods _authMethods = AuthMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<BlogModel> _blogList = [];
  List<BlogModel> _filteredBlogList = [];
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
  bool isPostSaved = false;

  @override
  void initState() {
    super.initState();
    _getUserId();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _isLoading = true;
    });

    final blogs = await _authMethods.getAllBlogs();
    savedPostList =
        await _authMethods.getSavedPosts(pref.getString("userId") ?? "");

    blogs.map((e) => savedPostList.any((element) {
          if (element.id == e.id) {
            e.isSaved = true;
            return true;
          }
          return false;
        }));

    setState(() {
      _blogList = blogs;
      _filterBlogs();
    });

    print(_blogList.length);

    for (var blog in blogs) {
      await _getImage(blog.UserId ?? "");
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
            .where((blog) => blog.Category == _selectedCategory)
            .toList();
      }
    });
  }

  bool isLikedByCurrentUser(List<dynamic>? likes, String userId) {
    if (likes == null) {
      return false; // Return false if the likes list is null
    }
    return likes.any((like) => like['userId'] == userId);
  }

  Future<void> _toggleLike(String blogId, bool isLiked) async {
    final prefs = await SharedPreferences.getInstance();
    String userName = prefs.getString('name') ?? 'Anonymous';
    String userId = prefs.getString('userId') ?? 'anonymous_user';

    // Create a userLikeInfo object
    Map<String, String> userLikeInfo = {
      'userId': userId,
      'userName': userName,
    };

    // Find the blog in the local state
    final blogIndex = _filteredBlogList.indexWhere((blog) => blog.id == blogId);
    if (blogIndex == -1) return; // If the blog is not found, exit

    // Update local state optimistically
    List<dynamic> updatedLikes;
    if (isLiked) {
      updatedLikes = _filteredBlogList[blogIndex]
              .like
              ?.where((like) => like['userId'] != userId)
              .toList() ??
          [];
    } else {
      updatedLikes = [
        ...(_filteredBlogList[blogIndex].like ?? []),
        userLikeInfo
      ];
    }

    setState(() {
      _filteredBlogList[blogIndex].like = updatedLikes;
    });

    try {
      // Update Firestore
      final updateData = isLiked
          ? {
              'likes': FieldValue.arrayRemove([userLikeInfo])
            }
          : {
              'likes': FieldValue.arrayUnion([userLikeInfo])
            };

      await _firestore.collection('Blog').doc(blogId).update(updateData);
    } catch (e) {
      // Handle errors gracefully, maybe log or show a message
      print('Error updating Firestore: $e');
      // Optionally, revert the optimistic update if necessary
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

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId') ?? '';
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

                              final Timestamp timestamp = blog.timestamp!;
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
                                  final String userId =
                                      prefs.getString('userId') ?? 'Anonymous';

                                  final String authorId = blog.UserId!;
                                  final List<dynamic> likes = blog.like ??
                                      []; // Default to an empty list if null
                                  final bool isLiked =
                                      isLikedByCurrentUser(likes, userId);
                                  final int likeCount = likes.length;
                                  final String? authorImage =
                                      _profileImages[authorId];

                                  return GestureDetector(
                                    onTap: () {},
                                    child: Card(
                                      elevation: 4.0, // Add subtle shadow
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12.0), // Rounded corners
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 8.0, horizontal: 16.0),
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
                                                    const SizedBox(width: 12.0),
                                                    // Increased spacing
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          blog.AutherName ??
                                                              'Unknown',
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16.0,
                                                            // Improved font size
                                                            color:
                                                                Colors.black87,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4.0),
                                                        // Improved spacing
                                                        Text(
                                                          formattedDate,
                                                          // Moved date here for better alignment
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12.0,
                                                            color:
                                                                Colors.black54,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16.0),
                                            Text(
                                              blog.title ?? 'Blog Title',
                                              style: const TextStyle(
                                                fontSize:
                                                    20.0, // Larger title font size
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8.0),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BlogDetailScreen(
                                                      blog: blog,
                                                      image: authorImage,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10.0,
                                                        horizontal: 14.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  blog.content ??
                                                      'Blog Content',
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight
                                                        .w400, // Normal weight for content
                                                  ),
                                                  maxLines: 4,
                                                  overflow: TextOverflow
                                                      .ellipsis, // Ellipsis for long content
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16.0),
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
                                                            : Colors.grey,
                                                      ),
                                                      onPressed: () {
                                                        _toggleLike(
                                                            blog.id!, isLiked);
                                                      },
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .mode_comment_outlined,
                                                        color: Colors.blueGrey,
                                                      ),
                                                      onPressed: () {
                                                        _authMethods
                                                            .countComments(
                                                                blog.id!);
                                                        _showCommentBottomSheet(
                                                            blog.id!);
                                                      },
                                                    ),
                                                    FutureBuilder<int>(
                                                      future: _authMethods
                                                          .countComments(
                                                              blog.id!),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot.hasError) {
                                                          return const Text(
                                                              'Error');
                                                        }

                                                        return Text(
                                                          "${snapshot.data ?? 0}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.black87,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                IconButton(
                                                  icon: blog.isSaved
                                                      ? const Icon(
                                                          Icons.bookmark,
                                                          color:
                                                              Colors.blueGrey,
                                                        )
                                                      : const Icon(
                                                          Icons
                                                              .bookmark_border_outlined,
                                                          color:
                                                              Colors.blueGrey,
                                                        ),
                                                  onPressed: () async {
                                                    setState(() {
                                                      blog.isSaved =
                                                          !blog.isSaved;
                                                    });

                                                    final userId =
                                                        await _getUserId();

                                                    if (blog.isSaved) {
                                                      // Save post to Firestore if marked as saved
                                                      await _authMethods
                                                          .savePost(
                                                              userId, blog);
                                                    } else {
                                                      // Remove post from Firestore if unmarked
                                                      await _authMethods
                                                          .removeSave(userId,
                                                              blog.id ?? "");
                                                    }
                                                  },
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 8.0),
                                            // Increased spacing
                                            Text(
                                              likeCount == 1
                                                  ? '$likeCount Like'
                                                  : '$likeCount Likes',
                                              style: const TextStyle(
                                                fontSize: 14.0,
                                                color: Colors.black87,
                                                fontWeight: FontWeight.bold,
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
