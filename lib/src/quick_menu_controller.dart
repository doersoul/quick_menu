import 'package:flutter/material.dart';

class QuickMenuController extends ChangeNotifier {
  bool _open = false;

  bool get isOpen => _open;

  void open() {
    _open = true;

    notifyListeners();
  }

  Future<void> close([VoidCallback? pushCallback]) async {
    _open = false;

    notifyListeners();

    if (pushCallback != null) {
      Future.delayed(Durations.medium1, pushCallback);
    }
  }
}
