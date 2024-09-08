import 'package:blog/Model/bloglist_model.dart';
import 'package:blog/Model/savedlist_model.dart';
import 'package:blog/Screens/blog_details_screen.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedPostsScreen extends StatefulWidget {
  final String userId;

  const SavedPostsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SavedPostsScreenState createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  List<SavedBlogModel> _savedPosts = [];
  List<BlogModel> blogModel = [];
  final Map<String, String> _profileImages = {};
  AuthMethods authMethods = AuthMethods();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    try {
      final savedPosts = await authMethods.getSavedPosts(widget.userId);

      // Fetch all profile images
      await _fetchProfileImages(savedPosts);

      setState(() {
        _savedPosts = savedPosts;
        _isLoading = false;
      });
    } catch (e) {
      // Handle errors
      setState(() {
        _isLoading = false;
      });
      print('Error loading saved posts: $e');
    }
  }

  Future<void> _fetchProfileImages(List<SavedBlogModel> posts) async {
    final userIds =
        posts.map((post) => post.userId).whereType<String>().toSet();
    for (String userId in userIds) {
      if (_profileImages.containsKey(userId)) {
        continue; // Skip already fetched images
      }

      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();
        if (userSnapshot.exists) {
          _profileImages[userId] = userSnapshot['imgUrl'] ?? '';
        }
      } catch (e) {
        print('Error fetching profile image for $userId: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white30,
      appBar: AppBar(
        title: const Text(
          'Saved Posts',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedPosts.isEmpty
              ? const Center(child: Text('No saved posts yet.'))
              : ListView.builder(
                  itemCount: _savedPosts.length,
                  itemBuilder: (context, index) {
                    final post = _savedPosts[index];
                    final String authorId = post.userId ?? '';
                    final String? pImage = _profileImages[authorId];

                    return Card(
                      color: Colors.grey[200],
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: ClipOval(
                                    child: pImage != null && pImage.isNotEmpty
                                        ? Image.network(pImage,
                                            fit: BoxFit.cover)
                                        : const Icon(Icons.person,
                                            size: 50, color: Colors.grey),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    post.titleText ?? 'No Title',
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                post.authorName ?? 'No Author',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.bookmark,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () async {
                                  try {
                                    await authMethods.removeSave(
                                        widget.userId, post.id ?? "");
                                    await _loadSavedPosts();
                                  } catch (e) {
                                    print('Error updating saved posts: $e');
                                  }
                                },
                              ),
                              onTap: () {
                                /*Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BlogDetailScreen(
                                      blog: post,
                                      image: pImage,
                                    ),
                                  ),
                                );*/
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
