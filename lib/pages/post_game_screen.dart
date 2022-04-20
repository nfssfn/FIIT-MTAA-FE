import 'package:fiit_mtaa_fe/config.dart';
import 'package:fiit_mtaa_fe/pages/games.dart';
import 'package:fiit_mtaa_fe/providers/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PostGameScreen extends StatefulWidget {
  const PostGameScreen({ Key? key }) : super(key: key);

  @override
  _PostGameScreenState createState() => _PostGameScreenState();
}

class _PostGameScreenState extends State<PostGameScreen> {
  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);

    String winTeam = game.winTeam;

    if (['MAF', 'CIV'].indexOf(winTeam) < 0) {
      winTeam = 'fallback';
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Column(
              children: <Widget>[
                SizedBox(
                  width: 150,
                  height: 200,
                  child: Image.asset('assets/images/$winTeam.png')
                ),
                const SizedBox(height: 100),
                Text(
                  '${Config.roles[winTeam]!.toUpperCase()}\n team won!',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40)
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Games()),
                );
              },
              child: const Text('GO HOME'),
            ),
            )
          ],
        ),
      )
    );
  }
}