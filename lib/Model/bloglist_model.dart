import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  String? authorName;
  String? category;
  String? content;
  String? id;
  String? imageBase64;
  Timestamp? timestamp;
  String? title;
  String? userId;
  List<dynamic> like = [];
  bool isSaved = false;

  BlogModel(
    this.authorName,
    this.category,
    this.content,
    this.id,
    this.imageBase64,
    this.timestamp,
    this.title,
    this.userId,
    this.like,
    this.isSaved,
  );
}
