import 'package:flutter/material.dart';
import '../internal_functions/paymentGestion.dart'; // Asegúrate de que la ruta sea correcta
import '../internal_functions/maskAccountNumber.dart';
import '../dialogs/getImportDialog.dart'; // Asegúrate de que la ruta sea correcta
import '../internal_functions/chargeGestion.dart'; // Importa el nuevo archivo
import '../functions/getOrigenAccount.dart'; // Asegúrate de que la ruta sea correcta
import '../functions/fetchPayKey.dart';
import '../utils/encrypt.dart';
import '../functions/setQrUsed.dart';
import '../functions/checkEnable.dart';

class QrGestion extends StatefulWidget {
  @override
  _QrGestionState createState() => _QrGestionState();
}

class _QrGestionState extends State<QrGestion> {
  String origen = '';
  String destino = '';
  double importe = -1;
  String? typePart;
  String? accessToken;
  bool? transferSuccess;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (accessToken == null) {
      final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      accessToken = arguments?['accessToken'] as String?;
      String qrText = arguments?['qrCode'] as String? ?? 'Código QR no disponible';

      if (qrText.startsWith("charge")) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('Iniciando processQrCharge...');
          processQrCharge(context, qrText, arguments, accessToken!, updateState);
        });
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('Iniciando processQrPayment...');
          processQrPayment(context, qrText, arguments, accessToken!, updateState);
        });
      }
    }
  }

  void updateState(String origen, String destino, double importe, String typePart, bool success) {
    print('Actualizando estado:');
    print('Origen: $origen');
    print('Destino: $destino');
    print('Importe: $importe');
    print('TypePart: $typePart');
    print('Success: $success');

    if (mounted) {
      setState(() {
        this.origen = origen;
        this.destino = destino;
        this.importe = importe;
        this.typePart = typePart;
        this.transferSuccess = success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Captured QR'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Transfer scanned by:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                origen.isNotEmpty ? maskAccountNumber(origen) : 'Origin not available',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                'QR code information:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Transfer operation: ${typePart ?? 'Operation not available'}',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                destino.isNotEmpty ? maskAccountNumber(destino) : 'Destination not available',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                importe > 0 ? importe.toStringAsFixed(2) : 'Amount not available',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              if (transferSuccess == true)
                Icon(Icons.check_circle, color: Colors.green, size: 50)
              else if (transferSuccess == false)
                Icon(Icons.error, color: Colors.red, size: 50),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/mainpage', arguments: accessToken);
                },
                child: Text('return to the main page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
