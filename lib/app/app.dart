import 'package:project_micah/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:project_micah/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:project_micah/ui/views/example/example_view.dart';
import 'package:project_micah/ui/views/home/home_view.dart';
import 'package:project_micah/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

@StackedApp(
  routes: [
    CustomRoute(page: StartupView, initial: true),
    CustomRoute(page: HomeView),
    CustomRoute(page: ExampleView),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
  ],
  bottomsheets: [StackedBottomsheet(classType: NoticeSheet)],
  dialogs: [StackedDialog(classType: InfoAlertDialog)],
)
class App {}
