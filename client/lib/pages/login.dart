import 'package:flutter/material.dart';
import '../functions/getUserRole.dart';
import '../functions/loginUser.dart';
import '../dialogs_simples/errorDialog.dart';
import '../dialogs_simples/processingDialog.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                final String username = _usernameController.text.trim();
                final String password = _passwordController.text.trim();

                // Show processing dialog
                processingDialog(context, "Identifying");

                try {
                  // Call loginUser to get the access token
                  final String? accessToken = await loginUser(context, username, password);

                  // Dismiss the processing dialog
                  Navigator.pop(context);

                  if (accessToken != null) {
                    // Call getUserRole to determine the user's role
                    final String role = await getUserRole(accessToken, username);

                    // Navigate based on user role
                    if (role != "admin") {
                      Navigator.pushReplacementNamed(
                        context,
                        '/mainpage',
                        arguments: accessToken,
                      );
                    } else {
                      print("User is an administrator");
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin',
                        arguments: accessToken,
                      );
                    }
                  } else {
                    Navigator.pop(context);
                    // Handle login failure (e.g., show an error message)
                    errorDialog(context, "Login failed. Please check your credentials.");
                  }
                } catch (error) {
                  // Dismiss the processing dialog in case of an error
                  Navigator.pop(context);
                  // Handle the error (e.g., show an error message)
                  errorDialog(context, "An error occurred. Please try again.");
                }
              },
              child: Text('Login'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registrationUser');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
