import 'package:flutter/material.dart';
import 'package:moti_me/database/rem_helper.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'ref_helper.dart';

class DbHelper {
  ParseUser? user;
  static final DbHelper _dbHelper = DbHelper._();
  DbHelper._();
  factory DbHelper() {
    return _dbHelper;
  }

  ParseUser? getUser() => user;
  Future<void> initParse() async {
    const keyApplicationId = '5biWTbbnmxc6KnaQbDiG2TUd7CGzQtoE5jhCP7aK';
    const keyClientKey = 'd6gL5Uqh2Qs36nITF37yA252UFf1021VxqQafUO9';
    const keyParseServerUrl = 'https://parseapi.back4app.com/';

    await Parse().initialize(
      keyApplicationId,
      keyParseServerUrl,
      clientKey: keyClientKey,
      autoSendSessionId: true,
      debug: true,
    );
  }

  Future<bool> checkUserLogin() async {
    final temp = await ParseUser.currentUser();
    if (temp != null && user == null) {
      user = temp;
      return true;
    } else if (temp != null) {
      return true;
    }
    return false;
  }

  Future<String> userRegistration(
      String username, String password, String email) async {
    final tempUser = ParseUser.createUser(username, password, email);
    var response = await tempUser.signUp();

    if (response.success) {
      return '';
    } else {
      return response.error!.message;
    }
  }

  Future<String> userLogin(String email, String password) async {
    final tempUser = ParseUser(email, password, null);
    var response = await tempUser.login();
    if (response.success) {
      user = tempUser;
      return '';
    } else {
      return response.error!.message;
    }
  }

  Future<void> userLogout(RefHelper refHelper, RemHelper remHelper) async {
    if (user != null) {
      refHelper.clearReflection();
      remHelper.clearReminders();
      await user?.logout();
    } else {
      print('smt wrong');
    }
  }

  Future<void> initUserData(RefHelper refHelper, RemHelper remHelper) async {
    await refHelper.loadReflections(getUser()!);
    await remHelper.loadReminders(getUser()!);
  }
}

class UserProvider with ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  Future<void> login() async {
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    print('occurred (logout test)');
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> checkLogin() async {
    _isLoggedIn = await DbHelper().checkUserLogin();
    notifyListeners();
  }
}
