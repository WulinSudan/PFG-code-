import 'package:flutter/material.dart';


import 'pages/welcomepage.dart';
import 'pages/login.dart';
import 'pages/mainpage.dart';
import 'pages/qrmainpage.dart';
import 'pages/qrpayment.dart';
import 'pages/qrscannerpage.dart';

void main() => runApp(MaterialApp(

  initialRoute: '/mainpage',


  routes: {
    '/welcomepage': (context) => WelcomePage(),
    '/login': (context) => Login(),
    '/mainpage': (context) => MainPage(username: 'Maria'),
    '/qrmainpage': (context) => QrMainPage(username:'Maria'),
    '/qrscannerpage': (context) => QRViewExample(),
    '/qrpayment': (context) => QrPayment(),
  },
));
