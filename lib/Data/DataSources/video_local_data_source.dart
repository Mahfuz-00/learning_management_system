import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer';

abstract class VideoLocalDataSource {
  Future<String> downloadAndSecureVideo(String url, String videoId, Function(int, int) onProgress);
  Future<void> deleteVideo(String videoId);
  Future<bool> isVideoCached(String videoId);
  Future<String?> getCachedVideoPath(String videoId);
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  final Dio dio;

  VideoLocalDataSourceImpl({required this.dio});

  @override
  Future<String> downloadAndSecureVideo(String url, String videoId, Function(int, int) onProgress) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videosDir = Directory('${directory.path}/secure_assets');
      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
      }

      // Use a custom extension to prevent standard players from recognizing it
      final filePath = '${videosDir.path}/$videoId.lmsdat';
      
      await dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
      );

      log('Video downloaded and secured at: $filePath');
      return filePath;
    } catch (e) {
      log('Download Error: $e');
      throw Exception('Failed to download video');
    }
  }

  @override
  Future<void> deleteVideo(String videoId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/secure_assets/$videoId.lmsdat');
    if (await file.exists()) {
      await file.delete();
      log('Secured video deleted: $videoId');
    }
  }

  @override
  Future<bool> isVideoCached(String videoId) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/secure_assets/$videoId.lmsdat');
    return await file.exists();
  }

  @override
  Future<String?> getCachedVideoPath(String videoId) async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/secure_assets/$videoId.lmsdat';
    final file = File(filePath);
    if (await file.exists()) {
      return filePath;
    }
    return null;
  }
}
