import 'package:fiit_mtaa_fe/config.dart';
import 'package:fiit_mtaa_fe/pages/post_game_screen.dart';
import 'package:fiit_mtaa_fe/providers/account.dart';
import 'package:fiit_mtaa_fe/providers/game.dart';
import 'package:fiit_mtaa_fe/widgets/player_frame.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sdp_transform/sdp_transform.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({ Key? key }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameProvider? game;
  AccountProvider? account;
  final _localVideoRenderer = RTCVideoRenderer();
  final _remoteVideoRenderer = RTCVideoRenderer();
  final sdpController = TextEditingController();

  bool _offer = false;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  initRenderer() async {
    await _localVideoRenderer.initialize();
    await _remoteVideoRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localVideoRenderer.srcObject = stream;
    return stream;
  }

  _createPeerConnecion() async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    _localStream = await _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print('canditade');
        // print(json.encode({
        //   'candidate': e.candidate.toString(),
        //   'sdpMid': e.sdpMid.toString(),
        //   'sdpMlineIndex': e.sdpMLineIndex,
        // }));
      }
    };

    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteVideoRenderer.srcObject = stream;
    };

    return pc;
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    game?.usersInLobby.forEach((username) {
      if (account?.token['username'] != username) {
        game?.sendRtc(username, account?.token['username'], json.encode(session));
      }
    });
    _offer = true;

    _peerConnection!.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection!.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    // print(json.encode(session));
    game?.usersInLobby.forEach((username) {
      if (account?.token['username'] != username) {
        game?.sendRtc(username, account?.token['username'], json.encode(session));
      }
    });

    _peerConnection!.setLocalDescription(description);
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    // String jsonString = game?.rtcInvite;
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
        RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    // print(description.toMap());

    await _peerConnection!.setRemoteDescription(description);
    _createAnswer();
  }

  void _addCandidate() async {
    // String jsonString = game?.rtcInvite;
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode(jsonString);
    // print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection!.addCandidate(candidate);
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      game = Provider.of<GameProvider>(context, listen: false);
      account = Provider.of<AccountProvider>(context, listen: false);
      game?.addListener(_onDisconnect, ['disconnect']);
      game?.addListener(_onGameOver, ['game-over']);
      game?.addListener(_onSheriffCheck, ['game-sheriff-check']);
      game?.addListener(_onRtcRcv, ['rtc-rcv']);
      game?.addListener(_onGiveWord, ['give-word']);
      game?.addListener(_onNight, ['game-night']);
    game?.addListener(_onVoting, ['game-voting']);
    });

    initRenderer();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    _getUserMedia();
    setState(() {});
  }

  @override
  void didUpdateWidget(GameScreen gameScreen) {
    super.didUpdateWidget(gameScreen);

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.addListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onGameOver, ['game-over']);
    game?.addListener(_onGameOver, ['game-over']);
    game?.addListener(_onSheriffCheck, ['game-sheriff-check']);
    game?.removeListener(_onSheriffCheck, ['game-sheriff-check']);
    game?.addListener(_onRtcRcv, ['rtc-rcv']);
    game?.removeListener(_onRtcRcv, ['rtc-rcv']);
    game?.addListener(_onGiveWord, ['give-word']);
    game?.removeListener(_onGiveWord, ['give-word']);
    game?.addListener(_onNight, ['game-night']);
    game?.removeListener(_onNight, ['game-night']);
    game?.addListener(_onVoting, ['game-voting']);
    game?.removeListener(_onVoting, ['game-voting']);
  }

  @override
  void dispose() async {
    super.dispose();

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onGameOver, ['game-over']);
    game?.removeListener(_onSheriffCheck, ['game-sheriff-check']);
    game?.removeListener(_onRtcRcv, ['rtc-rcv']);
    game?.removeListener(_onGiveWord, ['give-word']);
    game?.removeListener(_onNight, ['game-night']);
    game?.removeListener(_onVoting, ['game-voting']);
    game?.leaveRoom();
    await _localVideoRenderer.dispose();
    sdpController.dispose();
  }

  _onVoting() {
    showSnackBar(context, 'You can vote now');
  }

  _onNight() {
    showSnackBar(context, 'Night started');
  }

  _onGiveWord() {
    String? giveWord = game?.giveWord;
    if (giveWord != null) {
      showSnackBar(context, '$giveWord can speak now');
    }
  }

  _onRtcRcv() {
    sdpController.text = game?.rtcInvite;
    // _offer ? 'answer' : 'offer'
    if (_offer) {
      _setRemoteDescription();
    } else {
      _addCandidate();
    }
  }

  _onDisconnect() {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  _onGameOver() {
    game?.removeListener(_onDisconnect, ['disconnect']);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const PostGameScreen()),
    );
  }

  _onSheriffCheck() {
    showSnackBar(context, 'Player that was checked is ${Config.roles[game!.sheriffCheck]}');
  }

  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);
    AccountProvider account = Provider.of<AccountProvider>(context);

    String role = game.role;

    if (['MAF', 'CIV', 'DOC', 'SRF', 'killed'].indexOf(role) < 0) {
      role = 'fallback';
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            for (int i = 0; i < game.usersInLobby.length; i++) (
              PlayerFrame(
                index: i,
                // videoRenderer: account.token['username'] == game.usersInLobby[i] ? _localVideoRenderer : _remoteVideoRenderer
                videoRenderer: account.token['username'] == game.usersInLobby[i] ? _localVideoRenderer : _remoteVideoRenderer
              )
            ),
            // Container(
            //   margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //   padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            //   decoration: BoxDecoration(
            //     color: Colors.black45,
            //     borderRadius: BorderRadius.circular(8.0),
            //   ),
            //   child: Text(
            //     // '${game.gameState}\n${game.role}\n${game.showCamera ? 'show cam.' : 'hide cam.'}',
            //     '${game.gameState}\n${game.role}',
            //     style: TextStyle(
            //       // fontSize: 20
            //     ),
            //   ),
            // ),
            // TextField(
            //   controller: sdpController,
            //   keyboardType: TextInputType.multiline,
            //   maxLines: 4,
            //   maxLength: TextField.noMaxLength,
            // ),
            // ElevatedButton(
            //   onPressed: _createOffer,
            //   child: const Text("Offer"),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // ElevatedButton(
            //   onPressed: _createAnswer,
            //   child: const Text("Answer"),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // ElevatedButton(
            //   onPressed: _setRemoteDescription,
            //   child: const Text("Set Remote Description"),
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // ElevatedButton(
            //   onPressed: _addCandidate,
            //   child: const Text("Set Candidate"),
            // ),
          ],
        )
      )
    );
  }
}