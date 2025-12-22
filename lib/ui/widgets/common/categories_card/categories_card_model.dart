import 'package:project_micah/app/app.locator.dart';
import 'package:project_micah/app/app.router.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CategoriesCardModel extends BaseViewModel {
  final _routerService = locator<RouterService>();

  void navigateToCategory(String categoryName) {
    _routerService.navigateToCategoriesView(
      selectedCategory: categoryName,
    );
  }
}
