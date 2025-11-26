import '../../domain/entities/antique_item.dart';
import '../../domain/repositories/antique_repository.dart';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';
import '../../core/errors/exceptions.dart';
import '../../core/network/network_info.dart';
import '../datasources/antique_remote_datasource.dart';
import '../datasources/antique_local_datasource.dart';
import '../models/antique_item_model.dart';

class AntiqueRepositoryImpl implements AntiqueRepository {
  final AntiqueRemoteDataSource remoteDataSource;
  final AntiqueLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AntiqueRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<AntiqueItem>>> getItems({String? category}) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        try {
          final remoteItems = await remoteDataSource.getItems(category: category);
          await localDataSource.cacheItems(remoteItems);
          return Right(remoteItems.map((model) => model.toEntity()).toList());
        } on ServerException catch (e) {
          return Left(ServerFailure(e.message));
        }
      } else {
        try {
          final cachedItems = await localDataSource.getCachedItems();
          var items = cachedItems.map((model) => model.toEntity()).toList();
          
          if (category != null) {
            items = items.where((item) => item.category == category).toList();
          }
          
          return Right(items);
        } on CacheException catch (e) {
          return Left(CacheFailure(e.message));
        }
      }
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AntiqueItem>> getItemById(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        final remoteItem = await remoteDataSource.getItemById(id);
        return Right(remoteItem.toEntity());
      } else {
        final cachedItems = await localDataSource.getCachedItems();
        final item = cachedItems.firstWhere(
          (item) => item.id == id,
          orElse: () => throw CacheException('Item not found in cache'),
        );
        return Right(item.toEntity());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AntiqueItem>> createItem(AntiqueItem item) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = AntiqueItemModel.fromEntity(item);
      final createdItem = await remoteDataSource.createItem(model);
      
      return Right(createdItem.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AntiqueItem>> updateItem(AntiqueItem item) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final model = AntiqueItemModel.fromEntity(item);
      final updatedItem = await remoteDataSource.updateItem(model);
      
      return Right(updatedItem.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(String id) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (!isConnected) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.deleteItem(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<AntiqueItem>>> searchItems(String query) async {
    try {
      final isConnected = await networkInfo.isConnected;

      if (isConnected) {
        final remoteItems = await remoteDataSource.searchItems(query);
        return Right(remoteItems.map((model) => model.toEntity()).toList());
      } else {
        final cachedItems = await localDataSource.getCachedItems();
        final lowerQuery = query.toLowerCase();
        final filteredItems = cachedItems.where((item) {
          return item.name.toLowerCase().contains(lowerQuery) ||
                 item.description.toLowerCase().contains(lowerQuery) ||
                 item.category.toLowerCase().contains(lowerQuery);
        }).toList();
        return Right(filteredItems.map((model) => model.toEntity()).toList());
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}