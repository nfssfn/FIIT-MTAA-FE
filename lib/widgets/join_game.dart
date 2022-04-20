import 'package:flutter/material.dart';
import 'package:fiit_mtaa_fe/pages/lobby.dart';

class JoinGameWidget extends StatefulWidget {
  const JoinGameWidget({Key? key}) : super(key: key);

  @override
  State<JoinGameWidget> createState() => _JoinGameWidgetState();
}

class _JoinGameWidgetState extends State<JoinGameWidget> {
  TextEditingController gameIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Game'),
      content: TextFormField(
        autofocus: true,
        controller: gameIDController,
        decoration: const InputDecoration(
          labelText: 'ID',
          hintText: 'Enter ID',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Lobby(gameIDController.text)),
            );
          },
          child: const Text('JOIN'),
        ),
      ],
    );
  }
}