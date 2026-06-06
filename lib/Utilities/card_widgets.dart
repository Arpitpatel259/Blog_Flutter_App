import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Model/bloglist_model.dart';
import 'package:blog/Screens/blog_details_screen.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  bool _isLoading = true;
  final Map<String, String> _profileImages = {};
  String _selectedCategory = 'All';
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
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final blogs = await _authMethods.getAllBlogs();
      if (mounted) {
        setState(() {
          _blogList = blogs;
          _filterBlogs();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterBlogs() {
    if (_selectedCategory == 'All') {
      _filteredBlogList = _blogList;
    } else {
      _filteredBlogList = _blogList
          .where((blog) => blog.category == _selectedCategory)
          .toList();
    }
  }

  Future<void> _getImage(String userId) async {
    if (userId.isEmpty || _profileImages.containsKey(userId)) return;

    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('User').doc(userId).get();
      if (userSnapshot.exists && mounted) {
        setState(() {
          _profileImages[userId] = userSnapshot['imgUrl'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildCategoryFilter(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3))
                  : RefreshIndicator(
                      onRefresh: _refreshBlogs,
                      color: kPrimaryColor,
                      backgroundColor: kSurfaceColor,
                      child: _filteredBlogList.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: _filteredBlogList.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final blog = _filteredBlogList[index];
                                if (blog.userId != null) _getImage(blog.userId!);
                                return _buildBlogCard(blog);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discover', style: kHeadingStyle),
              Text('Explore stories from around the world', style: kBodyStyle),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kSurfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: kInputBorder),
            ),
            child: const Icon(Icons.search_rounded, color: kTextPrimary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                  _filterBlogs();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor : kSurfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? kPrimaryColor : kInputBorder,
                    width: 1,
                  ),
                  boxShadow: isSelected ? kSoftShadow : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : kTextSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
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
                child: const Icon(Icons.auto_stories_outlined, size: 48, color: kTextLight),
              ),
              const SizedBox(height: 24),
              Text('No stories yet', style: kTitleStyle),
              const SizedBox(height: 8),
              Text('Be the first one to share a story in this category',
                style: kBodyStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlogCard(BlogModel blog) {
    final String authorId = blog.userId ?? '';
    final String? pImage = _profileImages[authorId];
    final int likeCount = blog.like.length;
    final formattedDate = blog.timestamp != null
        ? DateFormat('MMM dd, yyyy').format(blog.timestamp!.toDate())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(kCardRadius),
        border: Border.all(color: kInputBorder, width: 1),
        boxShadow: kSoftShadow,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(kCardRadius),
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
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: kInputFill,
                      child: ClipOval(child: _authMethods.buildProfileImage(pImage)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          blog.authorName ?? 'Anonymous',
                          style: kLabelStyle,
                        ),
                        Text(
                          formattedDate,
                          style: kBodyStyle.copyWith(fontSize: 12, color: kTextLight),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kInputFill,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      blog.category ?? 'General',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimaryColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                blog.title ?? 'Untitled',
                style: kTitleStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                blog.content ?? '',
                style: kSubtitleStyle.copyWith(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildAction(Icons.favorite_rounded, likeCount.toString(), Colors.redAccent),
                  const SizedBox(width: 24),
                  FutureBuilder<int>(
                    future: _authMethods.countComments(blog.id!),
                    builder: (context, snapshot) => _buildAction(
                      Icons.chat_bubble_rounded, 
                      (snapshot.data ?? 0).toString(),
                      Colors.blueAccent
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: kTextLight, size: 20),
                    onPressed: () {
                      // Logic can be added here or kept as is
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
