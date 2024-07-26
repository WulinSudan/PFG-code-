import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isDialogOpen = false;

Future<void> showLogoutConfirmationDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Logout'),
        content: Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada más
            },
          ),
          TextButton(
            child: Text('Salir'),
            onPressed: () async {
              // Elimina el token de SharedPreferences
              final SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('access_token');

              // Cierra el diálogo
              Navigator.of(context).pop();

              // Redirige al usuario a la página de inicio de sesión
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      );
    },
  );
}

void _showQrDialog(BuildContext context, String qrData, int amountToPay) {
  const duration = Duration(seconds: 10);
  if (isDialogOpen) return; // Evita abrir múltiples diálogos

  isDialogOpen = true;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      Timer(duration, () {
        if (isDialogOpen) {
          Navigator.of(context).pop();
          isDialogOpen = false;
        }
      });

      return AlertDialog(
        title: Text('Codi QR per pagar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: [
                    TextSpan(
                      text: 'Import a pagar: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: amountToPay == -1 ? 'Libre' : '€$amountToPay',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text('Aquest codi QR es caducarà en:'),
              CountdownWidget(duration: duration),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              isDialogOpen = false;
            },
            child: Text('Tanca'),
          ),
        ],
      );
    },
  );
}

class CountdownWidget extends StatefulWidget {
  final Duration duration;

  CountdownWidget({required this.duration});

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late int secondsLeft;

  @override
  void initState() {
    super.initState();
    secondsLeft = widget.duration.inSeconds;
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$secondsLeft segons',
      style: TextStyle(fontSize: 16),
    );
  }
}
