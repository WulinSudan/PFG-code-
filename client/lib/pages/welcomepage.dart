import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Waits for 3 seconds before navigating to the login page
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
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
          Image.asset(
            'assets/qrPay.png',
            width: 100.0,  // Adjust the size as needed
            height: 100.0, // Adjust the size as needed
          ),
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
