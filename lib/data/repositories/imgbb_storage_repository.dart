// lib/data/repositories/imgbb_storage_repository.dart
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/failures.dart';
import '../../core/utils/either.dart';
import '../../domain/repositories/storage_repository.dart';

class ImgBBStorageRepository implements StorageRepository {
  // API key miễn phí - 5000 uploads/tháng
  static const String apiKey = '22e92f6a8ccb639cd63afdaaf04a1134';

  @override
  Future<Either<Failure, String>> uploadImage(File file, String path) async {
    try {
      print('📤 Uploading image to ImgBB...');
      
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse('https://api.imgbb.com/1/upload'),
        body: {
          'key': apiKey,
          'image': base64Image,
          'name': path.replaceAll('/', '_'), // Đặt tên file
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final imageUrl = jsonData['data']['url'] as String;
        print('✅ Upload success: $imageUrl');
        return Right(imageUrl);
      } else {
        final errorData = json.decode(response.body);
        print('❌ Upload failed: $errorData');
        return Left(ServerFailure('Upload failed: ${errorData['error']['message']}'));
      }
    } catch (e) {
      print('❌ Exception: $e');
      return Left(ServerFailure('Upload error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadMultipleImages(
    List<File> files,
    String path,
  ) async {
    try {
      final List<String> uploadedUrls = [];

      for (int i = 0; i < files.length; i++) {
        print('📤 Uploading image ${i + 1}/${files.length}');
        
        final result = await uploadImage(files[i], '$path/image_$i');
        
        result.fold(
          (failure) => throw Exception(failure.message),
          (url) => uploadedUrls.add(url),
        );
      }

      print('✅ All images uploaded: ${uploadedUrls.length} files');
      return Right(uploadedUrls);
    } catch (e) {
      print('❌ Multiple upload error: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(String imageUrl) async {
    // ImgBB free plan không hỗ trợ delete qua API
    // Ảnh sẽ tự động xóa sau 1 năm không truy cập
    print('⚠️ ImgBB does not support delete via API');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteMultipleImages(List<String> imageUrls) async {
    // ImgBB free plan không hỗ trợ delete qua API
    return const Right(null);
  }
}