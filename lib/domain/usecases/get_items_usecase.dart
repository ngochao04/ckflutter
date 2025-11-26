import '../entities/antique_item.dart';
import '../repositories/antique_repository.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

class GetItemsUseCase {
  final AntiqueRepository repository;

  GetItemsUseCase(this.repository);

  Future<Either<Failure, List<AntiqueItem>>> call({String? category}) {
    return repository.getItems(category: category);
  }
}