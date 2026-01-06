import 'package:stacked/stacked.dart';

class MotorcycleShowcaseModel extends BaseViewModel {
  String? _hoveredMotorcycle;
  String? get hoveredMotorcycle => _hoveredMotorcycle;

  void setHoveredMotorcycle(String? name) {
    _hoveredMotorcycle = name;
    notifyListeners();
  }
}
