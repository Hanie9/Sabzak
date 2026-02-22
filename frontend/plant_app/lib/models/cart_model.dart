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
      userId: json['userid']?.toString() ?? '',
      plantId: _toInt(json['plantid']) ?? 0,
      quantity: _toInt(json['quantity']) ?? 1,
      price: _toNum(json['price']),
      plantName: json['plantname']?.toString() ?? '',
    );
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static int _toNum(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}