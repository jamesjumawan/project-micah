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

  List<Map<String, String>> get searchResults => [
        {
          'imageUrl': 'images/sample_parts/related-parts-1.png',
          'partNo': '001',
          'partsName': 'Clutch Assembly',
        },
        {
          'imageUrl': 'images/sample_parts/related-parts-2.png',
          'partNo': '002',
          'partsName': 'Brake Disc',
        },
        {
          'imageUrl': 'images/sample_parts/related-parts-3.png',
          'partNo': '003',
          'partsName': 'Gear Shift',
        },
        {
          'imageUrl': 'images/sample_parts/related-parts-4.png',
          'partNo': '004',
          'partsName': 'Oil Filter',
        },
        {
          'imageUrl': 'images/sample_parts/related-parts-5.png',
          'partNo': '005',
          'partsName': 'Chain Sprocket',
        },
        {
          'imageUrl': 'images/sample_parts/related-parts-6.png',
          'partNo': '006',
          'partsName': 'Suspension Spring',
        },
        {
          'imageUrl': 'images/sample_parts/clutch-parts-01.png',
          'partNo': '007',
          'partsName': 'Clutch Plate',
        },
        {
          'imageUrl': 'images/sample_parts/clutch-parts-02.png',
          'partNo': '008',
          'partsName': 'Clutch Spring',
        },
        {
          'imageUrl': 'images/sample_parts/clutch-parts-03.png',
          'partNo': '009',
          'partsName': 'Clutch Hub',
        },
        {
          'imageUrl': 'images/sample_parts/1-selected-parts-01.png',
          'partNo': '010',
          'partsName': 'Engine Gasket',
        },
        {
          'imageUrl': 'images/sample_parts/1-selected-parts-02.png',
          'partNo': '011',
          'partsName': 'Air Filter',
        },
        {
          'imageUrl': 'images/sample_parts/1-selected-parts-03.png',
          'partNo': '012',
          'partsName': 'Spark Plug',
        },
      ];

  @override
  void dispose() {
    partNumberController.dispose();
    super.dispose();
  }
}
