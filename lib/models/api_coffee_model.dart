class ApiCoffee {
  final int id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String image;
  final bool isHot;

  ApiCoffee({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.image,
    required this.isHot,
  });

  factory ApiCoffee.fromJson(Map<String, dynamic> json, {required bool isHot}) {
    return ApiCoffee(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      ingredients: json['ingredients'] == null
          ? []
          : List<String>.from(json['ingredients']),
      image: json['image'] ?? '',
      isHot: isHot,
    );
  }
}