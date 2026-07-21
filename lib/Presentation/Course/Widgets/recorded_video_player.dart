import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../Core/Theme/app_colors.dart';
import 'dart:developer';

class RecordedVideoPlayer extends StatefulWidget {
  final String videoSource; // URL or Local Path
  final bool isLocal;

  const RecordedVideoPlayer({
    super.key,
    required this.videoSource,
    this.isLocal = false,
  });

  @override
  State<RecordedVideoPlayer> createState() => _RecordedVideoPlayerState();
}

class _RecordedVideoPlayerState extends State<RecordedVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    log('VideoPlayer: Initializing source: ${widget.videoSource} (Local: ${widget.isLocal})');

    if (widget.isLocal) {
      _videoPlayerController = VideoPlayerController.file(File(widget.videoSource));
    } else {
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoSource));
    }

    try {
      await _videoPlayerController.initialize();
      _createChewieController();
      setState(() {});
    } catch (e) {
      log('VideoPlayer Error: $e');
    }
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primaryBlue,
        handleColor: AppColors.secondaryGreen,
        backgroundColor: Colors.grey,
        bufferedColor: AppColors.primaryBlue.withOpacity(0.3),
      ),
      placeholder: Container(color: Colors.black),
      autoInitialize: true,
    );
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
    );
  }
}
