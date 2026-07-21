import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../../../Domain/Entities/live_class_entity.dart';
import '../../../Domain/Entities/user_entity.dart';
import 'dart:developer';

class LiveClassSessionPage extends StatefulWidget {
  final LiveClassEntity liveClass;
  final UserEntity user;

  const LiveClassSessionPage({
    super.key,
    required this.liveClass,
    required this.user,
  });

  @override
  State<LiveClassSessionPage> createState() => _LiveClassSessionPageState();
}

class _LiveClassSessionPageState extends State<LiveClassSessionPage> {
  final _jitsiMeet = JitsiMeet();

  @override
  void initState() {
    super.initState();
    _startMeeting();
  }

  void _startMeeting() {
    log('Jitsi: Initializing meeting for room ${widget.liveClass.id}');
    
    // Extract room name from documentation format meet.jit.si/room-name
    String roomName = widget.liveClass.roomUrl?.split('/').last ?? 'LMS_${widget.liveClass.id}';

    var options = JitsiMeetConferenceOptions(
      room: roomName,
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": false,
        "prejoinPageEnabled": false,
      },
      featureFlags: {
        "unsecureRecordingEnabled": false,
        "resolution": 360,
      },
      userInfo: JitsiMeetUserInfo(
        displayName: widget.user.fullName,
        email: widget.user.email,
        avatar: widget.user.profilePicture,
      ),
    );

    _jitsiMeet.join(options);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.liveClass.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_rounded, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Joining Session...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
