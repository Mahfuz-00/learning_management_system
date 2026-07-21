import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../Domain/Repositories/video_repository.dart';
import '../../../Core/Services/notification_service.dart';
import 'dart:developer';

abstract class VideoDownloadEvent extends Equatable {
  const VideoDownloadEvent();
  @override
  List<Object?> get props => [];
}

class StartVideoDownload extends VideoDownloadEvent {
  final String videoUrl;
  final String videoId;
  const StartVideoDownload({required this.videoUrl, required this.videoId});
  @override
  List<Object?> get props => [videoUrl, videoId];
}

class CheckDownloadStatus extends VideoDownloadEvent {
  final String videoId;
  const CheckDownloadStatus(this.videoId);
  @override
  List<Object?> get props => [videoId];
}

class DeleteDownloadedVideo extends VideoDownloadEvent {
  final String videoId;
  const DeleteDownloadedVideo(this.videoId);
  @override
  List<Object?> get props => [videoId];
}

class _DownloadProgressUpdated extends VideoDownloadEvent {
  final String videoId;
  final double progress;
  const _DownloadProgressUpdated(this.videoId, this.progress);
  @override
  List<Object?> get props => [videoId, progress];
}

abstract class VideoDownloadState extends Equatable {
  const VideoDownloadState();
  @override
  List<Object?> get props => [];
}

class VideoDownloadInitial extends VideoDownloadState {}

class VideoDownloading extends VideoDownloadState {
  final String videoId;
  final double progress;
  const VideoDownloading(this.videoId, this.progress);
  @override
  List<Object?> get props => [videoId, progress];
}

class VideoDownloadedState extends VideoDownloadState {
  final String videoId;
  final String path;
  const VideoDownloadedState(this.videoId, this.path);
  @override
  List<Object?> get props => [videoId, path];
}

class VideoNotDownloadedState extends VideoDownloadState {
  final String videoId;
  const VideoNotDownloadedState(this.videoId);
  @override
  List<Object?> get props => [videoId];
}

class VideoDownloadBloc extends Bloc<VideoDownloadEvent, VideoDownloadState> {
  final VideoRepository videoRepository;

  VideoDownloadBloc({required this.videoRepository}) : super(VideoDownloadInitial()) {
    on<StartVideoDownload>(_onStartDownload);
    on<CheckDownloadStatus>(_onCheckStatus);
    on<DeleteDownloadedVideo>(_onDeleteVideo);
    on<_DownloadProgressUpdated>((event, emit) {
      emit(VideoDownloading(event.videoId, event.progress));
    });
  }

  Future<void> _onStartDownload(StartVideoDownload event, Emitter<VideoDownloadState> emit) async {
    log('VideoDownloadBloc: Starting download for ${event.videoId}');
    final result = await videoRepository.downloadVideo(
      event.videoUrl,
      event.videoId,
      onProgress: (received, total) {
        if (total != -1) {
          add(_DownloadProgressUpdated(event.videoId, received / total));
        }
      },
    );

    result.fold(
      (failure) => emit(VideoNotDownloadedState(event.videoId)),
      (path) {
        log('VideoDownloadBloc: Download complete for ${event.videoId}');
        emit(VideoDownloadedState(event.videoId, path));
        NotificationService.showNotification(
          id: event.videoId.hashCode,
          title: 'Download Complete',
          body: 'Video is ready for offline viewing.',
        );
      },
    );
  }

  Future<void> _onCheckStatus(CheckDownloadStatus event, Emitter<VideoDownloadState> emit) async {
    final isDownloaded = await videoRepository.isVideoDownloaded(event.videoId);
    if (isDownloaded) {
      final path = await videoRepository.getLocalVideoPath(event.videoId);
      if (path != null) {
        emit(VideoDownloadedState(event.videoId, path));
      } else {
        emit(VideoNotDownloadedState(event.videoId));
      }
    } else {
      emit(VideoNotDownloadedState(event.videoId));
    }
  }

  Future<void> _onDeleteVideo(DeleteDownloadedVideo event, Emitter<VideoDownloadState> emit) async {
    await videoRepository.deleteVideo(event.videoId);
    emit(VideoNotDownloadedState(event.videoId));
  }
}
