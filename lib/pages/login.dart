import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_queries.dart';

class Login extends StatefulWidget {

  @override
  _LoginMutationState createState() => _LoginMutationState();
}

class _LoginMutationState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _accessToken;

  @override
  Widget build(BuildContext context) {
    return Mutation(
      options: MutationOptions(
        document: gql(loginUserMutation),
        onCompleted: (dynamic resultData) {
          setState(() {
            _accessToken = resultData['loginUser']['access_token'];
          });
        },
      ),
      builder: (
          RunMutation runMutation,
          QueryResult? result,
          ) {
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
                  onPressed: () {
                    runMutation({
                      'input': {
                        'name': _usernameController.text.trim(),
                        'password': _passwordController.text.trim(),
                      }
                    });
                  },
                  child: Text('Login'),
                ),
                if (_accessToken != null)
                  Column(
                    children: [
                      Text(
                        'Access Token: $_accessToken',
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context,
                              '/mainpage',
                              arguments: _accessToken);
                        },
                        child: Text('Ir a Main Page'),
                      ),
                    ],
                  ),

                if (result != null && result.hasException)
                  Text(
                    "Error en la autenticación: ${result.exception}",
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
