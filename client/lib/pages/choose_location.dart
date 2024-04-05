import 'package:flutter/material.dart';


class ChooseLocation extends StatefulWidget {
  const ChooseLocation({super.key});

  @override
  State<ChooseLocation> createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {

  int counter = 0;


  @override
  Widget build(BuildContext context) {
    print('built function ran');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text('Choose a Location'),
        centerTitle: true,
        elevation: 0,
      ),
      body: TextButton(
        onPressed: () {
          setState(() {
            counter += 1;
          });
        },
        child: Text('counter is $counter'),
      )
    );
  }
}
