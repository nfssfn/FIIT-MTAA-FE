// import 'dart:convert';

// import 'package:fiit_mtaa_fe/providers/account.dart';
// import 'package:fiit_mtaa_fe/providers/game.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:provider/provider.dart';
// import 'package:sdp_transform/sdp_transform.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({Key? key}) : super(key: key);

  @override
  State<VideoCall> createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        onPressed: () {

        },
        child: Icon(Icons.mic),
      )
    );
  }
}

// class _VideoCallState extends State<VideoCall> {
//   final _localVideoRenderer = RTCVideoRenderer();
//   final _remoteVideoRenderer = RTCVideoRenderer();
//   final sdpController = TextEditingController();
//   final candidateController = TextEditingController();

//   bool _offer = false;

//   RTCPeerConnection? _peerConnection;
//   MediaStream? _localStream;
//   GameProvider? game;
//   AccountProvider? account;

//   initRenderer() async {
//     await _localVideoRenderer.initialize();
//     await _remoteVideoRenderer.initialize();
//   }

//   _getUserMedia() async {
//     final Map<String, dynamic> mediaConstraints = {
//       'audio': true,
//       'video': {
//         'facingMode': 'user',
//       }
//     };

//     MediaStream stream =
//         await navigator.mediaDevices.getUserMedia(mediaConstraints);

//     _localVideoRenderer.srcObject = stream;
//     return stream;
//   }

//   _createPeerConnecion() async {
//     Map<String, dynamic> configuration = {
//       "iceServers": [
//         {"url": "stun:stun.l.google.com:19302"},
//       ]
//     };

//     final Map<String, dynamic> offerSdpConstraints = {
//       "mandatory": {
//         "OfferToReceiveAudio": true,
//         "OfferToReceiveVideo": true,
//       },
//       "optional": [],
//     };

//     _localStream = await _getUserMedia();

//     RTCPeerConnection pc =
//         await createPeerConnection(configuration, offerSdpConstraints);

//     pc.addStream(_localStream!);

//     pc.onIceCandidate = (e) {
//       if (e.candidate != null) {
//         game?.sendRtc(game!.rtcInviteFrom, account?.token['username'], 'candidate',
//         json.encode({
//           'candidate': e.candidate.toString(),
//           'sdpMid': e.sdpMid.toString(),
//           'sdpMlineIndex': e.sdpMLineIndex,
//         }));
//         // print(json.encode({
//         //   'candidate': e.candidate.toString(),
//         //   'sdpMid': e.sdpMid.toString(),
//         //   'sdpMlineIndex': e.sdpMLineIndex,
//         // }));
//       }
//     };

//     pc.onIceConnectionState = (e) {
//       // print(e);
//     };

//     pc.onAddStream = (stream) {
//       // print('addStream: ' + stream.id);
//       _remoteVideoRenderer.srcObject = stream;
//     };

//     return pc;
//   }

//   void _createOffer() async {
//     RTCSessionDescription description =
//         await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
//     var session = parse(description.sdp.toString());
//     game?.usersInLobby.forEach((username) {
//       if (account?.token['username'] != username) {
//         game?.sendRtc(username, account?.token['username'], 'sdp', json.encode(session));
//       }
//     });
//     _offer = true;

//     _peerConnection!.setLocalDescription(description);
//   }

//   void _createAnswer() async {
//     RTCSessionDescription description =
//         await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});

//     var session = parse(description.sdp.toString());
//     // print(json.encode(session));
//     game?.sendRtc(game!.rtcInviteFrom, account?.token['username'], 'sdp', json.encode(session));

//     _peerConnection!.setLocalDescription(description);
//   }

//   _setRemoteDescription() async {
//     String jsonString = sdpController.text;
//     dynamic session = await jsonDecode(jsonString);
//     print('set remote desc');

//     String sdp = write(session, null);

//     RTCSessionDescription description =
//         RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
//     // print(description.toMap());

//     await _peerConnection!.setRemoteDescription(description);
//   }

//   void _addCandidate() async {
//     String jsonString = candidateController.text;
//     dynamic session = await jsonDecode(jsonString);
//     print('add candidate: ' + session['candidate']);
//     dynamic candidate = RTCIceCandidate(
//         session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
//     await _peerConnection!.addCandidate(candidate);
//   }

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
//       game = Provider.of<GameProvider>(context, listen: false);
//       account = Provider.of<AccountProvider>(context, listen: false);
//       game?.addListener(_onDisconnect, ['disconnect']);
//       game?.addListener(_onRtcRcv, ['rtc-rcv']);
//       game?.addListener(_onSdpRcv, ['sdp-rcv']);
//       game?.addListener(_onCandidateRcv, ['candidate-rcv']);
//       initRenderer();
//       game?.rtc.forEach((key, value) {

//       });
//       _createPeerConnecion().then((pc) {
//         _peerConnection = pc;
//       });
//       // _getUserMedia();
//       game?.connectToRoom('bf1f0f13');
//     });
//   }

//   void didUpdateWidget(VideoCall videoCall) {
//     super.didUpdateWidget(videoCall);

//     game?.removeListener(_onDisconnect, ['disconnect']);
//     game?.addListener(_onDisconnect, ['disconnect']);
//     game?.removeListener(_onRtcRcv, ['rtc-rcv']);
//     game?.addListener(_onRtcRcv, ['rtc-rcv']);
//     game?.removeListener(_onSdpRcv, ['sdp-rcv']);
//     game?.addListener(_onSdpRcv, ['sdp-rcv']);
//     game?.removeListener(_onCandidateRcv, ['candidate-rcv']);
//     game?.addListener(_onCandidateRcv, ['candidate-rcv']);
//   }

//   @override
//   void dispose() async {
//     super.dispose();
//     await _localVideoRenderer.dispose();
//     await _remoteVideoRenderer.dispose();
//     game?.removeListener(_onDisconnect, ['disconnect']);
//     game?.removeListener(_onRtcRcv, ['rtc-rcv']);
//     game?.removeListener(_onSdpRcv, ['sdp-rcv']);
//     game?.removeListener(_onCandidateRcv, ['candidate-rcv']);
//     _localStream?.getTracks().forEach((track) {
//       track.stop();
//     });
//     _peerConnection?.dispose();
//   }

//   SizedBox videoRenderers() => SizedBox(
//         height: 210,
//         child: Row(children: [
//           Flexible(
//             child: Container(
//               key: const Key('local'),
//               margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//               decoration: const BoxDecoration(color: Colors.black),
//               child: RTCVideoView(_localVideoRenderer),
//             ),
//           ),
//           Flexible(
//             child: Container(
//               key: const Key('remote'),
//               margin: const EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//               decoration: const BoxDecoration(color: Colors.black),
//               child: RTCVideoView(_remoteVideoRenderer),
//             ),
//           ),
//         ]),
//       );

//   _onSdpRcv() async {
//     print('sdp rcv');
//     sdpController.text = game?.rtcInviteSdp;
//     await _setRemoteDescription();
//     if (!_offer) {
//       _createAnswer();
//     }
//   }

//   _onCandidateRcv() {
//     candidateController.text = game?.rtcInviteCandidate;
//     print('candidate rcv');
//     _addCandidate();
//   }

//   _onRtcRcv() {
//     if (game?.rtcType == 'sdp') {
//       sdpController.text = game?.rtcInviteSdp;
//     } else if (candidateController.text.isEmpty) {
//       candidateController.text = game?.rtcInviteCandidate;
//     }
//   }

//   _onDisconnect() {
//     Navigator.popUntil(context, ModalRoute.withName('/'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: BackButton(
//           onPressed: () {
//             game?.leaveRoom();
//           },
//         ),
//         title: Text('title'),
//       ),
//       body: Column(
//         children: [
//           videoRenderers(),
//           Row(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.5,
//                   child: TextField(
//                     controller: sdpController,
//                     keyboardType: TextInputType.multiline,
//                     maxLines: 4,
//                     maxLength: TextField.noMaxLength,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.5,
//                   child: TextField(
//                     controller: candidateController,
//                     keyboardType: TextInputType.multiline,
//                     maxLines: 4,
//                     maxLength: TextField.noMaxLength,
//                   ),
//                 ),
//               ),
//             ],
//           ),

//           ElevatedButton(
//             onPressed: _createOffer,
//             child: const Text("init"),
//           ),
//           // ElevatedButton(
//           //   onPressed: _createOffer,
//           //   child: const Text("Offer"),
//           // ),
//           // const SizedBox(
//           //   height: 10,
//           // ),
//           // ElevatedButton(
//           //   onPressed: _createAnswer,
//           //   child: const Text("Answer"),
//           // ),
//           // const SizedBox(
//           //   height: 10,
//           // ),
//           // ElevatedButton(
//           //   onPressed: _setRemoteDescription,
//           //   child: const Text("Set Remote Description"),
//           // ),
//           // const SizedBox(
//           //   height: 10,
//           // ),
//           // ElevatedButton(
//           //   onPressed: _addCandidate,
//           //   child: const Text("Set Candidate"),
//           // ),
//         ],
//       )
//     );
//   }
// }