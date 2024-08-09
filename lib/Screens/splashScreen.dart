import 'package:blog/Authentication/UserLoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../Services/Database.dart';
import 'BlogDetailScreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final DatabaseMethod _authMethods = DatabaseMethod();
  List<Map<String, dynamic>> _blogList = [];
  String pImage = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    setState(() {
      isLoading = true;
    });

    final blogs = await _authMethods.getAllBlogs();
    setState(() {
      _blogList = blogs;
      isLoading = false;
    });
  }

  Future<void> _getImage(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();

    if (userSnapshot.exists) {
      setState(() {
        pImage = userSnapshot['imgUrl'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Blog',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: Stack(
        children: [
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : RefreshIndicator(
                  onRefresh: _refreshBlogs,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 150.0),
                    itemCount: _blogList.length,
                    itemBuilder: (context, index) {
                      final blog = _blogList[index];
                      _getImage(blog['userId']);
                      final List<dynamic> likers = blog['likers'] ?? [];
                      final int likeCount = likers.length;

                      final Timestamp timestamp = blog['timestamp'];
                      final DateTime dateTime = timestamp.toDate();
                      final String formattedDate =
                          DateFormat.yMMMd().add_jm().format(dateTime);

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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        ClipOval(
                                          child: pImage.isNotEmpty
                                              ? Image.network(
                                                  pImage,
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,
                                                )
                                              : const Icon(
                                                  Icons.account_circle,
                                                  size: 50,
                                                  color: Colors.white,
                                                ),
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
                                Text(
                                  formattedDate,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () {
                                    _getImage(blog['userId']);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlogDetailScreen(
                                            blog: blog, image: pImage),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    blog['content'] ?? 'Blog Title',
                                    style: const TextStyle(fontSize: 15),
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            likeCount > 0
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: likeCount > 0
                                                ? Colors.red
                                                : null,
                                          ),
                                          onPressed: () {},
                                        ),
                                        Text(
                                          "$likeCount",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.mode_comment_outlined),
                                          onPressed: () {
                                            print("Comment Clicked");
                                          },
                                        ),
                                        const Text(
                                          "0",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send_outlined),
                                      onPressed: () {
                                        print("Share Clicked");
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sign in to unlock the full blogging experience and start writing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserLoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Sign In'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
