import 'package:flutter/material.dart';


import 'pages/welcomepage.dart';
import 'pages/login.dart';

void main() => runApp(MaterialApp(

  initialRoute: '/welcomepage',


  routes: {
    '/welcomepage': (context) => WelcomePage(),
    '/login': (context) => Login(),
    // '/mainpage': (context) => MainPage(username: 'Maria'),
    // '/qrmainpage': (context) => QrMainPage(username:'Maria'),
    //'/qrscannerpage': (context) => QRViewExample(),
    //'/qrpayment': (context) => QrPayment(),
  },
));
