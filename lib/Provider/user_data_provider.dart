import 'package:flutter/foundation.dart';

class UserDataProvider extends ChangeNotifier {
  dynamic userData;
  UserDataProvider({this.userData});
  updateUserData(data) {
    userData = data;
    notifyListeners();
  }
}

class LoginInfoProvider extends ChangeNotifier {
  bool isLoggedIn;
  LoginInfoProvider({this.isLoggedIn = true});
  void changeLoginStatus(bool value) {
    isLoggedIn = value;
    notifyListeners();
  }
}

class SelectedSoceityProvider extends ChangeNotifier {
  String? selectedSoceity, id;

  SelectedSoceityProvider({this.selectedSoceity, this.id});
  void updateSelectedSociety(String value, String idNo) {
    selectedSoceity = value;
    id = idNo;
    notifyListeners();
  }
}
