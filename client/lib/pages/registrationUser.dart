import 'dart:async';
import 'package:flutter/material.dart';
import '../functions/registerUser.dart'; // Import your registerUser function

class RegistrationUserPage extends StatefulWidget {
  @override
  _RegistrationUserPageState createState() => _RegistrationUserPageState();
}

class _RegistrationUserPageState extends State<RegistrationUserPage> {
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
      _isUsernameValid = RegExp(r'^[a-zA-Z0-9]{3,}$').hasMatch(username); // Allows alphanumeric characters with at least 3 characters
    });
  }

  void _validatePassword() {
    setState(() {
      _isPasswordValid = _passwordController.text.length >= 3;
    });
    _validatePasswordConfirmation();
  }

  void _validatePasswordConfirmation() {
    setState(() {
      _isPasswordConfirmationValid = _passwordConfirmationController.text == _passwordController.text &&
          _passwordConfirmationController.text.length >= 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register a new user'),
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
                      content: Text('Please correct the errors before submitting the form.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return; // Do nothing further if there are validation errors
                }

                final String dni = _dniController.text.trim();
                final String username = _usernameController.text.trim();
                final String password = _passwordController.text.trim();

                // Call the registerUser function to handle registration
                final registrationSuccess = await registerUser(context, dni, username, password);

                if (registrationSuccess) {
                  // Show a success message and wait 3 seconds before navigating
                  await Future.delayed(Duration(seconds: 2));
                  Navigator.pop(context);
                }
              },
              child: Text('Register'),
            ),
            SizedBox(height: 10.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous page
              },
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
