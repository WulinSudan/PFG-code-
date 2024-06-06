import 'package:flutter/material.dart';
import 'account.dart';

class AccountCard extends StatefulWidget {
  final Account account;

  AccountCard({required this.account});

  @override
  _AccountCardState createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {

  @override
  Widget build(BuildContext context) {
    return InkWell(

      child: Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                widget.account.owner_name,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                widget.account.owner_dni,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                widget.account.account_number.toString(),
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 6.0),
              Text(
                'Saldo: \ ${widget.account.balance.toString()}€',
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
