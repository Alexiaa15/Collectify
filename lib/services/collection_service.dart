import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/collection_item.dart';

class CollectionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _col => _db.collection('collection');

  // Stream all items for a user filtered by type
  Stream<List<CollectionItem>> streamItems(String userId, ItemType type) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type == ItemType.game ? 'game' : 'comic')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => CollectionItem.fromFirestore(doc)).toList());
  }

  // Stream filtered by status
  Stream<List<CollectionItem>> streamByStatus(
      String userId, ItemType type, String status) {
    return _col
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type == ItemType.game ? 'game' : 'comic')
        .where('status', isEqualTo: status)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => CollectionItem.fromFirestore(doc)).toList());
  }

  Future<void> addItem(CollectionItem item) async {
    final id = _uuid.v4();
    final newItem = CollectionItem(
      id: id,
      userId: item.userId,
      type: item.type,
      title: item.title,
      coverUrl: item.coverUrl,
      status: item.status,
      rating: item.rating,
      notes: item.notes,
      genre: item.genre,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await _col.doc(id).set(newItem.toFirestore());
  }

  Future<void> updateItem(CollectionItem item) async {
    await _col.doc(item.id).update({
      ...item.toFirestore(),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteItem(String itemId) async {
    await _col.doc(itemId).delete();
  }

  // Stats
  Future<Map<String, int>> getStatusCounts(
      String userId, ItemType type) async {
    final snap = await _col
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type == ItemType.game ? 'game' : 'comic')
        .get();

    final counts = <String, int>{};
    for (final doc in snap.docs) {
      final status = (doc.data() as Map<String, dynamic>)['status'] as String;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }
}
