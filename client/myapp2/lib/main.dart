import 'package:flutter/material.dart';
import 'package:myapp/pages/home.dart';
import 'package:myapp/pages/choose_location.dart';
import 'package:myapp/pages/login.dart';
import 'package:myapp/pages/mainpage.dart';
import 'package:myapp/pages/welcome.dart';
import 'package:myapp/pages/qrmainpage.dart';
import 'package:myapp/pages/qrscannerpage.dart';
import 'package:myapp/pages/qrpayment.dart';

void main() => runApp(MaterialApp(

  initialRoute: '/mainpage',

  routes: {
    '/home': (context) => Home(),
    '/location': (context) => ChooseLocation(),
    '/login': (context) => Login(),
    '/welcomepage': (context) => WelcomePage(),
    '/mainpage': (context) => MainPage(username: 'Maria'),
    '/qrmainpage': (context) => QrMainPage(username:'Maria'),
    '/qrscannerpage': (context) => QRViewExample(),
    '/qrpayment': (context) => QrPayment(),
  },
));
