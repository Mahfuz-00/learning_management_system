import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../Domain/Entities/lesson_entity.dart';
import '../../../Core/Constants/constants.dart';
import 'dart:developer';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final bool isYoutube;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
    required this.isYoutube,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;

  @override
  void initState() {
    super.initState();
    if (widget.isYoutube) {
      log('VideoPlayer: Initializing Youtube player for ${widget.videoUrl}');
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(autoPlay: true, mute: false),
        );
      }
    } else {
      log('VideoPlayer: Initializing Local/Network video player for ${widget.videoUrl}');
      final fullUrl = widget.videoUrl.startsWith('http')
          ? widget.videoUrl
          : '${AppConstants.videosUrl}${widget.videoUrl}';

      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(fullUrl));
      _videoPlayerController!.initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController!,
            autoPlay: true,
            looping: false,
            aspectRatio: _videoPlayerController!.value.aspectRatio,
          );
        });
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isYoutube && _youtubeController != null) {
      return YoutubePlayer(
        controller: _youtubeController!,
        showVideoProgressIndicator: true,
      );
    } else if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _chewieController!.videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return Container(
        height: 200,
        color: Colors.black,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
  }
}

class LessonContentWidget extends StatelessWidget {
  final LessonEntity lesson;

  const LessonContentWidget({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (lesson.content != null)
            Text(
              lesson.content!,
              style: const TextStyle(fontSize: 16, height: 1.5),
            )
          else
            const Text('No additional content for this lesson.'),
        ],
      ),
    );
  }
}
