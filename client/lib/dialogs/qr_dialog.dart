import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDialog {
  static bool isDialogOpen = false;

  static void showQrDialog(BuildContext context, String qrData, double amountToPay) {
    const duration = Duration(seconds: 10);
    if (isDialogOpen) return; // Evita abrir múltiples diálogos

    isDialogOpen = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
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
}

class CountdownWidget extends StatefulWidget {
  final Duration duration;

  const CountdownWidget({Key? key, required this.duration}) : super(key: key);

  @override
  _CountdownWidgetState createState() => _CountdownWidgetState();
}

class _CountdownWidgetState extends State<CountdownWidget> {
  late Timer _timer;
  int _remainingSeconds = 10;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.duration.inSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds--;
      });
      if (_remainingSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '$_remainingSeconds seconds',
      style: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
