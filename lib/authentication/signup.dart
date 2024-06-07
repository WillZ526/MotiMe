import 'package:moti_me/themes.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:moti_me/database/database_helper.dart';
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.dbHelper});
  final DbHelper dbHelper;

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String username;
  late String email;
  late String password;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Themes.titleMedium('Sign Up', context),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an username';
                      } else if (value.length > 100) {
                        return 'Too many characters!';
                      }
                      username = value;
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      } else if (!EmailValidator.validate(value)) {
                        return 'Please enter a valid email';
                      }
                      email = value;
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      } else if (value.length < 8) {
                        return 'Password must have at least 8 characters';
                      }
                      password = value;
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    child: Themes.headlineSmall('Sign Up', context),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        String temp = await widget.dbHelper
                            .userRegistration(username, password, email);
                        if (temp.isEmpty) {
                          showSuccess();
                        } else {
                          showError(temp);
                        }
                      }
                    },
                  ),
                  Themes.bodyMedium(
                    errorMessage,
                    context,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showSuccess() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success!"),
          content: const Text("User was successfully created!"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Return to Login"),
              onPressed: () {
                Navigator.of(context).pop();
                () => context.go('/login/signup');
              },
            ),
          ],
        );
      },
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
            ElevatedButton(
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
