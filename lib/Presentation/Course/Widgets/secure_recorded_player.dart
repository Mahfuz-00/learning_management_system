import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Bloc/course_bloc.dart';
import '../Bloc/course_event.dart';
import '../Bloc/video_download_bloc.dart';
import '../../../Core/Theme/app_colors.dart';
import '../../../Core/Services/notification_service.dart';
import 'dart:developer';

class SecureRecordedPlayer extends StatefulWidget {
  final String videoSource;
  final String lessonId;
  final bool isLocal;

  const SecureRecordedPlayer({
    super.key,
    required this.videoSource,
    required this.lessonId,
    required this.isLocal,
  });

  @override
  State<SecureRecordedPlayer> createState() => _SecureRecordedPlayerState();
}

class _SecureRecordedPlayerState extends State<SecureRecordedPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    log('SecurePlayer: Initializing source: ${widget.videoSource} (Local: ${widget.isLocal})');
    
    if (widget.isLocal) {
      _videoPlayerController = VideoPlayerController.file(File(widget.videoSource));
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoSource));
    }

    try {
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primaryBlue,
          handleColor: AppColors.secondaryGreen,
          bufferedColor: AppColors.primaryBlue.withAlpha((0.3 * 255).toInt()),
          backgroundColor: Colors.grey,
        ),
        placeholder: Container(color: Colors.black),
        autoInitialize: true,
      );
      
      // Heartbeat for progress tracking (Save every 15s)
      _progressTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
        _savePlaybackProgress();
      });

      setState(() {});
    } catch (e) {
      log('SecurePlayer Error: $e');
    }
  }

  void _savePlaybackProgress() {
    if (_videoPlayerController.value.isInitialized) {
      final currentPos = _videoPlayerController.value.position.inSeconds.toDouble();
      final totalDuration = _videoPlayerController.value.duration.inSeconds.toDouble();
      if (totalDuration > 0) {
        final percentage = (currentPos / totalDuration) * 100;
        context.read<CourseBloc>().add(SaveVideoProgressRequested(
          lessonId: widget.lessonId,
          progressData: {
            'progress': percentage,
            'lastPosition': currentPos,
            'totalDuration': totalDuration,
          },
        ));
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _savePlaybackProgress(); // Final save
    
    // Security Guardrail: Delete local cache index upon streaming termination
    if (widget.isLocal) {
      _cleanupSecureCache();
    }
    
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void _cleanupSecureCache() {
    log('Security Guardrail: Wiping secure cache for ${widget.lessonId}');
    context.read<VideoDownloadBloc>().add(DeleteDownloadedVideo(widget.lessonId));
    
    NotificationService.showNotification(
      id: widget.lessonId.hashCode,
      title: 'Security Cleanup',
      body: 'Offline video cache has been wiped for your security.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator(color: AppColors.secondaryGreen)),
            ),
    );
  }
}
