import '../entities/antique_item.dart';
import '../repositories/antique_repository.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

class SearchItemsUseCase {
  final AntiqueRepository repository;

  SearchItemsUseCase(this.repository);

  Future<Either<Failure, List<AntiqueItem>>> call(String query) {
    return repository.searchItems(query);
  }
}