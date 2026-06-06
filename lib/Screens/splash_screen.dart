import 'package:blog/Authentication/user_login_screen.dart';
import 'package:blog/Model/bloglist_model.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _refreshBlogs();
    _requestPermissionsSilently();
  }

  Future<void> _requestPermissionsSilently() async {
    try {
      await [
        Permission.camera,
        Permission.storage,
      ].request();
    } catch (e) {
      debugPrint('Permission request failed: $e');
    }
  }

  Future<void> _refreshBlogs() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final blogs = await _authMethods.getAllBlogs();
      if (mounted) {
        setState(() {
          _blogList = blogs;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching blogs: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _getImage(String userId) async {
    if (userId.isEmpty || _profileImages.containsKey(userId)) return;

    try {
      DocumentSnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (userSnapshot.exists && mounted) {
        setState(() {
          _profileImages[userId] = userSnapshot['imgUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching image for $userId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                backgroundColor: kBackgroundColor,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'BLOGSCAPE',
                    style: kHeadingStyle.copyWith(
                      fontSize: 20,
                      letterSpacing: 4,
                      color: kPrimaryColor,
                    ),
                  ),
                ),
              ),
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3)),
                )
              else if (_blogList.isEmpty)
                SliverFillRemaining(
                  child: _buildEmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 260),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final blog = _blogList[index];
                        if (blog.userId != null) {
                          _getImage(blog.userId!);
                        }
                        return _buildBlogCard(blog);
                      },
                      childCount: _blogList.length,
                    ),
                  ),
                ),
            ],
          ),
          _buildBottomOverlay(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories_outlined, size: 64, color: kTextLight),
          const SizedBox(height: 16),
          Text('No stories yet', style: kTitleStyle),
        ],
      ),
    );
  }

  Widget _buildBlogCard(BlogModel blog) {
    final String authorId = blog.userId ?? '';
    final String? pImage = _profileImages[authorId];
    final int likeCount = blog.like.length;
    final formattedDate = blog.timestamp != null
        ? DateFormat('MMM dd, yyyy').format(blog.timestamp!.toDate())
        : 'Recently';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kInputBorder),
        boxShadow: kSoftShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailScreen(blog: blog, image: pImage),
            ),
          );
        },
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
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(blog.authorName ?? 'Anonymous', style: kLabelStyle.copyWith(fontSize: 13)),
                      Text(formattedDate, style: kBodyStyle.copyWith(fontSize: 11)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(blog.title ?? 'Untitled', style: kTitleStyle.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                blog.content ?? '',
                style: kBodyStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMiniStat(Icons.favorite_rounded, "$likeCount", Colors.redAccent),
                  const SizedBox(width: 16),
                  _buildMiniStat(Icons.chat_bubble_rounded, "0", Colors.blueAccent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Text(value, style: kBodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBottomOverlay() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              kBackgroundColor.withValues(alpha: 0),
              kBackgroundColor.withValues(alpha: 0.8),
              kBackgroundColor,
            ],
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: kTextPrimary,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: kTextPrimary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Join the Community',
                style: kTitleStyle.copyWith(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(height: 12),
              Text(
                'Share your thoughts and engage with writers around the world.',
                textAlign: TextAlign.center,
                style: kBodyStyle.copyWith(color: Colors.white.withValues(alpha: 0.7), fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const UserLoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Get Started', style: kButtonStyle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
