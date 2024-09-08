import 'package:cloud_firestore/cloud_firestore.dart';

class BlogModel {
  String? AutherName;
  String? Category;
  String? content;
  String? id;
  String? imageBase64;
  Timestamp? timestamp;
  String? title;
  String? UserId;
  List<dynamic> like = [];
  bool isSaved = false;


  BlogModel(
    this.AutherName,
    this.Category,
    this.content,
    this.id,
    this.imageBase64,
    this.timestamp,
    this.title,
    this.UserId,
    this.like,
    this.isSaved,
  );
}
