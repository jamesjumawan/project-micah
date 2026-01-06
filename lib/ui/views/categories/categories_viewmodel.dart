import 'package:project_micah/models/category_model.dart';
import 'package:stacked/stacked.dart';

class CategoriesViewModel extends BaseViewModel {
  CategoriesViewModel({String? selectedCategory}) {
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      this.selectedCategory = selectedCategory;
    }
  }

  // Categories data
  final List<CategoryModel> categories = [
    CategoryModel(
      name: 'Brake',
      imageUrl: 'images/sample_parts/home-categories-1.png',
    ),
    CategoryModel(
      name: 'Clutch',
      imageUrl: 'images/sample_parts/home-categories-2.png',
    ),
    CategoryModel(
      name: 'Gearshift',
      imageUrl: 'images/sample_parts/home-categories-3.png',
    ),
    CategoryModel(
      name: 'Magneto',
      imageUrl: 'images/sample_parts/home-categories-4.png',
    ),
    CategoryModel(
      name: 'Oil Pump',
      imageUrl: 'images/sample_parts/home-categories-5.png',
    ),
    CategoryModel(
      name: 'Transmission Device',
      imageUrl: 'images/sample_parts/home-categories-6.png',
    ),
  ];

  // Selected category parts data (mutable)
  List<Map<String, String>> categoryParts = [];

  String selectedCategory = 'Clutch';
  Future<void> fetchCategoryParts(String category) async {
    setBusy(true);

    //TODO: call api to fetch parts for the category here
    await Future.delayed(const Duration(milliseconds: 700));

    //mock
    final partImages = [
      'images/sample_parts/related-parts-1.png',
      'images/sample_parts/related-parts-2.png',
      'images/sample_parts/related-parts-3.png',
      'images/sample_parts/related-parts-4.png',
      'images/sample_parts/related-parts-5.png',
      'images/sample_parts/related-parts-6.png',
    ];

    categoryParts = List.generate(6, (index) {
      return {
        'imageUrl': partImages[index],
        'partNo': (index + 1).toString().padLeft(3, '0'),
        'partsName': '$category Part ${index + 1}',
      };
    });

    setBusy(false);
    notifyListeners();
  }

  /// Selects a category and triggers fetching its parts.
  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
    fetchCategoryParts(category);
  }
}
