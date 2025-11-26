import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/antique_item_model.dart';
import '../../core/errors/exceptions.dart';

abstract class AntiqueRemoteDataSource {
  Future<List<AntiqueItemModel>> getItems({String? category});
  Future<AntiqueItemModel> getItemById(String id);
  Future<AntiqueItemModel> createItem(AntiqueItemModel item);
  Future<AntiqueItemModel> updateItem(AntiqueItemModel item);
  Future<void> deleteItem(String id);
  Future<List<AntiqueItemModel>> searchItems(String query);
}

class AntiqueRemoteDataSourceImpl implements AntiqueRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  AntiqueRemoteDataSourceImpl({
    required this.firestore,
    required this.auth,
  });

  String get _userId => auth.currentUser?.uid ?? '';

  CollectionReference get _collection => firestore.collection('antique_items');

  @override
  Future<List<AntiqueItemModel>> getItems({String? category}) async {
    try {
      Query query = _collection.where('userId', isEqualTo: _userId);
      
      if (category != null) {
        query = query.where('category', isEqualTo: category);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => AntiqueItemModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch items: ${e.toString()}');
    }
  }

  @override
  Future<AntiqueItemModel> getItemById(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      
      if (!doc.exists) {
        throw ServerException('Item not found');
      }
      
      return AntiqueItemModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      throw ServerException('Failed to fetch item: ${e.toString()}');
    }
  }

  @override
  Future<AntiqueItemModel> createItem(AntiqueItemModel item) async {
    try {
      await _collection.doc(item.id).set(item.toFirestore());
      return item;
    } catch (e) {
      throw ServerException('Failed to create item: ${e.toString()}');
    }
  }

  @override
  Future<AntiqueItemModel> updateItem(AntiqueItemModel item) async {
    try {
      await _collection.doc(item.id).update(item.toFirestore());
      return item;
    } catch (e) {
      throw ServerException('Failed to update item: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (e) {
      throw ServerException('Failed to delete item: ${e.toString()}');
    }
  }

  @override
  Future<List<AntiqueItemModel>> searchItems(String query) async {
    try {
      final snapshot = await _collection
          .where('userId', isEqualTo: _userId)
          .get();
      
      final allItems = snapshot.docs
          .map((doc) => AntiqueItemModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
      
      final lowerQuery = query.toLowerCase();
      return allItems.where((item) {
        return item.name.toLowerCase().contains(lowerQuery) ||
               item.description.toLowerCase().contains(lowerQuery) ||
               item.category.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to search items: ${e.toString()}');
    }
  }
}
