import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool isDialogOpen = false;

/*
void _showQrDialog(BuildContext context, String qrData, int amountToPay) {
  const duration = Duration(seconds: 10);
  if (isDialogOpen) return; // Prevent opening multiple dialogs

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
        title: Text('QR Code for Payment'),
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
                      text: 'Amount to Pay: ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: amountToPay == -1 ? 'Free' : '€$amountToPay',
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
              Text('This QR code will expire in:'),
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
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
*/
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
      '$secondsLeft seconds',
      style: TextStyle(fontSize: 16),
    );
  }
}
