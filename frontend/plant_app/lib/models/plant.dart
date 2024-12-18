class Plant {
  late int? plantId;
  late int price;
  late String size;
  late double rating;
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
    category = json['category'];
    isFavorated = json['isfavorite'];
  }

  Map<String,dynamic> toJson(){
    final Map<String,dynamic> data = <String,dynamic>{};
    data['plantName'] = plantName;
    data['description'] = description;
    data['price'] = price;
    data['size'] = size;
    data['rating'] = rating;
    data['humidity'] = humidity;
    data['temperature'] = temperature;
    data['category'] = category;
    data['isfavorite'] = isFavorated;

    return data;
  }
}