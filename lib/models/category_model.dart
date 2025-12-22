class CategoryModel {
  final String name;
  final String imageUrl;

  CategoryModel({
    required this.name,
    required this.imageUrl,
  });

  // Convert to Map for easy serialization
  Map<String, String> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  // Create from Map
  factory CategoryModel.fromMap(Map<String, String> map) {
    return CategoryModel(
      name: map['name']!,
      imageUrl: map['imageUrl']!,
    );
  }
}
