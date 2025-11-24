import 'package:project_micah/ui/utils/constants/text_strings.dart';
import 'package:project_micah/bootstrap.dart';

Future<void> main() async => await bootstrap(
  () => const MainApp(),
  environment: FlavorType.prod,
  appTitle: '${TTexts.appName} (Prod)',
);
