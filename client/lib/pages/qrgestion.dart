import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import '../functions/addAccount.dart';
import 'package:flutter/material.dart';
import '../functions/encrypt.dart';

// Función para realizar la transferencia
Future<void> doQr(String accessToken, String origen, String desti, double import) async {
  print('Origen: $origen');
  print('Destino: $desti');
  print('Importe: $import');

  final GraphQLClient client = GraphQLService.createGraphQLClient(accessToken);

  try {
    final QueryResult result = await client.mutate(
      MutationOptions(
        document: gql(makeTransferMutation),
        variables: {
          'input': {
            'accountOrigen': desti,
            'accountDestin': origen,
            'import': import,
          }
        },
      ),
    );

    if (result.hasException) {
      print('Error al ejecutar la mutación: ${result.exception.toString()}');
      // Manejo de error adicional según sea necesario
    } else {
      print('Mutación exitosa');
      // Aquí puedes manejar la respuesta de la mutación si es necesario
      // Por ejemplo, podrías actualizar las cuentas llamando a fetchUserAccounts()
      // O realizar alguna otra acción según tus necesidades
    }
  } catch (e) {
    print('Error inesperado: $e');
    // Manejo de error adicional según sea necesario
  }
}

class QrGestion extends StatefulWidget {
  @override
  _QrGestionState createState() => _QrGestionState();
}

class _QrGestionState extends State<QrGestion> {
  String origen = '';
  String destino = '';
  double importe = 0.0;
  String? typePart = '';
  String? accessToken;

  @override
  Future<void> didChangeDependencies() async{
    super.didChangeDependencies();

    // Recuperar los argumentos de la ruta
    Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Obtener los datos de los argumentos
    accessToken = arguments?['accessToken'] as String?;
    String qrText = arguments?['qrCode'] as String? ?? 'Código QR no disponible';

    // Descifrar el texto del código QR usando la función de desencriptación
    qrText = await decryptData(qrText);

    String accountNumber = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';

    // Verificar si el código QR comienza con 'c' o 'p' y extraer los datos
    if (qrText.startsWith('c') || qrText.startsWith('p')) {
      // Obtener partes del qrText
      List<String> parts = qrText.split(' ');
      typePart = parts.isNotEmpty ? parts[0] : null;
      String? accountPart = parts.length > 1 ? parts[1] : null;
      String? amountPart = parts.length > 2 ? parts[2] : null;

      print("-----------------------------68---------------------------");
      print(parts);
      print(typePart);
      print(accountPart);
      print(amountPart);

      // Asignar origen, destino e importe
      if (typePart == 'c') {
        setState(() {
          origen = accountPart ?? 'Origen no disponible';
          destino = accountNumber; // Usar el número de cuenta como destino
        });
      } else if (typePart == 'p') {
        setState(() {
          origen = accountNumber; // Usar el número de cuenta como origen
          destino = accountPart ?? 'Destino no disponible';
        });
      }
      setState(() {
        importe = double.tryParse(amountPart?.replaceAll(',', '.') ?? '0') ?? 0.0; // Parsear importe como double
      });
    } else {
      setState(() {
        origen = accountNumber; // Usar el número de cuenta como origen
        destino = qrText; // Usar el código QR como destino
        importe = 2.0; // Ejemplo de importe, ajustar según tu lógica
      });
    }

    // Verificar si el importe es mayor a 0 o igual a -1
    if (importe == -1) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _showInputDialog(context);
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
                  Navigator.pushNamed(
                      context,
                      '/mainpage',
                      arguments: accessToken);
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
                Navigator.pushNamed(
                  context,
                  '/mainpage',
                  arguments: accessToken,
                );
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
                        Navigator.pushNamed(
                          context,
                          '/mainpage',
                          arguments: accessToken,
                        );
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
