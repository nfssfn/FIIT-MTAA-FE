import 'package:fiit_mtaa_fe/pages/login.dart';
import 'package:fiit_mtaa_fe/providers/account.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAccountWidget extends StatefulWidget {
  const DeleteAccountWidget({Key? key}) : super(key: key);

  @override
  State<DeleteAccountWidget> createState() => _DeleteAccountWidgetState();
}

class _DeleteAccountWidgetState extends State<DeleteAccountWidget> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    AccountProvider account = Provider.of<AccountProvider>(context);

    _onDeleteAccount() async {
      final response = await account.deleteAccount();

      if (response['status']) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (Route<dynamic> route) => false
        );
        showSnackBar(context, 'Successfully deleted account');
      } else {
        Navigator.of(context).pop();
        showSnackBar(context, response['message']);
      }
    }

    return AlertDialog(
      title: const Text('Are you sure?'),
      content: const Text('Do you really want to delete your account? This process can not be undone.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _onDeleteAccount,
          child: const Text('DELETE'),
        ),
      ],
    );
  }
}