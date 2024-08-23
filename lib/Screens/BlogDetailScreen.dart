// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:blog/Services/Auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class BlogDetailScreen extends StatefulWidget {
  final Map<String, dynamic> blog; // Required parameter
  final String? image; // Optional parameter

  // Constructor without `const`
  const BlogDetailScreen({Key? key, required this.blog, this.image})
      : super(key: key);

  @override
  State<BlogDetailScreen> createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  final AuthMethods authMethods = AuthMethods();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, String> _profileImages = {};

  void _showUsersList(BuildContext context, String title,
      Future<List<Map<String, String>>> usersFuture) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Map<String, String>>>(
          future: usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No users found.'));
            } else {
              return ListView(
                children: snapshot.data!.map((user) {
                  _getImage(user['userId']!);
                  final String? authorId = user['userId'];
                  final String? authorImage = _profileImages[authorId];

                  return ListTile(
                    leading: ClipOval(
                      child: Container(
                        color: Colors.blueGrey,
                        child: authMethods.buildProfileImage(authorImage),
                      ),
                    ),
                    title: Text(user['username'] ?? 'Unknown'),
                  );
                }).toList(),
              );
            }
          },
        );
      },
    );
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
  void initState() {
    super.initState();
    _getImage(widget.blog['userId']);
  }

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;
    final String? image = widget.image;
    final String formattedDate =
        DateFormat.yMMMd().add_jm().format(blog['timestamp'].toDate());
    final int likeCount = (blog['likes'] ?? []).length;
    AuthMethods authMethods = AuthMethods();
    _getImage(blog['userId']);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: ClipOval(
          child: authMethods.buildProfileImage(image),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              authMethods.shareMessage(blog['title'], blog['content'],
                  blog['author'], blog['timestamp']);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog['title'] ?? '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline6?.color,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Published by: ${blog['author'] ?? ''}",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.subtitle1?.color,
              ),
            ),
            Text(
              formattedDate,
              style: TextStyle(
                color: Theme.of(context).textTheme.subtitle1?.color,
              ),
            ),
            const SizedBox(height: 16),
            blog['imageBase64'] != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(
                        base64Decode(blog['imageBase64']),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200.0,
                      ),
                    ),
                  )
                : Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.shadow,
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.black54,
                      ),
                    ),
                  ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SelectableText(
                blog['content'] ?? '',
                style: TextStyle(
                  fontSize: 20.0,
                  height: 2,
                  color: Theme.of(context).textTheme.bodyText1?.color,
                ),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      onPressed: () {
                        _showUsersList(context, "Likes",
                            authMethods.getUsersWhoLiked(blog['id']));
                      },
                    ),
                    Text(
                      likeCount == 1 ? '$likeCount Like' : '$likeCount Likes',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyText2?.color,
                      ),
                    ),
                    const SizedBox(width: 30),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
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
                                            .doc(blog['id'])
                                            .collection('comments')
                                            .orderBy('timestamp',
                                                descending: true)
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }

                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return const Center(
                                                child:
                                                    Text('No comments yet.'));
                                          }

                                          final comments = snapshot.data!.docs;

                                          return ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: comments.length,
                                            itemBuilder: (context, index) {
                                              final commentData =
                                                  comments[index].data()
                                                      as Map<String, dynamic>;
                                              final userName =
                                                  commentData['userName'] ??
                                                      'Anonymous';
                                              final commentText =
                                                  commentData['commentText'] ??
                                                      '';

                                              final timestamp =
                                                  commentData['timestamp'];
                                              final DateTime? dateTime =
                                                  timestamp != null
                                                      ? (timestamp as Timestamp)
                                                          .toDate()
                                                      : null;
                                              final String formattedDate =
                                                  dateTime != null
                                                      ? DateFormat.yMMMd()
                                                          .format(dateTime)
                                                      : '';

                                              final String? authorId =
                                                  commentData['userId'];
                                              _getImage(authorId!);
                                              final String? authorImage =
                                                  _profileImages[authorId];

                                              return ListTile(
                                                leading: ClipOval(
                                                  child: Container(
                                                    color: Colors.blueGrey,
                                                    child: authMethods
                                                        .buildProfileImage(
                                                            authorImage),
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
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    FutureBuilder<int>(
                      future: authMethods.countComments(blog['id']),
                      builder:
                          (BuildContext context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        return Text(
                          "${snapshot.data} comments",
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyText2?.color,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
