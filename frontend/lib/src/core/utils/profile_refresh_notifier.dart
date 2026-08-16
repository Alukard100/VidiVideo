import 'package:flutter/material.dart';

class ProfileRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}