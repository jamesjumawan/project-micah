import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {
  String get title => 'Home View';

  int _counter = 0;
  int get counter => _counter;

  void incrementCounter() {
    _counter++;
    rebuildUi();
  }
}
