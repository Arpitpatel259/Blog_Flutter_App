import 'dart:convert';

import 'package:flutter/material.dart';

class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> blog;

  const BlogDetailScreen({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    // Build your blog detail screen here
    return Scaffold(
      appBar: AppBar(
        title: Text(blog['title'] ?? 'Blog Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blog['title'] ?? '',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            blog['imageBase64'] != null
                ? Image.memory(
                    base64Decode(blog['imageBase64']),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200.0,
                  )
                : Container(
                    height: 200.0,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image_outlined, size: 48),
                    ),
                  ),
            const SizedBox(height: 16),
            Text(
              blog['content'] ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
