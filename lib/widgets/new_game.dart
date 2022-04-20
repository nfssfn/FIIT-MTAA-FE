import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiit_mtaa_fe/providers/game.dart';
import 'package:fiit_mtaa_fe/pages/lobby.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';

class NewGameWidget extends StatefulWidget {
  const NewGameWidget({Key? key}) : super(key: key);

  @override
  State<NewGameWidget> createState() => _NewGameWidgetState();
}

class _NewGameWidgetState extends State<NewGameWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    GameProvider game = Provider.of<GameProvider>(context);

    _onCreateGame() async {
      final response = await game.createGame(isChecked);

      if (response['status']) {
        String id = response['id'];

        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Lobby(id, isPrivate: isChecked)),
        );
        showSnackBar(context, 'Successfully created game');
      } else {
        Navigator.of(context).pop();
        showSnackBar(context, response['message']);
      }
    }

    return AlertDialog(
      title: const Text('Create New Game'),
      content: Row(
        children: <Widget>[
          // Text()
          Checkbox(
            value: isChecked,
            onChanged: (bool? newValue) {
              setState(() {
                isChecked = newValue!;
              });
            }
          ),
          const Text('Private')
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _onCreateGame,
          child: const Text('CREATE'),
        ),
      ],
    );
  }
}