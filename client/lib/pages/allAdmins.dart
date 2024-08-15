import 'package:flutter/material.dart';
import '../utils/user.dart';
import '../functions/getAdmins.dart';
import '../utils/user_card.dart';

class AllAdminsPage extends StatefulWidget {
  final String accessToken;

  AllAdminsPage({required this.accessToken});

  @override
  _AllAdminsPageState createState() => _AllAdminsPageState();
}

class _AllAdminsPageState extends State<AllAdminsPage> {
  late Future<List<User>> _futureAdmins;
  User? _selectedAdmin; // Para almacenar el administrador seleccionado

  @override
  void initState() {
    super.initState();
    _futureAdmins = getAdmins(widget.accessToken); // Cargar la lista de administradores
  }

  void _onAdminSelected(User admin) {
    setState(() {
      _selectedAdmin = admin; // Marcar el administrador seleccionado
    });
  }

  void _viewAdminMovements() {
    if (_selectedAdmin != null) {
      // Aquí debes implementar la lógica para mostrar los movimientos del administrador seleccionado
      // Por ejemplo, puedes navegar a otra página que muestre los movimientos
      Navigator.pushNamed(
        context,
        '/adminMovements', // Asegúrate de definir esta ruta en tu configuración de navegación
        arguments: _selectedAdmin!.dni,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona un administrador primero.'),
        ),
      );
    }
  }

  Future<void> _deactivateAdmin() async {
    if (_selectedAdmin != null) {
      // Aquí debes implementar la lógica para desactivar el administrador seleccionado
      // Por ejemplo, puedes hacer una llamada a una función que actualice el estado del administrador
      // y luego refrescar la lista de administradores.

      try {
        // Supongamos que tienes una función `deactivateAdmin` para desactivar el administrador
        // bool success = await deactivateAdmin(widget.accessToken, _selectedAdmin!.dni);

        // Aquí, deberías implementar la lógica para desactivar el administrador y manejar el estado.

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Administrador desactivado correctamente.'),
          ),
        );
        setState(() {
          _futureAdmins = getAdmins(widget.accessToken); // Refresca la lista de administradores
          _selectedAdmin = null; // Desmarcar el administrador después de desactivarlo
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al desactivar el administrador: $e'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona un administrador primero.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administradores'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _futureAdmins,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay administradores disponibles.'));
                } else {
                  final admins = snapshot.data!;
                  return ListView.builder(
                    itemCount: admins.length,
                    itemBuilder: (context, index) {
                      final admin = admins[index];
                      return GestureDetector(
                        onTap: () => _onAdminSelected(admin), // Selecciona el admin cuando se toca
                        child: UserCard(
                          user: admin,
                          isSelected: _selectedAdmin == admin, // Marca el card como seleccionado si coincide
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          if (_selectedAdmin != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _viewAdminMovements,
                      child: Text('Ver sus movimientos'),
                    ),
                  ),
                  SizedBox(width: 16.0), // Espacio entre los botones
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _deactivateAdmin,
                      child: Text('Desactivar'),
                    ),
                  ),
                ],
              ),
            ),
          if (_selectedAdmin == null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Selecciona un administrador para realizar acciones',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
