class Rating {
  final int? plantId;
  final double rating;
  final String? reaction;
  final String? username;

  Rating({
    this.plantId,
    required this.rating,
    this.username,
    this.reaction,
  });

  Map<String, dynamic> toJson() {
    return {
      'plantid': plantId,
      'rating': rating,
      'reaction': reaction
    };
  }

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      rating: json['rating'],
      reaction: json['reaction'],
      username: json['username'],
    );
  }
}
