import 'package:flutter/material.dart';
import '../utils/user.dart';
import '../functions/getUsers.dart';
import '../utils/user_card.dart';
import '../dialogs/logoutDialog.dart';
import '../dialogs/showAccountsDialog.dart';
import '../functions/changeUserStatus.dart';
import '../dialogs/changeUserStatusDialog.dart';
import '../dialogs_simples/okDialog.dart';
import '../dialogs/addUserAdminDialog.dart';
import '../functions/removeUser.dart';
import '../dialogs/changePasswordDialog.dart';
import '../dialogs/setPassword.dart';
import '../functions/getLogs.dart';
import '../functions/getUserName.dart';

class AdminPage extends StatefulWidget {
  final String accessToken;

  AdminPage({required this.accessToken});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<User>> _futureUsers;
  User? _selectedUser;
  String? adminName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Cargar usuarios y nombre del administrador en paralelo
    setState(() {
      _futureUsers = getUsers(widget.accessToken);
    });
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    try {
      final name = await getUserName(widget.accessToken);
      setState(() {
        adminName = name;
      });
    } catch (e) {
      print('Error al obtener el nombre del administrador: $e');
    }
  }

  void _onUserSelected(User user) {
    setState(() {
      _selectedUser = user;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureUsers = getUsers(widget.accessToken);
      _selectedUser = null;
    });
  }

  void _viewUserAccounts() {
    if (_selectedUser != null) {
      showAccountsDialog(context, widget.accessToken, _selectedUser!.dni);
    } else {
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
        await changeUserStatusDialog(context, _selectedUser!.name, status);
        _refreshData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar el estado del usuario: $e'),
          ),
        );
      }
    } else {
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
          _refreshData();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar el usuario'),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, selecciona un usuario primero.'),
        ),
      );
    }
  }

  void _viewUserMovements() async {
    if (_selectedUser != null) {
      try {
        List<String> logs = await getLogs(widget.accessToken, _selectedUser!.dni);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Movimientos de ${_selectedUser!.name}'),
              content: logs.isNotEmpty
                  ? Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(logs[index]),
                    );
                  },
                ),
              )
                  : Text('No hay movimientos disponibles para este administrador.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener los movimientos: $e'),
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
        title: Text('Administer ${adminName ?? ''}'),
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: _refreshData, // Refrescar los datos
          ),
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
              child: Text('Navigation', style: TextStyle(color: Colors.red)),
            ),
            ListTile(
              title: Text('List all admins'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/allAdmins',
                  arguments: widget.accessToken,
                );
              },
            ),
            ListTile(
              title: Text('Change own password'),
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
                          isSelected: _selectedUser == user,
                        ),
                      );
                    },
                  );
                }
              },
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
                          child: Text('Show this accounts'),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showSetPasswordDialog(context, widget.accessToken, _selectedUser!.dni);
                          },
                          child: Text('Set a new password'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onChangeUserStatus,
                          child: Text('Change status'),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _viewDeleteUser,
                          child: Text('Remove user'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _viewUserMovements,
                          child: Text('Show his movements'),
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
