class CategoryModel {
  final String name;
  final String imageUrl;
  final bool has3DModel;

  CategoryModel({
    required this.name,
    required this.imageUrl,
    this.has3DModel = false,
  });

  // Convert to Map for easy serialization
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'has3DModel': has3DModel,
    };
  }

  // Create from Map
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      name: map['name']!,
      imageUrl: map['imageUrl']!,
      has3DModel: map['has3DModel'] ?? false,
    );
  }
}
