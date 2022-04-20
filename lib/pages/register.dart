import 'package:fiit_mtaa_fe/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiit_mtaa_fe/providers/auth.dart';
import 'games.dart';
import 'package:fiit_mtaa_fe/widgets/snack_bar.dart';

class Register extends StatefulWidget {
  const Register({ Key? key }) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool validateForm() {
    if (usernameController.text.length < 1 || nameController.text.length < 1 || passwordController.text.length < 1) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider auth = Provider.of<AuthProvider>(context);

    void _onRegister() async {

      if (validateForm()) {
        final response = await auth.register(usernameController.text, nameController.text, passwordController.text);

        usernameController.text = '';
        nameController.text = '';
        passwordController.text = '';

        if (response['status']) {
          showSnackBar(context, 'Successfully registered account');
          Navigator.pushReplacement(
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
        title: const Text('Create an Account')
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
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Enter your name',
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
                onPressed: _onRegister,
                child: const Text('SIGN UP'),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
                child: const Text('Already have an Account?'),
              ),
            ]
          )
        )
      ),
    );
  }
}
