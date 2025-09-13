import 'package:flutter/foundation.dart';

class QuickMenuController extends ChangeNotifier {
  bool _open = false;

  bool get isOpen => _open;

  void open() {
    _open = true;

    notifyListeners();
  }

  void close() {
    _open = false;

    notifyListeners();
  }
}
