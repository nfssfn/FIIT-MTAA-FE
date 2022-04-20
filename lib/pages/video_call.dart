import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCall extends StatefulWidget {

  const VideoCall({ Key? key }) : super(key: key);

  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final _localVideoRenderer = RTCVideoRenderer();

  void initRenderers() async {
    await _localVideoRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user'
      }
    };

    MediaStream stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localVideoRenderer.srcObject = stream;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initRenderers();
    _getUserMedia();
    setState(() {});
  }

  @override
  void dispose() async {
    super.dispose();
    _localVideoRenderer.srcObject = null;
    await _localVideoRenderer.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video call'),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 0.0,
            right: 0.0,
            left: 0.0,
            bottom: 0.0,
            child: RTCVideoView(_localVideoRenderer))
        ],
      ),
    );
  }
}