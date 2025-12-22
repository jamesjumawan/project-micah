import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_micah/app/app.bottomsheets.dart';
import 'package:project_micah/app/app.dialogs.dart';
import 'package:project_micah/app/app.locator.dart';
import 'package:project_micah/app/app.router.dart';
import 'package:project_micah/ui/utils/constants/text_strings.dart';
import 'package:project_micah/ui/utils/device/web_material_scroll.dart';
import 'package:project_micah/ui/utils/theme/theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_strategy/url_strategy.dart';

class FlavorType {
  static const String dev = 'dev';
  static const String prod = 'prod';
  static const String stg = 'stg';
}

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  required String environment,
  required String appTitle,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  await setupLocator(stackedRouter: stackedRouter);
  setupDialogUi();
  setupBottomSheetUi();
  runApp(await builder());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveApp(
      builder: (_) => MaterialApp.router(
        title: TTexts.appName,
        themeMode: ThemeMode.light,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        scrollBehavior: MyCustomScrollBehavior(),
        debugShowCheckedModeBanner: false,
        routerDelegate: stackedRouter.delegate(),
        routeInformationParser: stackedRouter.defaultRouteParser(),
      ),
    ).animate().fadeIn(
          delay: const Duration(milliseconds: 50),
          duration: const Duration(milliseconds: 400),
        );
  }
}
