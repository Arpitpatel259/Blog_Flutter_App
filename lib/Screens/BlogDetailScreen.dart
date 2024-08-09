import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

@immutable
class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> blog;
  String? image;

  BlogDetailScreen({super.key, required this.blog, this.image});

  @override
  Widget build(BuildContext context) {
    // Build your blog detail screen here

    final Timestamp timestamp = blog['timestamp'];
    final DateTime dateTime = timestamp.toDate();
    final String formattedDate = DateFormat.yMMMd().add_jm().format(dateTime);

    final List<dynamic> likers = blog['likers'] ?? [];
    final int likeCount = likers.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Row(
          children: [
            ClipOval(
              child: image != null
                  ? Image.network(
                      image!,
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
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final String blogUrl = blog['content'] ?? '';
              final String blogTitle = blog['title'] ?? '';

              final String shareText = '$blogTitle\nRead more at: $blogUrl';

              Share.share(shareText);
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Text(
              "Published by: ${blog['author'] ?? ''}",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            Text(
              formattedDate,
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
                style: const TextStyle(
                  fontSize: 20.0, // Increase the font size
                  height: 2, // Adjust the line height for better readability
                  // Align text properly
                ),
                textAlign: TextAlign.justify,
              ),
            ),

            const SizedBox(height: 16),
            blog['imageBase64'] != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8.0,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined, size: 48),
                    ),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                    "${likeCount == 1 ? '$likeCount Like' : '$likeCount Likes'} "),
                const Text("0 Comments"),
              ],
            )
          ],
        ),
      ),
    );
  }
}
