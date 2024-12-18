class CartItem {
  final String userId;
  final int plantId;
  int quantity;
  final int price;
  final String plantName;

  CartItem({
    required this.userId,
    required this.plantId,
    required this.quantity,
    required this.price,
    required this.plantName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      userId: json['userid'],
      plantId: json['plantid'],
      quantity: json['quantity'],
      price: json['price'],
      plantName: json['plantname'],
    );
  }
}