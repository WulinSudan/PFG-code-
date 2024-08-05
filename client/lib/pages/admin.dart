import 'package:flutter/material.dart';
import '../utils/user.dart'; // Asegúrate de importar UserCard y User
import '../functions/getUsers.dart'; // Asegúrate de importar la función getUsers
import '../utils/user_card.dart';
import '../dialogs/logoutDialog.dart';
import '../dialogs/showAccountsDialog.dart'; // Asegúrate de importar la función para mostrar el diálogo

class AdminPage extends StatefulWidget {
  final String accessToken;

  AdminPage({required this.accessToken});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<User>> _futureUsers;
  User? _selectedUser; // Para almacenar el usuario seleccionado

  @override
  void initState() {
    super.initState();
    _futureUsers = getUsers(widget.accessToken);
  }

  void _onUserSelected(User user) {
    setState(() {
      _selectedUser = user;
    });
  }

  void _viewUserAccounts() {
    if (_selectedUser != null) {
      // Muestra el diálogo con las cuentas del usuario seleccionado
      showAccountsDialog(context, widget.accessToken, _selectedUser!.dni);
    } else {
      // Muestra un mensaje si no hay usuario seleccionado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona un usuario primero.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: true, // Esto muestra el ícono de retroceso
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showLogoutConfirmationDialog(context);
              // Aquí puedes manejar la lógica para el logout
              // Navigator.pushReplacementNamed(context, '/login'); // Ejemplo de redirección al login
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No hay usuarios disponibles.'));
                } else {
                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return GestureDetector(
                        onTap: () => _onUserSelected(user),
                        child: UserCard(
                          user: user,
                          isSelected: _selectedUser == user, // Marca el card como seleccionado si coincide
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedUser != null ? _viewUserAccounts : null, // Desactiva el botón si no hay usuario seleccionado
              child: Text('Ver sus cuentas'),
            ),
          ),
        ],
      ),
    );
  }
}
