import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';

class SignupProvider with ChangeNotifier {
  final ApiService authService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> signup(String username, String email, String password, String firstName, String lastName) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await authService.signup(username, email, password, firstName, lastName);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('SignupProvider error: $e');
      return {'error': e.toString()};
    }
  }
}
