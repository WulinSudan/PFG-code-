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
import '../dialogs_simples/errorDialog.dart'; // Ensure this file exists to show error dialogs
import '../dialogs_simples/okDialog.dart'; // Ensure this file exists to show error dialogs
import '../dialogs_simples/askconfirmacion.dart'; // Ensure this file exists to show error dialogs


class AdminPage extends StatefulWidget {
  final String accessToken;

  // Constructor to initialize AdminPage with an access token
  AdminPage({required this.accessToken});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<User>> _futureUsers; // Future to hold the list of users
  User? _selectedUser; // Variable to keep track of the selected user
  String? adminName; // Variable to store the admin's name

  @override
  void initState() {
    super.initState();
    _loadData(); // Load initial data when the widget is initialized
  }

  // Method to load users and admin name
  Future<void> _loadData() async {
    setState(() {
      _futureUsers = getUsers(widget.accessToken); // Fetch users using access token
    });
    _loadAdminName(); // Load the admin's name
  }

  // Method to load the admin's name
  Future<void> _loadAdminName() async {
    try {
      final name = await getUserName(widget.accessToken); // Get admin's name using access token
      setState(() {
        adminName = name; // Store the admin's name
        print("------------------------------------");
        print(adminName); // Print admin's name for debugging
      });
    } catch (e) {
      print('Error retrieving admin name: $e'); // Error handling
    }
  }

  // Method to handle user selection
  void _onUserSelected(User user) {
    setState(() {
      _selectedUser = user; // Set the selected user
    });
  }

  // Method to refresh user data
  Future<void> _refreshData() async {
    setState(() {
      _futureUsers = getUsers(widget.accessToken); // Refresh the user list
      _selectedUser = null; // Clear the selected user
    });
  }

  // Method to view accounts of the selected user
  void _viewUserAccounts() {
    if (_selectedUser != null) {
      showAccountsDialog(context, widget.accessToken, _selectedUser!.dni); // Show accounts dialog
    } else {
      errorDialog(context, "Please, select a user first"); // Show error if no user is selected
    }
  }

// Method to change the status of the selected user
  Future<void> _onChangeUserStatus() async {
    bool? confirm = await askConfirmation(context);

    if (confirm == true) {
      if (_selectedUser != null) {
        try {
          bool status = await changeUserStatus(widget.accessToken, _selectedUser!.dni); // Change user status
          await changeUserStatusDialog(context, _selectedUser!.name, status); // Show status change dialog
          _refreshData(); // Refresh data after status change
        } catch (e) {
          errorDialog(context, "Error canviant l'estat de l'usuari"); // Show error if status change fails
        }
      } else {
        errorDialog(context, "Si us plau, selecciona primer un usuari"); // Show error if no user is selected
      }
    }
  }


  // Method to handle user deletion
  Future<void> _viewDeleteUser() async {
    if (_selectedUser != null) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Confirm deletion'),
          content: Text('Are you sure you want to delete ${_selectedUser!.name}?'), // Confirmation dialog
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel deletion
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
              child: Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          await removeUser(context, widget.accessToken, _selectedUser!.dni); // Remove the selected user
          okDialog(context, "User deleted"); // Show confirmation of deletion
          _refreshData(); // Refresh data after deletion
        } catch (e) {
          errorDialog(context, "Error deleting user, may have an account with amount"); // Show error if deletion fails
        }
      }
    }
  }

  // Method to view user movements/logs
  void _viewUserMovements() async {
    if (_selectedUser != null) {
      try {
        List<String> logs = await getLogs(widget.accessToken, _selectedUser!.dni); // Get user logs
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Movements of ${_selectedUser!.name}'),
              content: logs.isNotEmpty
                  ? Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: logs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(logs[index]), // Display each log entry
                    );
                  },
                ),
              )
                  : Text('No movements available for this user.'), // Show message if no logs available
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Close'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        errorDialog(context, "Error when obtaining the movements"); // Show error if log retrieval fails
      }
    } else {
      errorDialog(context, "Please, select a user first"); // Show error if no user is selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administer ${adminName ?? ''}'), // Display the admin's name in the title
        centerTitle: true,
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.autorenew),
            onPressed: _refreshData, // Refresh the data
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showAddUserAdminDialog(context, widget.accessToken); // Show dialog to add a new admin
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              showLogoutConfirmationDialog(context); // Show logout confirmation dialog
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Text('Navigation', style: TextStyle(color: Colors.red)), // Drawer header
            ),
            ListTile(
              title: Text('List all admins'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/allAdmins',
                  arguments: widget.accessToken, // Navigate to list all admins
                );
              },
            ),
            ListTile(
              title: Text('Change own password'),
              onTap: () {
                showChangePasswordDialog(context, widget.accessToken); // Show dialog to change own password
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<User>>(
              future: _futureUsers, // Future that holds the user list
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}')); // Show error if something goes wrong
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No users available.')); // Show message if no users are available
                } else {
                  final users = snapshot.data!;
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return GestureDetector(
                        onTap: () => _onUserSelected(user), // Handle user selection
                        child: UserCard(
                          user: user,
                          isSelected: _selectedUser == user, // Highlight the selected user
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
                          onPressed: _viewUserAccounts, // Show selected user's accounts
                          child: Text('Show accounts'),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            showSetPasswordDialog(context, widget.accessToken, _selectedUser!.dni); // Show dialog to set a new password
                          },
                          child: Text('Set new password'),
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
                          onPressed: _onChangeUserStatus, // Change status of the selected user
                          child: Text('Change status'),
                        ),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _viewDeleteUser, // Remove the selected user
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
                          onPressed: _viewUserMovements, // Show selected user's movements/logs
                          child: Text('Show movements'),
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
