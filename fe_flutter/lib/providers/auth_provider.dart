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

    print('🔐 Starting login for: $email');
    final res = await AuthService.login(email, password);
    print('📥 Login response: $res');

    if (res != null) {
      token = res['token'];
      role = res['user']['role']; // <-- penting
      print('✅ Token saved: ${token?.substring(0, 20)}...');
      print('👤 Role: $role');
    } else {
      print('❌ Login failed - no response');
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
