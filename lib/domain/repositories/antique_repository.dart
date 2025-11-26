import '../entities/antique_item.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

abstract class AntiqueRepository {
  Future<Either<Failure, List<AntiqueItem>>> getItems({String? category});
  Future<Either<Failure, AntiqueItem>> getItemById(String id);
  Future<Either<Failure, AntiqueItem>> createItem(AntiqueItem item);
  Future<Either<Failure, AntiqueItem>> updateItem(AntiqueItem item);
  Future<Either<Failure, void>> deleteItem(String id);
  Future<Either<Failure, List<AntiqueItem>>> searchItems(String query);
}