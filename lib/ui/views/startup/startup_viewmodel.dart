import 'package:stacked/stacked.dart';
import 'package:project_micah/app/app.router.dart';

class StartupViewModel extends BaseViewModel {
  Future runStartupLogic() async {
    await Future.delayed(const Duration(seconds: 2));
    stackedRouter.replace(HomeViewRoute());
  }
}
