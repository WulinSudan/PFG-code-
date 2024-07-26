import 'package:flutter/material.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../functions/fetchChargeKey.dart';
import '../functions/fetchPayKey.dart';
import '../functions/encrypt.dart';
import '../functions/getOriginAccount.dart';
import '../functions/getOperation.dart';
import '../functions/doQr.dart';
import '../dialogs/showHelloDialog.dart'; // Importa la función correcta

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
  String? operation;
  String? originAccount;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Llamar solo si accessToken es null (esto asegura que processQr solo se llame una vez)
    if (accessToken == null) {
      final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      accessToken = arguments?['accessToken'] as String?;
      String qrText = arguments?['qrCode'] as String? ?? 'Código QR no disponible';
      print("-----------------En qrgestion, mensaje cifrado: $qrText");
      processQr(qrText, arguments);
    }
  }

  Future<void> processQr(String qrText, Map<String, dynamic>? arguments) async {
    try {
      // Obtener la cuenta de origen y la operación
      originAccount = await getOrigenAccount(accessToken!, qrText);
      operation = await getOperation(accessToken!, qrText);
      print("-----------------En processQr, qr generado por: $originAccount, tipo de operación: $operation");

      String cuentaEscaneadora = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';
      print("-----------------En processQr, qr escaneada por: $cuentaEscaneadora");

      // Desencriptar el texto del QR usando la clave adecuada
      if (operation == 'charge') {
        origen = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';
        destino = originAccount ?? 'Destino no disponible';
        String chargeKey = await fetchChargeKey(accessToken!, originAccount!);
        qrText = decryptAES(qrText, chargeKey);
        typePart = 'Cargo'; // Asumimos que este es el tipo para 'charge'
      } else if (operation == 'payment') {
        origen = originAccount ?? 'Origen no disponible';
        destino = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';
        String payKey = await fetchPayKey(accessToken!, originAccount!);
        qrText = decryptAES(qrText, payKey);
        typePart = 'Pago'; // Asumimos que este es el tipo para 'payment'
      } else {
        throw Exception('Tipo de operación no válido');
      }

      // Extraer el importe del texto desencriptado
      List<String> parts = qrText.split(' ');
      if (parts.length >= 3) {
        String amountPart = parts.last; // Asumimos que el importe está al final
        importe = double.tryParse(amountPart) ?? 0.0;
      }

      // Verificar si el importe es mayor a 0
      if (importe == -1) {
        print("--------------------importe -1");
        String? nuevoImporte = await showImporteDialog(context);
        if (nuevoImporte != null && nuevoImporte.isNotEmpty) {
          importe = double.tryParse(nuevoImporte) ?? -1;
        }
      }

      print("ya tenemos todos los datos");

      doQr(accessToken!, origen, destino, importe);

    } catch (e) {
      print('Error al descifrar el código QR: $e');
      // Manejar el error según sea necesario
      return;
    }

    print("------------------------113---------------------------");
    print("origen: $origen");
    print("destino: $destino");
    print("importe: $importe");
    print("accessToken: $accessToken");
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
                origen.isNotEmpty ? origen : 'Origen no disponible',
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
                destino.isNotEmpty ? destino : 'Destino no disponible',
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
