import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class SearchViewModel extends BaseViewModel {
  SearchViewModel() {
    partNumberController = TextEditingController();
  }

  late TextEditingController partNumberController;

  String selectedMotorcycle = 'All';
  String selectedCategory = 'CLUTCH';

  // Dropdown items
  List<String> get motorcycleItems => ['All', 'Model A', 'Model B'];
  List<String> get categoryItems => ['All', 'CLUTCH', 'Engine', 'Brakes'];

  void setMotorcycle(String? val) {
    selectedMotorcycle = val ?? 'All';
    notifyListeners();
  }

  void setCategory(String? val) {
    selectedCategory = val ?? 'All';
    notifyListeners();
  }

  // Mock search results - replace with actual data
  int get resultsCount => 12;

  List<Map<String, String>> get searchResults => List.generate(
        12,
        (index) => {
          'imageUrl': 'assets/images/banner_decoration.png',
          'partNo': '001',
          'partsName': index == 1 ? 'Gear 01' : 'Gear name',
        },
      );

  @override
  void dispose() {
    partNumberController.dispose();
    super.dispose();
  }
}
