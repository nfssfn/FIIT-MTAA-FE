import 'package:fiit_mtaa_fe/config.dart';
import 'package:fiit_mtaa_fe/pages/game_screen.dart';
import 'package:fiit_mtaa_fe/providers/account.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fiit_mtaa_fe/providers/game.dart';
import 'role.dart';
import 'package:flutter/services.dart';

class Lobby extends StatefulWidget {
  final String id;
  bool isPrivate = false;

  Lobby(String this.id, { Key? key, bool this.isPrivate = false }) : super(key: key);

  @override
  _LobbyState createState() => _LobbyState(id, isPrivate);
}

class _LobbyState extends State<Lobby> {
  final String id;
  final bool isPrivate;
  GameProvider? game;

  _LobbyState(this.id, this.isPrivate);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      game = Provider.of<GameProvider>(context, listen: false);
      game?.connectToRoom(id);
      game?.addListener(_onDisconnect, ['disconnect']);
      game?.addListener(_onRoleSet, ['role-set']);
    });
  }

  @override
  void didUpdateWidget(Lobby lobby) {
    super.didUpdateWidget(lobby);

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.addListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onRoleSet, ['role-set']);
    game?.addListener(_onRoleSet, ['role-set']);
  }

  @override
  void dispose() {
    super.dispose();

    game?.removeListener(_onDisconnect, ['disconnect']);
    game?.removeListener(_onRoleSet, ['role-set']);
  }

  void _copyId() {
    Clipboard.setData(ClipboardData(text: id)).then((_){
      showSnackBar(context, 'ID copied to clipboard');
    });
  }

  void _onDisconnect() {
    print('_onDisconnect lobby');
    Navigator.of(context).pop();
  }

  void _onRoleSet() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Role()),
    );
  }

  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);
    AccountProvider account = Provider.of<AccountProvider>(context);
    bool enoughPlayers = game.usersInLobby.length == Config.maxPlayers;

    _onLeaveGame() async {
      await game.deleteGame(id);
      game.leaveRoom();
    }

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: _onLeaveGame,
        ),
        automaticallyImplyLeading: game.gameState == 'preparing',
        title: const Text('Lobby')
      ),
      body: Column(
        children: <Widget>[
          const SizedBox(height: 20),
          if (game.isPrivate)
            GestureDetector(
              child: Text(id),
              onTap: _copyId,
            ),
          if (game.isPrivate)
            const SizedBox(height: 20),
          Text(
            '${game.usersInLobby.length}/${Config.maxPlayers}',
            style: const TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Ready',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              itemBuilder: (buildContext, i) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage('${Config.avatar}?username=${game.usersInLobby[i]}'),
                      backgroundColor: Colors.white30,
                    ),
                    title: Text(game.usersInLobby[i]),
                    trailing: account.token['username'] != game.usersInLobby[i] && game.isAdmin ? IconButton(
                      onPressed: () {
                        game.kickUser(game.usersInLobby[i]);
                      },
                      icon: const Icon(Icons.person_remove)
                    ) : null
                  )
                );
              },
              itemCount: game.usersInLobby.length,
              padding: const EdgeInsets.only(top: 10, right: 10, bottom: 75, left: 10 ),
            ),
          )

        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: game.isAdmin ? FloatingActionButton.extended(
      // floatingActionButton: FloatingActionButton.extended(
        // onPressed: !enoughPlayers ? null : () {
        onPressed: () {
          game.startGame();
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => const GameScreen()),
          // );
        },
        extendedPadding: const EdgeInsetsDirectional.only(start: 46, end: 50),
        backgroundColor: !enoughPlayers ? Colors.grey : Colors.black87,
        label: const Text('START'),
        icon: const Icon(Icons.play_arrow_rounded),
      ) : null
      // )
    );
  }
}