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
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
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
                Text(
                  likeCount == 1 ? '$likeCount Like' : '$likeCount Likes',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyText2?.color,
                  ),
                ),
                const Text(
                  "0 Comments",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
