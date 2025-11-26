import '../entities/antique_item.dart';
import '../repositories/antique_repository.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

class CreateItemUseCase {
  final AntiqueRepository repository;

  CreateItemUseCase(this.repository);

  Future<Either<Failure, AntiqueItem>> call(AntiqueItem item) {
    return repository.createItem(item);
  }
}