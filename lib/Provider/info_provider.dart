import 'package:flutter/foundation.dart';

class InfoProvider extends ChangeNotifier {
  dynamic message;
  updateMessage(dynamic value) {
    message = value;
    notifyListeners();
  }
}
