import 'package:flutter/material.dart';
import '../utils/user.dart'; // Asegúrate de importar UserCard y User
import '../functions/getUsers.dart'; // Asegúrate de importar la función getUsers
import '../utils/user_card.dart';
import '../dialogs/logoutDialog.dart';
import '../dialogs/showAccountsDialog.dart'; // Asegúrate de importar la función para mostrar el diálogo
import '../functions/changeUserStatus.dart'; // Asegúrate de importar la función para cambiar el estado del usuario
import '../dialogs/confirmacionDialog2.dart';
import '../dialogs/addUserAdminDialog.dart';
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

  Future<void> _onChangeUserStatus() async {
    if (_selectedUser != null) {
      try {
        bool status = await changeUserStatus(widget.accessToken, _selectedUser!.dni);
        await showConfirmationDialog2(context, _selectedUser!.name, status);
        setState(() {
          _futureUsers = getUsers(widget.accessToken); // Refresca la lista de usuarios
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar el estado del usuario: $e'),
          ),
        );
      }
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
            icon: Icon(Icons.add),
            onPressed: () {
              showAddUserAdminDialog(context,widget.accessToken);
              //Navigator.pushNamed(
                //  context,
                  //'/registrationAdmin',
                  //arguments: widget.accessToken);
              //showLogoutConfirmationDialog(context);
              // Aquí puedes manejar la lógica para el logout
              // Navigator.pushReplacementNamed(context, '/login'); // Ejemplo de redirección al login
            },
          ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Navegación', style: TextStyle(color: Colors.red)),
            ),
            ListTile(
              title: Text('AllAdmins'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/allAdmins',
                  arguments: widget.accessToken,
                );
              },
            ),
          ],
        ),
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
          if (_selectedUser == null)
            Expanded(
              child: Center(
                child: Text(
                  'Selecciona una cuenta',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16.0),
                ),
              ),
            ),
          if (_selectedUser != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _viewUserAccounts,
                      child: Text('Ver sus cuentas'),
                    ),
                  ),
                  SizedBox(width: 16.0), // Espacio entre los botones
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onChangeUserStatus,
                      child: Text('Change Status'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
