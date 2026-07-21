import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';
import '../../Domain/Repositories/video_repository.dart';
import '../DataSources/video_local_data_source.dart';
import 'dart:developer';

class VideoRepositoryImpl implements VideoRepository {
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String>> downloadVideo(
    String videoUrl,
    String videoId,
    {Function(int, int)? onProgress}
  ) async {
    log('Repo: Starting secure video download for $videoId');
    try {
      final path = await localDataSource.downloadAndSecureVideo(
        videoUrl,
        videoId,
        onProgress ?? (received, total) {}
      );
      return Right(path);
    } catch (e) {
      log('Repo Error: Secure download failed: $e');
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteVideo(String videoId) async {
    log('Repo: Deleting video $videoId');
    try {
      await localDataSource.deleteVideo(videoId);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<bool> isVideoDownloaded(String videoId) async {
    return await localDataSource.isVideoCached(videoId);
  }

  @override
  Future<String?> getLocalVideoPath(String videoId) async {
    return await localDataSource.getCachedVideoPath(videoId);
  }
}
