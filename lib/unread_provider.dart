// C:\Users\wkhan\dentalkey\lib\unread_provider.dart

import 'package:flutter/material.dart';

class UnreadProvider with ChangeNotifier {
  List<int> _unreadIndices = [];

  List<int> get unreadIndices => _unreadIndices;

  void setUnreadIndices(List<int> indices) {
    _unreadIndices = indices;
    notifyListeners();
  }

  void clearUnreadIndices() {
    _unreadIndices = [];
    notifyListeners();
  }

  void addUnreadIndex(int index) {
    _unreadIndices.add(index);
    notifyListeners();
  }

  void removeUnreadIndex(int index) {
    _unreadIndices.remove(index);
    notifyListeners();
  }
}
