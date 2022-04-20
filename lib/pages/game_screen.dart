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
  MediaStream? _localStream;

  initRenderer() async {
    await _localVideoRenderer.initialize();
    for (var entry in game!.rtc.entries) {
      await entry.value['renderer'].initialize();
    }
    // await _remoteVideoRenderer.initialize();
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

  _createPeerConnecion(username, value) async {
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'url': 'stun:stun.l.google.com:19302'},
        // {'url': 'stun:stun1.l.google.com:19302'},
        // {'url': 'stun:stun2.l.google.com:19302'},
        // {'url': 'stun:stun3.l.google.com:19302'},
      ]
    };

    final Map<String, dynamic> offerSdpConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    if (_localStream == null)
      _localStream = await _getUserMedia();
      _toggleMute(false);

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);

    pc.addStream(_localStream!);

    pc.onIceCandidate = (e) {
      print('candidate for ${username} ${value['type']}');
      // if (e.candidate != null && value['type'] == 'listen') {
      if (e.candidate != null) {
        game?.sendRtc(
          username,
          account?.token['username'],
          'candidate',
          json.encode({
            'candidate': e.candidate.toString(),
            'sdpMid': e.sdpMid.toString(),
            'sdpMlineIndex': e.sdpMLineIndex,
          })
        );
      }
    };

    pc.onIceConnectionState = (e) {
      // print(e);
    };

    pc.onAddStream = (stream) {
      value['renderer'].srcObject = stream;
    };

    return pc;
  }

  void _createOffer(username, value) async {
    RTCSessionDescription description =
        await value['peerConnection']!.createOffer({'offerToReceiveVideo': 1});
    var session = parse(description.sdp.toString());
    game?.sendRtc(username, account?.token['username'], 'sdp', json.encode(session));

    value['peerConnection']!.setLocalDescription(description);
  }

  void _createAnswer(username, value) async {
    RTCSessionDescription description =
        await value['peerConnection']!.createAnswer({'offerToReceiveVideo': 1});

    var session = parse(description.sdp.toString());
    game?.sendRtc(username, account?.token['username'], 'sdp', json.encode(session));

    value['peerConnection']!.setLocalDescription(description);
  }

  _setRemoteDescription(username, value) async {
    print(value.toString());
    String jsonString = value['sdp'];
    dynamic session = await jsonDecode(jsonString);

    String sdp = write(session, null);

    RTCSessionDescription description =
        RTCSessionDescription(sdp, value['type'] == 'send' ? 'answer' : 'offer');

    await value['peerConnection']!.setRemoteDescription(description);
  }

  void _addCandidate(value) async {
    String jsonString = value['candidate'];
    dynamic session = await jsonDecode(jsonString);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await value['peerConnection']!.addCandidate(candidate);
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
      game?.addListener(_onGiveWord, ['give-word']);
      game?.addListener(_onNight, ['game-night']);
      game?.addListener(_onHideAll, ['hide-all']);
      game?.addListener(_onVoting, ['game-voting']);
      game?.addListener(_onSdpRcv, ['sdp-rcv']);
      game?.addListener(_onCandidateRcv, ['candidate-rcv']);
      game?.addListener(_onStartRtc, ['start-rtc']);

      await initRenderer();

      game?.rtc.forEach((username, value) {
        _createPeerConnecion(username, value).then((pc) {
          value['peerConnection'] = pc;
        });
      });
    });
  }

  @override
  void didUpdateWidget(GameScreen gameScreen) {
    super.didUpdateWidget(gameScreen);

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onGameOver, ['game-over']);
    game?.removeListener(_onSheriffCheck, ['game-sheriff-check']);
    game?.removeListener(_onGiveWord, ['give-word']);
    game?.removeListener(_onNight, ['game-night']);
    game?.removeListener(_onHideAll, ['hide-all']);
    game?.removeListener(_onVoting, ['game-voting']);
    game?.removeListener(_onSdpRcv, ['sdp-rcv']);
    game?.removeListener(_onCandidateRcv, ['candidate-rcv']);
    game?.removeListener(_onStartRtc, ['start-rtc']);

    game?.addListener(_onDisconnect, ['disconnect']);
    game?.addListener(_onGameOver, ['game-over']);
    game?.addListener(_onSheriffCheck, ['game-sheriff-check']);
    game?.addListener(_onGiveWord, ['give-word']);
    game?.addListener(_onNight, ['game-night']);
    game?.addListener(_onHideAll, ['hide-all']);
    game?.addListener(_onVoting, ['game-voting']);
    game?.addListener(_onSdpRcv, ['sdp-rcv']);
    game?.addListener(_onCandidateRcv, ['candidate-rcv']);
    game?.addListener(_onStartRtc, ['start-rtc']);
  }

  @override
  void dispose() async {
    super.dispose();

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onGameOver, ['game-over']);
    game?.removeListener(_onSheriffCheck, ['game-sheriff-check']);
    game?.removeListener(_onGiveWord, ['give-word']);
    game?.removeListener(_onNight, ['game-night']);
    game?.removeListener(_onHideAll, ['hide-all']);
    game?.removeListener(_onVoting, ['game-voting']);
    game?.removeListener(_onSdpRcv, ['sdp-rcv']);
    game?.removeListener(_onCandidateRcv, ['candidate-rcv']);
    game?.removeListener(_onStartRtc, ['start-rtc']);
    game?.leaveRoom();

    _localVideoRenderer.srcObject = null;
    _localStream?.getTracks().forEach((track) {
      track.stop();
    });
    _localStream?.dispose();
    await _localVideoRenderer.dispose();

    game?.rtc.forEach((username, value) {
      value['peerConnection'].dispose();
    });
    game?.rtc = {};
  }

  _onStartRtc() {
    game?.rtc.forEach((username, value) {
      if (value['type'] == 'send') {
        _createOffer(username, value);
      }
    });
  }

  _onSdpRcv() async {
    final username = game?.sdpQeue.removeAt(0);
    print('sdp rcv: ' + username);

    await _setRemoteDescription(username, game?.rtc[username]);
    if (game?.rtc[username]['type'] == 'listen') {
      _createAnswer(username, game?.rtc[username]);
    }
  }

  _onCandidateRcv() {
    final username = game?.candidateQeue.removeAt(0);
    print('candidate rcv: ' + username);

    // if (game?.rtc[username]['type'] == 'send')
      _addCandidate(game?.rtc[username]);
  }

  _onVoting() {
    showSnackBar(context, 'You can vote now');
  }

  _onNight() {
    showSnackBar(context, 'Night started');
    _toggleMute(false);
  }

  _onGiveWord() {
    String? giveWord = game?.giveWord;
    if (giveWord != null) {
      showSnackBar(context, '$giveWord can speak now');
    }
    if (giveWord == account?.token['username']) {
      _toggleMute(true);
    } else {
      _toggleMute(false);
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

  _onHideAll() {
    _toggleMute(false);
  }

  _toggleMute([bool? value]) {
    if (value != null)
      _localStream!.getAudioTracks()[0].enabled = value;
    else
      _localStream!.getAudioTracks()[0].enabled = !_localStream!.getAudioTracks()[0].enabled;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);
    AccountProvider account = Provider.of<AccountProvider>(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: GridView.count(
          crossAxisCount: 2,
          children: <Widget>[
            for (int i = 0; i < game.usersInLobby.length; i++) (
              PlayerFrame(
                index: i,
                videoRenderer: account.token['username'] == game.usersInLobby[i] ? _localVideoRenderer : game.rtc[game.usersInLobby[i]]['renderer']
              )
            )
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: game.giveWord == account.token['username'] ? Colors.black87 : Colors.grey,
        foregroundColor: Colors.white,
        onPressed: game.giveWord == account.token['username'] ? _toggleMute : null,
        child: Icon(
          _localStream?.getAudioTracks()[0].enabled != null && _localStream!.getAudioTracks()[0].enabled ? Icons.mic : Icons.mic_off
        ),
      )
    );
  }
}