import 'package:project_micah/app/app.locator.dart';
import 'package:project_micah/app/app.router.dart';
import 'package:project_micah/models/category_model.dart';
import 'package:project_micah/ui/widgets/common/motorcycle_big_card/motorcycle_big_card.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  //TODO: pass this from the view
  final RouterService _routerService = locator<RouterService>();

  void navigateToSearchView() {
    _routerService.navigateToSearchView();
  }

  List<CategoryModel> get categories => [
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
  List<MotorcycleBigCard> get featuredMotorcycles => [
        MotorcycleBigCard(
          title: 'BLT150',
          imagePath: 'images/sample_mcs/home-select-mc-1.png',
          onTap: () => _routerService.navigateToDetailsView(),
        ),
        MotorcycleBigCard(
          title: 'Hero 2024',
          imagePath: 'images/sample_mcs/home-select-mc-2.png',
          onTap: () => _routerService.navigateToDetailsView(),
        ),
        MotorcycleBigCard(
          title: 'King Pro',
          imagePath: 'images/sample_mcs/home-select-mc-3.png',
          onTap: () => _routerService.navigateToDetailsView(),
        ),
      ];
}
