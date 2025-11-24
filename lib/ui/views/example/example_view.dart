import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'example_view.desktop.dart';
import 'example_view.mobile.dart';
import 'example_view.tablet.dart';
import 'example_viewmodel.dart';

class ExampleView extends StackedView<ExampleViewModel> {
  const ExampleView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ExampleViewModel viewModel,
    Widget? child,
  ) {
    return ScreenTypeLayout.builder(
      mobile: (_) => const ExampleViewMobile(),
      tablet: (_) => const ExampleViewTablet(),
      desktop: (_) => const ExampleViewDesktop(),
    );
  }

  @override
  ExampleViewModel viewModelBuilder(BuildContext context) => ExampleViewModel();
}
