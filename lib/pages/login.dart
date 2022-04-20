import 'package:fiit_mtaa_fe/pages/game_screen.dart';
import 'package:fiit_mtaa_fe/pages/role.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';
import 'package:flutter/material.dart';
import 'register.dart';
import 'games.dart';
import 'package:fiit_mtaa_fe/providers/auth.dart';
import 'package:provider/provider.dart';
import 'video_call.dart';

class Login extends StatefulWidget {
  const Login({ Key? key }) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool validateForm() {
    if (usernameController.text.length < 0 || passwordController.text.length < 0) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    void _onLogin() async {
      if (validateForm()) {
        // final response = await auth.login('user', 'user');
        final response = await auth.login(usernameController.text, passwordController.text);

        usernameController.text = '';
        passwordController.text = '';

        if (response['status']) {
          showSnackBar(context, 'Successfully logged in');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Games()),
          );
        } else {
          showSnackBar(context, response['message']);
        }
      } else {
        showSnackBar(context, 'Form is invalid');
      }

    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Account')
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
              SizedBox(
                width: 200,
                height: 150,
                child: Image.asset('assets/images/logo.png')
              ),
              const SizedBox( height: 30),

              TextFormField(
                autofocus: false,
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                autofocus: false,
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40)
                ),
                onPressed: _onLogin,
                child: const Text('SIGN IN'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                child: const Text('Create an Account'),
              )
            ]
          )
        )
      ),
    );
  }
}
