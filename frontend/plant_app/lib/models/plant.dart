class Plant {
  late int plantId;
  late int price;
  late String size;
  late double rating;
  late int humidity;
  late String temperature;
  late String category;
  late String plantName;
  late bool isFavorated;
  late String? description;

  Plant({
    required this.plantId,
    required this.price,
    required this.category,
    required this.plantName,
    required this.size,
    required this.rating,
    required this.humidity,
    required this.temperature,
    required this.isFavorated,
    required this.description,
  });


  Plant.fromJson(Map<String,dynamic> json){
    plantId = json['plantid'];
    plantName = json['plantname'];
    description = json['description'];
    price = json['price'];
    size = json['size'];
    rating = json['rating'];
    humidity = json['humidity'];
    temperature = json['temperature'];
    isFavorated = json['isfavorite'];
    category = json['category'];
  }
}