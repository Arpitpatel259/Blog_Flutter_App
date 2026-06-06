import 'dart:convert';

import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Model/bloglist_model.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BlogDetailScreen extends StatefulWidget {
  final BlogModel blog;
  final String? image;

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
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kInputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(title, style: kTitleStyle),
              const SizedBox(height: 20),
              Expanded(
                child: FutureBuilder<List<Map<String, String>>>(
                  future: usersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.people_outline, size: 48, color: kTextLight),
                          const SizedBox(height: 16),
                          Text('No users yet', style: kSubtitleStyle),
                        ],
                      ));
                    } else {
                      for (var user in snapshot.data!) {
                        _getImage(user['userId']!);
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final user = snapshot.data![index];
                          final String? authorId = user['userId'];
                          final String? authorImage = _profileImages[authorId];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kInputFill,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: kSurfaceColor,
                                  child: AuthMethods().buildProfileImage(authorImage),
                                ),
                                const SizedBox(width: 16),
                                Text(user['username'] ?? 'Unknown', style: kLabelStyle.copyWith(fontSize: 16)),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(String userId) async {
    if (_profileImages.containsKey(userId)) return;

    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (userSnapshot.exists && mounted) {
        setState(() {
          _profileImages[userId] = userSnapshot['imgUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching image for user $userId: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.blog.userId != null) {
      _getImage(widget.blog.userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blog = widget.blog;
    final String? image = widget.image;
    final String formattedDate = blog.timestamp != null
        ? DateFormat('MMMM dd, yyyy • hh:mm a').format(blog.timestamp!.toDate())
        : 'Unknown Date';
    final int likeCount = blog.like.length;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: kPrimaryColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () {
                  authMethods.shareMessage(blog.title!, blog.content!,
                      blog.authorName!, blog.timestamp!);
                },
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: blog.imageBase64 != null
                  ? Image.memory(
                      base64Decode(blog.imageBase64!),
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      child: const Icon(Icons.image_outlined, size: 80, color: kPrimaryColor),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: kSurfaceColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        blog.category ?? 'General',
                        style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(blog.title ?? 'Untitled', style: kHeadingStyle.copyWith(fontSize: 24)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: kInputFill,
                          child: AuthMethods().buildProfileImage(image),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(blog.authorName ?? 'Anonymous', style: kLabelStyle),
                            Text(formattedDate, style: kBodyStyle.copyWith(fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: kInputBorder),
                    const SizedBox(height: 24),
                    Text(
                      blog.content ?? '',
                      style: kBodyStyle.copyWith(
                        fontSize: 16,
                        height: 1.8,
                        color: kTextPrimary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatButton(
                          icon: Icons.favorite_rounded,
                          label: 'Likes',
                          count: likeCount.toString(),
                          color: Colors.redAccent,
                          onTap: () => _showUsersList(context, "Likes", authMethods.getUsersWhoLiked(blog.id!)),
                        ),
                        _buildStatButton(
                          icon: Icons.chat_bubble_rounded,
                          label: 'Comments',
                          count: '...', // Will be loaded by future builder
                          color: Colors.blueAccent,
                          isComment: true,
                          blogId: blog.id!,
                          onTap: () => _showComments(context, blog.id!),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatButton({
    required IconData icon,
    required String label,
    required String count,
    required Color color,
    required VoidCallback onTap,
    bool isComment = false,
    String? blogId,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            if (isComment && blogId != null)
              FutureBuilder<int>(
                future: authMethods.countComments(blogId),
                builder: (context, snapshot) => Text(
                  (snapshot.data ?? 0).toString(),
                  style: kLabelStyle.copyWith(color: color, fontSize: 16),
                ),
              )
            else
              Text(
                count,
                style: kLabelStyle.copyWith(color: color, fontSize: 16),
              ),
            Text(label, style: kBodyStyle.copyWith(color: color.withValues(alpha: 0.7), fontSize: 12)),
          ],
        ),
      ),
    );
  }

  void _showComments(BuildContext context, String blogId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: kSurfaceColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: kInputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text('Comments', style: kTitleStyle),
              const SizedBox(height: 24),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('Blog')
                      .doc(blogId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 48, color: kTextLight),
                          const SizedBox(height: 16),
                          Text('Be the first to comment', style: kSubtitleStyle),
                        ],
                      ));
                    }
                    final comments = snapshot.data!.docs;
                    return ListView.builder(
                      controller: controller,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final commentData = comments[index].data() as Map<String, dynamic>;
                        final String userId = commentData['userId'] ?? '';
                        _getImage(userId);
                        final String? authorImage = _profileImages[userId];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: kInputFill,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: kSurfaceColor,
                                child: AuthMethods().buildProfileImage(authorImage),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(commentData['userName'] ?? 'Anonymous', style: kLabelStyle),
                                    const SizedBox(height: 4),
                                    Text(commentData['commentText'] ?? '', style: kBodyStyle.copyWith(color: kTextPrimary)),
                                  ],
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
