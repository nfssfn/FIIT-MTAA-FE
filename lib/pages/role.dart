import 'package:fiit_mtaa_fe/config.dart';
import 'package:fiit_mtaa_fe/pages/game_screen.dart';
import 'package:fiit_mtaa_fe/providers/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Role extends StatefulWidget {
  const Role({ Key? key }) : super(key: key);

  @override
  _RoleState createState() => _RoleState();
}

class _RoleState extends State<Role> {
  GameProvider? game;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      game = Provider.of<GameProvider>(context, listen: false);
      game?.addListener(_onDisconnect, ['disconnect']);
      game?.addListener(_onGameStarted, ['game-started']);
    });
  }

  @override
  void didUpdateWidget(Role role) {
    super.didUpdateWidget(role);

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.addListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onGameStarted, ['game-started']);
    game?.addListener(_onGameStarted, ['game-started']);
  }

  @override
  void dispose() {
    super.dispose();

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onGameStarted, ['game-started']);
  }

  _onGameStarted() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GameScreen()),
    );
  }

  _onDisconnect() {
    print('_onDisconnect role');
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);

    String role = game.role;

    if (['MAF', 'CIV', 'DOC', 'SRF', 'killed'].indexOf(role) < 0) {
      role = 'fallback';
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 150, horizontal: 20),
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 150,
              height: 200,
              child: Image.asset('assets/images/${role}.png')
            ),
            const SizedBox(height: 50),
            Text(
              Config.roles[role]!,
              style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            Text(
              Config.rolesDescription[role]!,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: game.acceptRole,
        extendedPadding: const EdgeInsetsDirectional.only(start: 50, end: 50),
        backgroundColor: Colors.black87,
        label: const Text('ENTER GAME')
      ),
    );
  }
}