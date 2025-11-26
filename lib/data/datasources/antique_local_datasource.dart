import 'package:hive/hive.dart';
import '../models/antique_item_model.dart';
import '../../core/errors/exceptions.dart';

abstract class AntiqueLocalDataSource {
  Future<List<AntiqueItemModel>> getCachedItems();
  Future<void> cacheItems(List<AntiqueItemModel> items);
  Future<void> clearCache();
}

class AntiqueLocalDataSourceImpl implements AntiqueLocalDataSource {
  final Box<AntiqueItemModel> box;

  AntiqueLocalDataSourceImpl(this.box);

  @override
  Future<List<AntiqueItemModel>> getCachedItems() async {
    try {
      return box.values.toList();
    } catch (e) {
      throw CacheException('Failed to get cached items: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheItems(List<AntiqueItemModel> items) async {
    try {
      await box.clear();
      for (var item in items) {
        await box.put(item.id, item);
      }
    } catch (e) {
      throw CacheException('Failed to cache items: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await box.clear();
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }
}