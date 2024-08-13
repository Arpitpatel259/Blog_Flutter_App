import 'dart:convert';
import 'package:blog/Services/Auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

@immutable
class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> blog;
  final String? image;

  const BlogDetailScreen({super.key, required this.blog, this.image});

  @override
  Widget build(BuildContext context) {
    final String formattedDate =
        DateFormat.yMMMd().add_jm().format(blog['timestamp'].toDate());
    final int likeCount = (blog['likes'] ?? []).length;
    AuthMethods authMethods = AuthMethods();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: ClipOval(
          child: authMethods.buildProfileImage(image),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('${blog['title']}\nRead more at: ${blog['content']}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(blog['title'] ?? '',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            Text("Published by: ${blog['author'] ?? ''}",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            Text(formattedDate),
            const SizedBox(height: 16),
            blog['imageBase64'] != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.memory(base64Decode(blog['imageBase64']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200.0),
                    ),
                  )
                : Container(
                    height: 200.0,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8.0,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: const Center(
                        child: Icon(Icons.image_outlined, size: 48)),
                  ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SelectableText(
                blog['content'] ?? '',
                style: const TextStyle(fontSize: 20.0, height: 2),
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(likeCount == 1 ? '$likeCount Like' : '$likeCount Likes'),
                const Text("0 Comments"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
