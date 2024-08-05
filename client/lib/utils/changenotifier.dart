import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  Color _appBarColor = Colors.redAccent;

  Color get appBarColor => _appBarColor;

  void updateColor(Color newColor) {
    _appBarColor = newColor;
    notifyListeners();
  }
}
