import 'package:blog/Authentication/user_login_screen.dart';
import 'package:blog/Model/bloglist_model.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import '../Model/savedlist_model.dart';
import 'blog_details_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthMethods _authMethods = AuthMethods();
  List<BlogModel> _blogList = [];



  final Map<String, String> _profileImages = {};
  bool isLoading = true;
  AuthMethods authMethods = AuthMethods();

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final storageStatus = await Permission.storage.request();

    if (cameraStatus.isDenied || storageStatus.isDenied) {
      if (cameraStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Camera permission is required for this app. Please enable it from app settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }

      if (storageStatus.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Storage permission is required for this app. Please enable it from app settings.'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    } else if (cameraStatus.isGranted && storageStatus.isGranted) {
      // Permissions are granted, continue with your functionality
      _refreshBlogs();
    }
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Blog',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey[800],
        // Darker blue-grey for the AppBar
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
                      _getImage(blog.UserId!);
                      final List<dynamic> likers = blog.like ?? [];
                      final int likeCount = likers.length;

                      final Timestamp timestamp = blog.timestamp!;
                      final DateTime dateTime = timestamp.toDate();
                      final String formattedDate =
                          DateFormat.yMMMd().add_jm().format(dateTime);

                      // Get author image
                      final String authorId = blog.UserId!;
                      final String? pImage = _profileImages[authorId];

                      return GestureDetector(
                        onTap: () {},
                        child: Card(
                          margin: const EdgeInsets.all(8.0),
                          color: Colors
                              .grey[200], // Light grey for card background
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
                                          child: authMethods
                                              .buildProfileImage(pImage),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              blog.AutherName ?? 'Unknown',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors
                                                    .black87, // Dark text color
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
                                  blog.title ?? 'Blog Title',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black, // Darker text color
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54, // Lighter text color
                                  ),
                                ),
                                const SizedBox(height: 5),
                                GestureDetector(
                                  onTap: () {
                                    _getImage(blog.UserId!);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BlogDetailScreen(
                                            blog: blog, image: pImage),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    blog.content ?? 'Blog Content',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black87, // Dark text color
                                    ),
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
                                                : Colors
                                                    .black54, // Color for inactive state
                                          ),
                                          onPressed: () {},
                                        ),
                                        Text(
                                          "$likeCount",
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .black87, // Dark text color
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                              Icons.mode_comment_outlined,
                                              color: Colors.black54),
                                          // Color for comment icon
                                          onPressed: () {
                                            print("Comment Clicked");
                                          },
                                        ),
                                        const Text(
                                          "0",
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .black87, // Dark text color
                                          ),
                                        ),
                                      ],
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.send_outlined,
                                          color: Colors.black54),
                                      // Color for send icon
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
              decoration: BoxDecoration(
                color: Colors.blueGrey[800], // Matching color with AppBar
                borderRadius: const BorderRadius.only(
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
                        foregroundColor: Colors.blueGrey[800],
                        // Button text color
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
