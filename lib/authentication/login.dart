import 'package:email_validator/email_validator.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:moti_me/themes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.dbHelper});
  final DbHelper dbHelper;

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  String? email;
  String? password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Themes.headlineSmall('Motivation Time!', context)),
        leadingWidth: 200,
        actions: [
          ElevatedButton(
            onPressed: () async {
              context.go('/login/signup');
            },
            child: Themes.titleMedium('Sign Up', context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'MotiMe',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Themes.headlineMedium('Log In to continue', context),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Email';
                        } else if (!EmailValidator.validate(value)) {
                          return 'Email Invalid';
                        }
                        email = value;
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        labelText: 'Email',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter Password';
                        } else if (value.length < 8) {
                          return 'Password Invalid';
                        }
                        password = value;
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        labelText: 'Password',
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final String temp = await widget.dbHelper
                              .userLogin(email!, password!);
                          if (temp.isEmpty) {
                            if (context.mounted) {
                              await Provider.of<UserProvider>(context,
                                      listen: false)
                                  .login();
                            }
                          } else {
                            showError(temp);
                          }
                        }
                      },
                      child: Themes.headlineSmall('Login', context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showError(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error!"),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
