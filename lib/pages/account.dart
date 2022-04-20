import 'package:fiit_mtaa_fe/providers/account.dart';
import 'package:fiit_mtaa_fe/widgets/delete_account.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiit_mtaa_fe/config.dart';

class Account extends StatefulWidget {
  const Account({ Key? key }) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController repeatPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AccountProvider account = Provider.of<AccountProvider>(context);

    void _onChangePassword() async {
      final response = await account.changePassword(oldPasswordController.text, newPasswordController.text);

      // oldPasswordController.text = '';
      // newPasswordController.text = '';
      // repeatPasswordController.text = '';

      if (response['status']) {
        showSnackBar(context, 'Successfully changed password');
      } else {
        showSnackBar(context, response['message']);
      }
    }

    void _onChangeAvatar() async {
      final response = await account.changeAvatar();

      if (response['status']) {

        // Timer(Duration(seconds: 5), () => setState(() { }));
        setState(() { });

        showSnackBar(context, 'Successfully changed avatar');
      } else {
        showSnackBar(context, response['message']);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account')
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: _onChangeAvatar,
                child: CircleAvatar(
                  radius: 75,
                  backgroundImage: NetworkImage('${Config.avatar}?username=${account.token['username']}&noCache=${DateTime.now().millisecondsSinceEpoch.toString()}'),
                  backgroundColor: Colors.white30,
                ),
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                ),
              ),

              const SizedBox(height: 10),
              Text(
                account.token['name'],
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              TextFormField(
                autofocus: false,
                obscureText: true,
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                autofocus: false,
                obscureText: true,
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                autofocus: false,
                obscureText: true,
                controller: repeatPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  hintText: 'Enter password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40)
                ),
                onPressed: _onChangePassword,
                child: const Text('CHANGE PASSWORD'),
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white60,
                  minimumSize: const Size.fromHeight(40)
                ),
                onPressed: () {
                  showDialog(context: context, builder: (BuildContext context) {
                    return const DeleteAccountWidget();
                  });
                },
                child: const Text(
                  'DELETE ACCOUNT',
                  style: TextStyle(color: Colors.black87)
                ),
              )
            ]
          )
        ),
      )
    );
  }
}