import 'package:fiit_mtaa_fe/config.dart';
import 'package:fiit_mtaa_fe/pages/game_screen.dart';
import 'package:fiit_mtaa_fe/pages/login.dart';
import 'package:fiit_mtaa_fe/pages/video_call.dart';
import 'package:fiit_mtaa_fe/providers/account.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiit_mtaa_fe/providers/game.dart';
import 'account.dart';
import 'lobby.dart';
import 'package:fiit_mtaa_fe/widgets/join_game.dart';
import 'package:fiit_mtaa_fe/widgets/new_game.dart';

class Games extends StatefulWidget {
  const Games({ Key? key }) : super(key: key);

  @override
  _GamesState createState() => _GamesState();
}

class _GamesState extends State<Games> {
  List games = [];
  GameProvider? game;

  void _onRefresh() async {
    final response = await game?.getGames();

    if (response == null) {
      return;
    }

    if (response['status']) {
      setState(() {
        games = response['games'];
      });
      print(games);
    } else {
      showSnackBar(context, response['message']);
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      game = Provider.of<GameProvider>(context, listen: false);
      _onRefresh();
    });
  }

  @override
  void didUpdateWidget(Games games) {
    super.didUpdateWidget(games);

     WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      game = Provider.of<GameProvider>(context, listen: false);
      _onRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    AccountProvider account = Provider.of<AccountProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games List'),
        leading: IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (Route<dynamic> route) => false
            );
            account.token = null;
          },
        ),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Account()),
              );
            },
            icon: const Icon(Icons.person)
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _onRefresh();
        },
        child: ListView.builder(
          itemCount: games.length,
          padding: const EdgeInsets.only(top: 10, right: 10, bottom: 75, left: 10 ),
          itemBuilder: (buildContext, i) {
            return Card(
              child: ListTile(
                title: Text('${games[i]['usersInRoom']}/${Config.maxPlayers} Players'),
                trailing: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Lobby(games[i]['id'])),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward_ios)
                )
              )
            );
          },
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton.extended(
              onPressed: () {
                showDialog(context: context, builder: (BuildContext context) {
                  return const JoinGameWidget();
                });
              },
              elevation: 0,
              // extendedPadding: const EdgeInsetsDirectional.only(start: 65, end: 65),
              backgroundColor: Colors.black87,
              label: const Text('Join'),
              heroTag: 'join-game'
            ),
            FloatingActionButton.extended(
              onPressed: () {
                showDialog(context: context, builder: (BuildContext context) {
                  return const NewGameWidget();
                });
              },
              elevation: 0,
              backgroundColor: Colors.black87,
              label: const Text('Create new Game'),
              heroTag: 'create-game'
            ),
          ],
        ),
      ),

    );
  }
}

// floatingActionButton: SizedBox(
//   width: double.infinity,
//   child: Padding(
//     padding: const EdgeInsets.symmetric(horizontal: 8),
//     child: Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () async {
//               final StorageItem? newItem = await showDialog<StorageItem>(
//                   context: context, builder: (_) => AddDataDialog());
//               if (newItem != null) {
//                 _storageService.writeSecureData(newItem).then((value) {
//                   setState(() {
//                     _loading = true;
//                   });
//                   initList();
//                 });
//               }
//             },
//             child: const Text("Add Data"),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(primary: Colors.red),
//             onPressed: () async {
//               _storageService
//                   .deleteAllSecureData()
//                   .then((value) => initList());
//             },
//             child: const Text("Delete All Data"),
//           ),
//         ),
//       ],
//     ),
//   ),
// ),
// floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,