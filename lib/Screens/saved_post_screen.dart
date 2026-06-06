import 'package:blog/Model/savedlist_model.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedPostsScreen extends StatefulWidget {
  final String userId;

  const SavedPostsScreen({super.key, required this.userId});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  List<SavedBlogModel> _savedPosts = [];
  final Map<String, String> _profileImages = {};
  final AuthMethods _authMethods = AuthMethods();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPosts();
  }

  Future<void> _loadSavedPosts() async {
    try {
      final savedPosts = await _authMethods.getSavedPosts(widget.userId);
      await _fetchProfileImages(savedPosts);

      if (mounted) {
        setState(() {
          _savedPosts = savedPosts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading saved posts: $e');
    }
  }

  Future<void> _fetchProfileImages(List<SavedBlogModel> posts) async {
    final userIds = posts.map((post) => post.userId).whereType<String>().toSet();
    for (String userId in userIds) {
      if (_profileImages.containsKey(userId)) continue;

      try {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('User')
            .doc(userId)
            .get();
        if (userSnapshot.exists) {
          _profileImages[userId] = userSnapshot['imgUrl'] ?? '';
        }
      } catch (e) {
        debugPrint('Error fetching profile image for $userId: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Saved Stories'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3))
          : _savedPosts.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadSavedPosts,
                  color: kPrimaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _savedPosts.length,
                    itemBuilder: (context, index) => _buildSavedCard(_savedPosts[index]),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: kInputBorder),
            ),
            child: const Icon(Icons.bookmark_outline_rounded, size: 48, color: kTextLight),
          ),
          const SizedBox(height: 24),
          Text('Your library is empty', style: kTitleStyle),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Stories you save will appear here for quick access.',
              style: kBodyStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCard(SavedBlogModel post) {
    final String authorId = post.userId ?? '';
    final String? pImage = _profileImages[authorId];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kInputBorder),
        boxShadow: kSoftShadow,
      ),
      child: InkWell(
        onTap: () {
          // You might want to navigate to detail screen here if a blog model can be fetched
        },
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kInputFill,
                    child: ClipOval(child: _authMethods.buildProfileImage(pImage)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      post.authorName ?? 'Anonymous',
                      style: kLabelStyle,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark_rounded, color: kPrimaryColor, size: 22),
                    onPressed: () async {
                      await _authMethods.removeSave(widget.userId, post.id ?? "");
                      _loadSavedPosts();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: kPrimaryColor.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.titleText ?? 'Untitled',
                style: kTitleStyle.copyWith(fontSize: 18),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.auto_stories_outlined, size: 14, color: kTextLight),
                  const SizedBox(width: 6),
                  Text(
                    'Read story',
                    style: kBodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimaryColor),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: kTextLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
