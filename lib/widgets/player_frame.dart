import 'package:fiit_mtaa_fe/providers/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class PlayerFrame extends StatefulWidget {
  final int index;
  final RTCVideoRenderer videoRenderer;

  PlayerFrame({ Key? key, required int this.index, required RTCVideoRenderer this.videoRenderer }) : super(key: key);

  @override
  State<PlayerFrame> createState() => _PlayerFrameState(index, videoRenderer);
}

class _PlayerFrameState extends State<PlayerFrame> {
  final int index;
  RTCVideoRenderer videoRenderer;

  _PlayerFrameState(this.index, this.videoRenderer);

  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: game.killed.indexOf(game.usersInLobby[index]) >= 0 ? Colors.red[400] : Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: <Widget>[
          if (game.showCamera.indexOf(game.usersInLobby[index]) >= 0 && game.killed.indexOf(game.usersInLobby[index]) < 0)
            Positioned(
              top: 0.0,
              right: 0.0,
              left: 0.0,
              bottom: 0.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: RTCVideoView(
                  videoRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                )
              )
            )
          else if (game.showCamera.indexOf(game.usersInLobby[index]) < 0)
            Container(
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          Positioned(
            left: 10,
            right: 10,
            top: 5,
            child: Text(
              game.usersInLobby[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white
              ),
            )
          ),
          if (game.usersForVoting.indexOf(game.usersInLobby[index]) >= 0)
            Positioned(
              left: 10,
              right: 10,
              bottom: 5,
              child: ElevatedButton(
                onPressed: () {
                  game.vote(game.usersInLobby[index]);
                },
                child: Text('Vote'),
              )
            ),
        ],
      ),
    );
  }
}