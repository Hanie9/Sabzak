import 'package:flutter/material.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final ApiService authService = ApiService();
  List<CartItem> _cartItems = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  Future<void> fetchCartItems() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cartItems = await authService.getCartItems();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(int plantId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final index = _cartItems.indexWhere((item) => item.plantId == plantId);
      if(index >= 0){
        await authService.increaseQuantity(plantId);
      } else {
      await authService.addToCart(plantId);
      }
      await fetchCartItems();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCartItem(int plantId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.deleteCartItem(plantId);
      await fetchCartItems();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.clearCart();
      await fetchCartItems();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> increaseQuantity(int plantId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.increaseQuantity(plantId);
      await fetchCartItems();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> decreaseQuantity(int plantId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await authService.decreaseQuantity(plantId);
      await fetchCartItems();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  double getTotalAmount() {
    return _cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }
}
