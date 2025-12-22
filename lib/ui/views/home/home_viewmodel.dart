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
        CategoryModel(
          name: 'Suspension',
          imageUrl: 'https://via.placeholder.com/200',
        ),
      ];
  List<MotorcycleBigCard> get featuredMotorcycles => [
        MotorcycleBigCard(
          title: '2024 Yamaha YZF-R1',
          imagePath:
              'https://images.piaggio.com/vespa/vehicles/nvh6000u03/nvh6q1tu03/nvh6q1tu03-01-m.png',
          onTap: () => _routerService.navigateToDetailsView(),
        ),
        MotorcycleBigCard(
          title: '2024 Ducati Panigale V4',
          // imagePath:
          //     'https://images.ducati.com/ducati/vehicles/nvh6000u03/nvh6q1tu03/nvh6q1tu03-01-m.png',
        ),
        MotorcycleBigCard(
          title: '2024 Kawasaki Ninja H2',
          // imagePath:
          //     'https://images.kawasaki.com/vehicles/nvh6000u03/nvh6q1tu03/nvh6q1tu03-01-m.png',
        ),
        MotorcycleBigCard(
          title: '2024 BMW S1000RR',
          // imagePath:
          //     'https://images.bmw-m.com/vehicles/nvh6000u03/nvh6q1tu03/nvh6q1tu03-01-m.png',
        ),
        MotorcycleBigCard(
          title: '2024 Honda CBR1000RR-R',
          // imagePath:
          //     'https://images.honda.com/vehicles/nvh6000u03/nvh6q1tu03/nvh6q1tu03-01-m.png',
        ),
        MotorcycleBigCard(
          title: '2024 Suzuki GSX-R1000',
          // imagePath:
          //     'https://images.suzuki.com/vehicles/nvh6000u03/nvh6q1tu03/nvh6q1tu03-01-m.png',
        ),
      ];
}
