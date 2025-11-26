import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/repositories/storage_repository.dart';

class StorageRepositoryImpl implements StorageRepository {
  final SupabaseClient supabase;
  static const String bucketName = 'antique-images';

  StorageRepositoryImpl(this.supabase);

  @override
  Future<Either<Failure, String>> uploadImage(File file, String path) async {
    try {
      final bytes = await file.readAsBytes();
      final fileExt = file.path.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$path/$fileName';

      await supabase.storage.from(bucketName).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: false,
            ),
          );

      final publicUrl = supabase.storage.from(bucketName).getPublicUrl(filePath);

      return Right(publicUrl);
    } on StorageException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadMultipleImages(
    List<File> files,
    String path,
  ) async {
    try {
      final List<String> uploadedUrls = [];

      for (final file in files) {
        final result = await uploadImage(file, path);
        result.fold(
          (failure) => throw Exception(failure.message),
          (url) => uploadedUrls.add(url),
        );
      }

      return Right(uploadedUrls);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    try {
      // Extract file path from public URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf(bucketName);
      
      if (bucketIndex == -1 || bucketIndex == pathSegments.length - 1) {
        return Left(ValidationFailure('Invalid image URL'));
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await supabase.storage.from(bucketName).remove([filePath]);

      return const Right(null);
    } on StorageException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMultipleImages(List<String> imageUrls) async {
    try {
      for (final url in imageUrls) {
        final result = await deleteImage(url);
        result.fold(
          (failure) => throw Exception(failure.message),
          (_) => null,
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}