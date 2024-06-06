import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registro Exitoso'),
          content: Text('Registro hecho con éxito.'),
        );
      },
    );
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context); // Cierra el diálogo
      Navigator.pushNamed(context, '/login');
    });
  }

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
              controller: _dniController,
              decoration: InputDecoration(
                labelText: 'dni',
              ),
            ),
            SizedBox(height: 12.0),
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
                final String dni = _dniController.text.trim();
                final String username = _usernameController.text.trim();
                final String password = _passwordController.text.trim();

                final GraphQLClient client = GraphQLService.createGraphQLClient('');

                final QueryResult result = await client.mutate(
                  MutationOptions(
                    document: gql(signUpMutation),
                    variables: {
                      'input': {
                        'dni': dni,
                        'name': username,
                        'password': password,
                      },
                    },
                  ),
                );

                if (result.hasException) {
                  print("Error en el registro: ${result.exception}");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error en el registro: ${result.exception.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
                  print("Registro exitoso: ${result.data!['signup']['name']}");
                  _showSuccessDialog(context);
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
