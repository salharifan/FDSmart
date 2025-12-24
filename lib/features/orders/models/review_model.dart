import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String orderId;
  final String rating;
  final String text;
  final String? imageUrl;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.orderId,
    required this.rating,
    required this.text,
    this.imageUrl,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> data, String id) {
    return ReviewModel(
      id: id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      orderId: data['orderId'] ?? '',
      rating: data['rating'] ?? '5',
      text: data['text'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'orderId': orderId,
      'rating': rating,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
