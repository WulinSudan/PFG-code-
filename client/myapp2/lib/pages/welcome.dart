import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Espera 2 segundos antes de navegar a la página de inicio de sesión
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushNamed(context, '/login');
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome'),
      ),
      body: WelcomeBody(),
    );
  }
}

class WelcomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FlutterLogo(size: 100.0),
          SizedBox(height: 20.0),
          Text(
            'PAYMENT QR',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}