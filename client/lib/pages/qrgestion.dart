import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../graphql_client.dart'; // Asegúrate de importar tu servicio GraphQL
import '../graphql_queries.dart';
import '../functions/fetchUserDate.dart';
import '../functions/addAccount.dart';

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
            'accountOrigen': origen,
            'accountDestin': desti,
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

class QrGestion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Recuperar los argumentos de la ruta
    Map<String, dynamic>? arguments = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Obtener los datos de los argumentos
    String? accessToken = arguments?['accessToken'] as String?;
    String qrText = arguments?['qrCode'] as String? ?? 'Código QR no disponible';
    String accountNumber = arguments?['accountNumber'] as String? ?? 'Número de cuenta no disponible';

    // Determinar origen y destino
    String origen = '';
    String destino = '';
    double importe = 0.0;

    // Verificar si el código QR comienza con 'from' y extraer los datos
    if (qrText.startsWith('from:')) {
      // Obtener partes del qrText
      List<String> parts = qrText.split(' ');
      String? originPart = parts.length > 1 ? parts[1] : null;
      String? importPart = parts.length > 3 ? parts[3] : null;

      print("-----------------------------68---------------------------");
      print(parts);
      print(originPart);
      print(importPart);

      // Asignar origen, destino e importe
      origen = originPart ?? 'Origen no disponible';
      destino = accountNumber; // Usar el número de cuenta como destino
      importe = double.tryParse(importPart ?? '0') ?? 0.0; // Parsear importe como double
    } else {
      origen = accountNumber; // Usar el número de cuenta como origen
      destino = qrText; // Usar el código QR como destino
      importe = 2.0; // Ejemplo de importe, ajustar según tu lógica
    }

    // Llamar a la función makeTransfer con los parámetros determinados
    doQr(accessToken!, origen, destino, importe);

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
                'Código QR:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                qrText.isNotEmpty ? qrText : 'Texto no disponible',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Text(
                'Transferencia realizada desde:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                origen.isNotEmpty ? origen : 'Origen no disponible',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'A cuenta:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                destino.isNotEmpty ? destino : 'Destino no disponible',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
