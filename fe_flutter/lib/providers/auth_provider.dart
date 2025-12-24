import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? token;
  String? role; // admin / kasir
  bool isLoading = false;

  bool get isAuth => token != null;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    final res = await AuthService.login(email, password);

    if (res != null) {
      token = res['token'];
      role = res['user']['role']; // <-- penting
    }

    isLoading = false;
    notifyListeners();
    return token != null;
  }

  void logout() {
    token = null;
    role = null;
    notifyListeners();
  }
}
