import 'package:cloud_firestore/cloud_firestore.dart';

enum ItemType { game, comic }

class CollectionItem {
  final String id;
  final String userId;
  final ItemType type;
  final String title;
  final String coverUrl;
  final String status;
  final double rating; // 0.0 - 5.0
  final String notes;
  final String? genre;
  final DateTime createdAt;
  final DateTime updatedAt;

  CollectionItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.coverUrl = '',
    required this.status,
    this.rating = 0.0,
    this.notes = '',
    this.genre,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CollectionItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CollectionItem(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] == 'game' ? ItemType.game : ItemType.comic,
      title: data['title'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      status: data['status'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      notes: data['notes'] ?? '',
      genre: data['genre'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type == ItemType.game ? 'game' : 'comic',
      'title': title,
      'coverUrl': coverUrl,
      'status': status,
      'rating': rating,
      'notes': notes,
      'genre': genre,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  CollectionItem copyWith({
    String? title,
    String? coverUrl,
    String? status,
    double? rating,
    String? notes,
    String? genre,
  }) {
    return CollectionItem(
      id: id,
      userId: userId,
      type: type,
      title: title ?? this.title,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      notes: notes ?? this.notes,
      genre: genre ?? this.genre,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
