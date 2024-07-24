import 'package:flutter/material.dart';
import '../graphql_client.dart';
import '../graphql_queries.dart';
import '../functions/fetchChargeKey.dart';
import '../functions/fetchPayKey.dart';
import '../functions/encrypt.dart';
import '../functions/getOriginAccount.dart';
import '../functions/getOperation.dart';
import '../functions/makeTransfer.dart';

class QrGestion extends StatefulWidget {
  @override
  _QrGestionState createState() => _QrGestionState();
}

class _QrGestionState extends State<QrGestion> {
  String origen = '';
  String destino = '';
  double importe = 0.0;
  String? typePart;
  String? accessToken;
  String? operation;
  String? originAccount;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    // Recuperar los argumentos de la ruta
    final Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Obtener los datos de los argumentos
    accessToken = arguments?['accessToken'] as String?;
    String qrText = arguments?['qrCode'] as String? ?? 'Código QR no disponible';
    print("--------------------------35----------------- $qrText");

    try {
      // Obtener la cuenta de origen y la operación
      originAccount = await getOrigenAccount(accessToken!, qrText);
      operation = await getOperation(accessToken!, qrText);
      print(originAccount);
      print(operation);

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

      print("50--------------------------------------------");
      print(qrText);

      // Extraer el importe del texto desencriptado
      List<String> parts = qrText.split(' ');
      if (parts.length >= 3) {
        String amountPart = parts.last; // Asumimos que el importe está al final
        importe = double.tryParse(amountPart) ?? 0.0;
      } else {
        print('Formato de texto QR inválido');
        importe = 0.0;
      }

      // Actualizar el estado para reflejar los cambios en la UI
      setState(() {});

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

    // Verificar si el importe es mayor a 0 o igual a -1
    if (importe == -1) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showInputDialog(context);
      });
    } else if (importe > 0) {
      print("----------------------135------------------");
      doQr(accessToken!, origen, destino, importe);
    } else {
      print("error!");
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
                importe.toString(),
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

  void _showInputDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ingresar Importe'),
          content: TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "Ingrese el importe"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/mainpage', arguments: accessToken);
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                double? inputImporte = double.tryParse(_controller.text.replaceAll(',', '.'));
                if (inputImporte != null && inputImporte > 0) {
                  print("--------------------------199-----------------------");
                  print(inputImporte);
                  Navigator.of(context).pop();
                  doQr(accessToken!, origen, destino, inputImporte);

                  // Mostrar el diálogo de éxito
                  showDialog(
                    context: context,
                    barrierDismissible: false, // Evita que se cierre al tocar fuera del diálogo
                    builder: (BuildContext context) {
                      // Cerrar el diálogo automáticamente después de 3 segundos
                      Future.delayed(Duration(seconds: 3), () {
                        Navigator.of(context).pop(); // Cierra el diálogo de éxito
                        Navigator.pushNamed(context, '/mainpage', arguments: accessToken);
                      });

                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/exito.png'), // Ruta de la imagen de éxito
                            SizedBox(height: 16),
                            Text('Operación correcta'),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  // Mostrar un error si el importe no es válido
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, ingrese un importe válido.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
