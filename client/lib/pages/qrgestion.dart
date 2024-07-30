import 'package:flutter/material.dart';
import '../functions/doQr.dart'; // Asegúrate de que la ruta sea correcta
import '../internal_functions/maskAccountNumber.dart';
import '../dialogs/getImportDialog.dart'; // Asegúrate de que la ruta sea correcta

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
  bool? transferSuccess; // Para rastrear el resultado de la transferencia

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (accessToken == null) {
      final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      accessToken = arguments?['accessToken'] as String?;
      String qrText = arguments?['qrCode'] as String? ?? 'Código QR no disponible';

      if (qrText.startsWith("charge")) {
        // Llama a processQrCharge solo si el QR tiene un prefijo válido
        WidgetsBinding.instance.addPostFrameCallback((_) {
          processQrCharge(qrText, arguments);
        });
      } else {
        print("El texto del QR no comienza con 'charge'");
      }
    }
  }

  Future<void> processQrCharge(String qrText, Map<String, dynamic>? arguments) async {
    try {
      // Asumimos que qrText comienza con 'charge', por lo que eliminamos ese prefijo
      String remainingText = qrText.substring("charge".length).trim();

      // Separar el número de cuenta y el importe
      List<String> parts = remainingText.split(' ');
      if (parts.length == 2) {
        String accountNumber = parts[0]; // Número de cuenta
        double? amount = double.tryParse(parts[1]); // Importe

        if (amount == null || amount <= 0) {
          // Si el importe no es válido o es <= 0, pedimos al usuario que lo ingrese
          amount = await getImportDialog(context) ?? 0.0;
        }

        // Obtener el número de cuenta de origen desde los argumentos
        origen = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';
        destino = accountNumber;
        importe = amount; // No es necesario usar importe ?? 0.0 aquí porque amount no será null aquí
        typePart = 'Cargo'; // Tipo de operación

        // Realizar la operación doQr y actualizar el estado basado en el resultado
        bool success = await doQr(accessToken!, origen, destino, importe);

        // Usa addPostFrameCallback para asegurarte de que setState se llama después de que la construcción se haya completado
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            this.origen = origen;
            this.destino = destino;
            this.importe = importe;
            this.typePart = typePart;
            this.transferSuccess = success; // Transferencia exitosa o fallida
          });
        });
      } else {
        print("El texto del QR no tiene el formato esperado.");
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            transferSuccess = false; // Error al procesar el QR
          });
        });
      }
    } catch (e) {
      print('Error al procesar el código QR: $e');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          transferSuccess = false; // Error al procesar el QR
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Capturado'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Transferencia escaneada por:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                origen.isNotEmpty ? maskAccountNumber(origen) : 'Origen no disponible',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              Text(
                'Información del código QR:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Tipo de transferencia: ${typePart ?? 'Tipo no disponible'}',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                destino.isNotEmpty ? maskAccountNumber(destino) : 'Destino no disponible',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                importe > 0 ? importe.toString() : 'Importe no disponible',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              // Mostrar ícono basado en el resultado de la transferencia
              if (transferSuccess == true)
                Icon(Icons.check_circle, color: Colors.green, size: 50)
              else if (transferSuccess == false)
                Icon(Icons.error, color: Colors.red, size: 50),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/mainpage', arguments: accessToken);
                },
                child: Text('Volver a la página principal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
