import 'dart:async';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../functions/addAccount.dart';

class RegistrationUserPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationUserPage> {
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();

  bool _isDniValid = false;
  bool _isUsernameValid = false;
  bool _isPasswordValid = false;
  bool _isPasswordConfirmationValid = false;

  @override
  void initState() {
    super.initState();
    _dniController.addListener(_validateDni);
    _usernameController.addListener(_validateUsername);
    _passwordController.addListener(_validatePassword);
    _passwordConfirmationController.addListener(_validatePasswordConfirmation);
  }

  void _validateDni() {
    setState(() {
      _isDniValid = _dniController.text.length == 9;
    });
  }

  void _validateUsername() {
    final username = _usernameController.text;
    setState(() {
      _isUsernameValid = RegExp(r'^[a-zA-Z0-9]{3,}$').hasMatch(username); // Permite caracteres alfabéticos y números con más de 2 caracteres
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 3;
    });
    _validatePasswordConfirmation(); // Revalidar confirmación si la contraseña cambia
  }

  void _validatePasswordConfirmation() {
    setState(() {
      _isPasswordConfirmationValid = _passwordConfirmationController.text == _passwordController.text &&
          _passwordConfirmationController.text.length >= 3;
    });
  }

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
      Navigator.pop(context); // Vuelve a AdminPage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Alta a un nuevo administrador'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _dniController,
              decoration: InputDecoration(
                labelText: 'DNI',
                suffixIcon: _isDniValid ? Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                suffixIcon: _isUsernameValid ? Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: _isPasswordValid ? Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordConfirmationController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                suffixIcon: _isPasswordConfirmationValid ? Icon(Icons.check_circle, color: Colors.green) : null,
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (!_isDniValid || !_isUsernameValid || !_isPasswordValid || !_isPasswordConfirmationValid) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor, corrija los errores antes de enviar el formulario.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // No hacer nada más si hay errores de validación
                }

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error en el registro: ${result.exception.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else {
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
