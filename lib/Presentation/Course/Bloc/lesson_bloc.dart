import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../Domain/Repositories/video_repository.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc extends Bloc<LessonEvent, LessonState> {
  final VideoRepository videoRepository;

  LessonBloc({required this.videoRepository}) : super(LessonInitial()) {
    on<DownloadVideoRequested>(_onDownloadVideo);
    on<DeleteDownloadedVideoRequested>(_onDeleteVideo);
    on<CheckVideoDownloadStatus>(_onCheckStatus);
    on<InternalDownloadProgressUpdated>((event, emit) {
      emit(VideoDownloadInProgress(event.progress));
    });
  }

  Future<void> _onDownloadVideo(DownloadVideoRequested event, Emitter<LessonState> emit) async {
    emit(const VideoDownloadInProgress(0.0));
    final result = await videoRepository.downloadVideo(
      event.videoUrl,
      event.lessonId,
      onProgress: (received, total) {
        if (total != -1) {
          add(InternalDownloadProgressUpdated(received / total));
        }
      },
    );

    result.fold(
      (failure) => emit(LessonError(failure.message)),
      (path) => emit(VideoDownloaded(path)),
    );
  }

  Future<void> _onDeleteVideo(DeleteDownloadedVideoRequested event, Emitter<LessonState> emit) async {
    final result = await videoRepository.deleteVideo(event.lessonId);
    result.fold(
      (failure) => emit(LessonError(failure.message)),
      (_) => emit(VideoNotDownloaded()),
    );
  }

  Future<void> _onCheckStatus(CheckVideoDownloadStatus event, Emitter<LessonState> emit) async {
    final isDownloaded = await videoRepository.isVideoDownloaded(event.lessonId);
    if (isDownloaded) {
      final path = await videoRepository.getLocalVideoPath(event.lessonId);
      if (path != null) {
        emit(VideoDownloaded(path));
      } else {
        emit(VideoNotDownloaded());
      }
    } else {
      emit(VideoNotDownloaded());
    }
  }
}
