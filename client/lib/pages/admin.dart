import 'package:flutter/material.dart';
import '../utils/user.dart'; // Asegúrate de importar UserCard y User
import '../functions/getUsers.dart'; // Asegúrate de importar la función getUsers
import '../utils/user_card.dart';
import '../dialogs/logoutDialog.dart';
import '../dialogs/showAccountsDialog.dart'; // Asegúrate de importar la función para mostrar el diálogo
import '../functions/changeUserStatus.dart'; // Asegúrate de importar la función para cambiar el estado del usuario
import '../dialogs/confirmacionDialog2.dart';
import '../dialogs/confirmationOKdialog.dart';
import '../dialogs/addUserAdminDialog.dart';
import '../functions/removeUser.dart'; // Asegúrate de importar la función para eliminar un usuario
import '../dialogs/changePasswordDialog.dart';
import '../dialogs/setPassword.dart';

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

  Future<void> _viewDeleteUser() async {
    if (_selectedUser != null) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar a ${_selectedUser!.name}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Eliminar'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await removeUser(context, widget.accessToken, _selectedUser!.dni);
          setState(() {
            _futureUsers = getUsers(widget.accessToken); // Refresca la lista de usuarios
            _selectedUser = null; // Resetea el usuario seleccionado
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el usuario'),
            ),
          );
        }
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
              showAddUserAdminDialog(context, widget.accessToken);
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showLogoutConfirmationDialog(context);
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
            ListTile(
              title: Text('Change password'),
              onTap: () {
                showChangePasswordDialog(context, widget.accessToken);
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
              child: Column(
                children: [
                  Row(
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
                          onPressed: () {
                            showSetPasswordDialog(context, widget.accessToken, _selectedUser!.dni);
                          },
                          child: Text('Set new password'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0), // Espacio entre las filas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onChangeUserStatus,
                          child: Text('Cambiar estado'),
                        ),
                      ),
                      SizedBox(width: 16.0), // Espacio entre los botones
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _viewDeleteUser,
                          child: Text('Eliminar usuario'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
