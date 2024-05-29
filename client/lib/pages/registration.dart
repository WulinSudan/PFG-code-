import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
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

                final GraphQLClient client = GraphQLService.createGraphQLClient('');

                final QueryResult result = await client.mutate(
                  MutationOptions(
                    document: gql(
                        """
                      mutation Signup(\$name: String!, \$password: String!) {
                        signup(name: \$name, password: \$password) {
                          name
                        }
                      }
                      """
                    ),
                    variables: {
                      'name': username,
                      'password': password,
                    },
                  ),
                );

                if (result.hasException) {
                  print("Error en el registro: ${result.exception}");
                } else {
                  print("Registro exitoso: ${result.data!['signup']['name']}");
                  Navigator.pop(context);
                }
              },
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
