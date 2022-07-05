import 'package:flutter/foundation.dart';

class InfoProvider extends ChangeNotifier {
  dynamic message = "Please start the fingerprint scanner";
  updateMessage(dynamic value) {
    message = value;
    notifyListeners();
  }
}
