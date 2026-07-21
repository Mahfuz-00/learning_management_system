import 'package:dartz/dartz.dart';
import '../../Core/Error/failures.dart';

abstract class VideoRepository {
  Future<Either<Failure, String>> downloadVideo(
    String videoUrl, 
    String videoId, 
    {Function(int, int)? onProgress}
  );
  Future<Either<Failure, Unit>> deleteVideo(String videoId);
  Future<bool> isVideoDownloaded(String videoId);
  Future<String?> getLocalVideoPath(String videoId);
}
