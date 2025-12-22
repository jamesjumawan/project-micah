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
      imageUrl: 'https://via.placeholder.com/200',
    ),
    CategoryModel(
      name: 'Clutch',
      imageUrl: 'https://via.placeholder.com/200',
    ),
    CategoryModel(
      name: 'Gearshift',
      imageUrl: 'https://via.placeholder.com/200',
    ),
    CategoryModel(
      name: 'Magneto',
      imageUrl: 'https://via.placeholder.com/200',
    ),
    CategoryModel(
      name: 'Oil Pump',
      imageUrl: 'https://via.placeholder.com/200',
    ),
    CategoryModel(
      name: 'Transmission Device',
      imageUrl: 'https://via.placeholder.com/200',
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
    categoryParts = List.generate(6, (index) {
      return {
        'imageUrl': 'https://via.placeholder.com/200',
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
