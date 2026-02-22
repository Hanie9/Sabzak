class Plant {
  late int? plantId;
  late int price;
  late String size;
  late int humidity;
  late String temperature;
  late String category;
  late String plantName;
  bool isFavorated = false; 
  late String? description;

  Plant({
    this.plantId,
    required this.price,
    required this.category,
    required this.plantName,
    required this.size,
    required this.humidity,
    required this.temperature,
    required this.isFavorated,
    required this.description,
  });


  Plant.fromJson(Map<String,dynamic> json){
    plantId = _toInt(json['plantid']);
    plantName = json['plantname'] ?? '';
    description = json['description'];
    price = _toInt(json['price']) ?? 0;
    size = json['size'] ?? '';
    humidity = _toInt(json['humidity']) ?? 0;
    temperature = json['temperature'] ?? '';
    category = json['category'] ?? '';
    isFavorated = json['isfavorite'] ?? false;
  }

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['plantName'] = plantName;
    data['description'] = description;
    data['price'] = price;
    data['size'] = size;
    data['humidity'] = humidity;
    data['temperature'] = temperature;
    data['category'] = category;
    data['isfavorite'] = isFavorated;

    return data;
  }
}

class Category {
  final String name;

  Category({required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
    );
  }
}
