import 'package:flutter/material.dart';
import 'package:project_micah/app/app.locator.dart';
import 'package:project_micah/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

//TODO: use formview
class HomeBannerModel extends BaseViewModel {
  //TODO: pass this from the view
  final RouterService _routerService = locator<RouterService>();
  HomeBannerModel() {
    partNumberController = TextEditingController();
  }

  late TextEditingController partNumberController;

  String selectedMotorcycle = 'All';
  String selectedCategory = 'All';

  // Dropdown items
  List<String> get motorcycleItems => ['All', 'Model A', 'Model B'];
  List<String> get categoryItems => ['All', 'Engine', 'Brakes'];

  void setMotorcycle(String? val) {
    selectedMotorcycle = val ?? 'All';
    notifyListeners();
  }

  void navigateToSearchView() {
    _routerService.navigateToSearchView();
  }

  void setCategory(String? val) {
    selectedCategory = val ?? 'All';
    notifyListeners();
  }

  @override
  void dispose() {
    partNumberController.dispose();
    super.dispose();
  }
}
