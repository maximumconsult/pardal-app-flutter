import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get error => _error;
  String get userName => _user?['name'] ?? '';
  String get userEmail => _user?['email'] ?? '';
  String get userRole => _user?['role'] ?? '';

  Future<bool> tryAutoLogin() async {
    final token = await _api.token;
    if (token == null) return false;
    try {
      final response = await _api.get('/auth/profile');
      _user = response['user'] as Map<String, dynamic>;
      notifyListeners();
      return true;
    } catch (e) {
      await _api.clearToken();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      await _api.setToken(response['token'] as String);
      _user = response['user'] as Map<String, dynamic>;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout', {});
    } catch (_) {}
    await _api.clearToken();
    _user = null;
    notifyListeners();
  }

  Future<bool> updateProfile(String name, String? phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final body = <String, dynamic>{'name': name};
      if (phone != null && phone.isNotEmpty) body['phone'] = phone;
      final response = await _api.put('/auth/profile', body);
      _user = response['user'] as Map<String, dynamic>;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String current, String newPass, String confirm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.put('/auth/profile', {
        'current_password': current,
        'password': newPass,
        'password_confirmation': confirm,
      });
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
