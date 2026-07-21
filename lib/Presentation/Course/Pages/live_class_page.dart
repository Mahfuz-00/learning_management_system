import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../../../Domain/Entities/live_class_entity.dart';
import '../../../Domain/Entities/user_entity.dart';
import 'dart:developer';

class LiveClassPage extends StatefulWidget {
  final LiveClassEntity liveClass;
  final UserEntity user;

  const LiveClassPage({
    super.key,
    required this.liveClass,
    required this.user,
  });

  @override
  State<LiveClassPage> createState() => _LiveClassPageState();
}

class _LiveClassPageState extends State<LiveClassPage> {
  final _jitsiMeet = JitsiMeet();

  @override
  void initState() {
    super.initState();
    _joinMeeting();
  }

  void _joinMeeting() {
    log('Jitsi: Joining meeting ${widget.liveClass.roomUrl}');
    
    // Extract room name from URL if necessary, or use as is
    String roomName = widget.liveClass.roomUrl?.split('/').last ?? widget.liveClass.id;

    var options = JitsiMeetConferenceOptions(
      room: roomName,
      configOverrides: {
        "startWithAudioMuted": true,
        "startWithVideoMuted": true,
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
      appBar: AppBar(
        title: Text(widget.liveClass.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to live class...'),
          ],
        ),
      ),
    );
  }
}
