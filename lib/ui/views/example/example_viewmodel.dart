import 'package:stacked/stacked.dart';

class ExampleViewModel extends BaseViewModel {
  // Add your ViewModel logic here

  String get title => 'Example View';

  Future<void> initialize() async {
    setBusy(true);
    // Add initialization logic
    setBusy(false);
  }
}
