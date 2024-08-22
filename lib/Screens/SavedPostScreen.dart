import 'package:blog/Services/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'BlogDetailScreen.dart';

class SavedPostsScreen extends StatefulWidget {
  final String userId;

  const SavedPostsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _SavedPostsScreenState createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  List<Map<String, dynamic>> _savedPosts = [];
  final Map<String, String> _profileImages = {};
  AuthMethods authMethods = AuthMethods();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    final savedPosts = await authMethods.getSavedPosts(widget.userId, context);

    setState(() {
      _savedPosts = savedPosts;
      _isLoading = false;
    });
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
                    _getImage(post['userId']);

                    final String authorId = post['userId'];
                    final String? pImage = _profileImages[authorId];

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: SizedBox(
                              width: 50,
                              height: 50,
                              child: ClipOval(
                                child: authMethods.buildProfileImage(pImage),
                              ),
                            ),
                            title: Text(
                              post['title'] ?? 'No Title',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              post['content'] ?? 'No Content',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.bookmark,
                                color: Colors.blueGrey,
                              ),
                              onPressed: () async {
                                // Add or remove the post from saved posts
                                await authMethods.savePost(widget.userId, post);
                                // Refresh the saved posts list
                                await _loadSavedPosts();
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlogDetailScreen(
                                    blog: post,
                                    image: pImage,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
