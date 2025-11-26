import 'dart:io';
import '../../core/utils/either.dart';
import '../../core/errors/failures.dart';

abstract class StorageRepository {
  Future<Either<Failure, String>> uploadImage(File image, String path);
  Future<Either<Failure, List<String>>> uploadMultipleImages(
    List<File> images,
    String basePath,
  );
  Future<Either<Failure, void>> deleteImage(String url);
}