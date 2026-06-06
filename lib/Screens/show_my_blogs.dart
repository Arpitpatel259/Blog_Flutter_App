// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:blog/Model/bloglist_model.dart';
import 'package:blog/Screens/edit_update_screen.dart';
import 'package:blog/Authentication/authentication.dart';
import 'package:blog/Utilities/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'blog_details_screen.dart';

class ShowMyBlogPost extends StatefulWidget {
  const ShowMyBlogPost({super.key});

  @override
  State<ShowMyBlogPost> createState() => _ShowMyBlogPostState();
}

class _ShowMyBlogPostState extends State<ShowMyBlogPost> {
  Future<List<BlogModel>>? _futureBlogs;

  final AuthMethods _authMethods = AuthMethods();
  late SharedPreferences pref;

  String? userId;
  String? profileImageUrl;
  String? name;
  String? email;

  @override
  void initState() {
    super.initState();
    _refreshBlogs();
  }

  Future<void> _refreshBlogs() async {
    pref = await SharedPreferences.getInstance();
    setState(() {
      _futureBlogs = _authMethods.getCurrentUserBlogs();
    });

    userId = pref.getString("userId") ?? "";
    name = pref.getString("name") ?? "";
    email = pref.getString("email") ?? "";
    profileImageUrl = pref.getString("imgUrl") ?? "";
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }

  Future<void> _uploadProfileImage(File? image) async {
    if (userId == null || userId!.isEmpty) return;
    if (image == null) return;

    try {
      String base64Image = await _convertImageToBase64(image);
      await FirebaseFirestore.instance.collection('User').doc(userId).update({
        'imgUrl': base64Image,
      });
      await pref.setString('imgUrl', base64Image);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile image updated'), 
            behavior: SnackBarBehavior.floating,
            backgroundColor: kSuccessColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() {
          profileImageUrl = base64Image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile image')),
        );
      }
    }
  }

  Future<String> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _showLogoutDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBlogs,
        color: kPrimaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  children: [
                    Text("My Stories", style: kTitleStyle),
                    const SizedBox(width: 8),
                    FutureBuilder<List<BlogModel>>(
                      future: _futureBlogs,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              snapshot.data!.length.toString(),
                              style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
              _buildBlogsList(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: kSoftShadow,
        border: Border.all(color: kInputBorder),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              File? imageFile = await _pickImage();
              if (imageFile != null) {
                await _uploadProfileImage(imageFile);
              }
            },
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2), width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: kInputFill,
                    child: ClipOval(child: _authMethods.buildProfileImage(profileImageUrl)),
                  ),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: kSurfaceColor, width: 2),
                    ),
                    child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(name ?? 'Anonymous', style: kTitleStyle.copyWith(fontSize: 22)),
          const SizedBox(height: 4),
          Text(email ?? 'No email set', style: kBodyStyle),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuickStat('Followers', '124'), // Dummy data for UI
              _buildStatDivider(),
              _buildQuickStat('Following', '89'),   // Dummy data for UI
              _buildStatDivider(),
              _buildQuickStat('Appreciations', '1.2k'), // Dummy data for UI
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: kInputBorder,
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: kLabelStyle.copyWith(fontSize: 18)),
        Text(label, style: kBodyStyle.copyWith(fontSize: 12)),
      ],
    );
  }

  Widget _buildBlogsList() {
    return FutureBuilder<List<BlogModel>>(
      future: _futureBlogs,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(40.0),
            child: CircularProgressIndicator(color: kPrimaryColor, strokeWidth: 3),
          ));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error fetching blogs', style: kSubtitleStyle));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              children: [
                const SizedBox(height: 60),
                const Icon(Icons.post_add_rounded, size: 64, color: kTextLight),
                const SizedBox(height: 16),
                Text('Your journey starts here!', style: kTitleStyle),
                const SizedBox(height: 8),
                Text('Create your first blog post and share it with the world.', style: kBodyStyle),
              ],
            ),
          );
        } else {
          final blogList = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            physics: const NeverScrollableScrollPhysics(),
            itemCount: blogList.length,
            itemBuilder: (context, index) => _buildBlogCard(blogList[index]),
          );
        }
      },
    );
  }

  Widget _buildBlogCard(BlogModel blog) {
    final String formattedDate = blog.timestamp != null 
        ? DateFormat('MMM dd, yyyy').format(blog.timestamp!.toDate()) 
        : '';
    final int likeCount = blog.like.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kInputBorder),
        boxShadow: kSoftShadow,
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BlogDetailScreen(blog: blog, image: profileImageUrl)),
        ),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kInputFill,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      blog.category ?? 'General',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: kPrimaryColor),
                    ),
                  ),
                  const Spacer(),
                  Text(formattedDate, style: kBodyStyle.copyWith(fontSize: 11)),
                  const SizedBox(width: 8),
                  _buildMenuButton(blog),
                ],
              ),
              const SizedBox(height: 12),
              Text(blog.title ?? 'Untitled', style: kTitleStyle.copyWith(fontSize: 18)),
              const SizedBox(height: 8),
              Text(
                blog.content ?? '',
                style: kBodyStyle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMiniStat(Icons.favorite_rounded, likeCount.toString(), Colors.redAccent),
                  const SizedBox(width: 20),
                  FutureBuilder<int>(
                    future: _authMethods.countComments(blog.id!),
                    builder: (context, snap) => _buildMiniStat(Icons.chat_bubble_rounded, (snap.data ?? 0).toString(), Colors.blueAccent),
                  ),
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
        Icon(icon, size: 16, color: color.withValues(alpha: 0.7)),
        const SizedBox(width: 6),
        Text(value, style: kLabelStyle.copyWith(fontSize: 13, color: kTextSecondary)),
      ],
    );
  }

  Widget _buildMenuButton(BlogModel blog) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostEditor(isEdit: true, blog: blog)),
          ).then((_) => _refreshBlogs());
        } else if (value == 'delete') {
          _showDeleteDialog(blog.id!);
        }
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: const Icon(Icons.more_vert_rounded, color: kTextLight, size: 20),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 18, color: kAccentColor),
              SizedBox(width: 12),
              Text('Edit Post'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 18, color: kErrorColor),
              SizedBox(width: 12),
              Text('Delete', style: TextStyle(color: kErrorColor)),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await pref.clear();
              if (mounted) {
                _authMethods.logout(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kErrorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(String blogId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Blog', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone. Are you sure you want to delete this blog post?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await _authMethods.deleteBlogByUser(context, blogId);
              if (mounted) {
                Navigator.pop(context);
                _refreshBlogs();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kErrorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
