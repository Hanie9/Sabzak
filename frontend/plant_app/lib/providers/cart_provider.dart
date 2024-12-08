import 'package:flutter/material.dart';
import 'package:plant_app/models/cart_model.dart';
import 'package:plant_app/models/plant.dart';

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  void addItem(Plant plant) {
    if (_items.containsKey(plant.plantId)) {
      _items[plant.plantId]!.quantity += 1;
    } else {
      _items[plant.plantId] = CartItem(plant: plant);
    }
    notifyListeners();
  }

  void removeItem(int plantId) {
    _items.remove(plantId);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.plant.price * cartItem.quantity;
    });
    return total;
  }
}
