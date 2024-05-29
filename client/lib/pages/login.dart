import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tus consultas/mutaciones GraphQL aquí
import '../graphql_queries.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

                final GraphQLClient client = GraphQLService.createGraphQLClient('Bearer YourAuthToken');

                // Envío de la mutación al servidor GraphQL
                final QueryResult result = await client.mutate(
                  MutationOptions(
                    document: gql(loginUserMutation),
                    variables: {
                      'input': {
                        'name': username,
                        'password': password,
                      },
                    },
                  ),
                );

                // Manejo del resultado de la mutación
                if (result.hasException) {
                  print("++++++++++++++++++++++++++++++++++++++++++++");
                  // Manejar errores de autenticación
                  print("Error en la autenticación: ${result.exception}");
                } else {
                  print("************************************************");
                  // Autenticación exitosa, obtener el token de acceso y navegar a la siguiente pantalla
                  final String accessToken = result.data!['loginUser']['access_token'];
                  print(accessToken);
                  Navigator.pushNamed(
                      context,
                      '/mainpage',
                      arguments: accessToken);
                }
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/registration');
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
