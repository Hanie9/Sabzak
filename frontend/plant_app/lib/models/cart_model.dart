import 'package:plant_app/models/plant.dart';

class CartItem {
  final Plant plant;
  int quantity;

  CartItem({required this.plant, this.quantity = 1});
}