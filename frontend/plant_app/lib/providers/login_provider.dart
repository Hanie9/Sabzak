import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';

class LoginProvider with ChangeNotifier {
  final ApiService authService = ApiService();
  bool _isLoading = false;
  bool _isAdmin = false;

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;

  Future<Map<String, dynamic>> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await authService.login(username, password);
      if (response.containsKey('session_id')) {
        await authService.saveSessionId(response['session_id']);
        _isAdmin = await authService.isAdmin(response['session_id']);
      }
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'error': e.toString()};
    }
  }
}
