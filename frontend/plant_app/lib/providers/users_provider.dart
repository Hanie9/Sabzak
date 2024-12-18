import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/models/users_model.dart';

class UsersProvider with ChangeNotifier{
  final ApiService authService = ApiService();
  List<Users> _users = [];
  bool _isLoading = false;

  List<Users> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchusers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await authService.getUsers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}