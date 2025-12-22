import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacked/stacked.dart';

import 'categories_view.desktop.dart';
import 'categories_view.tablet.dart';
import 'categories_view.mobile.dart';
import 'categories_viewmodel.dart';

class CategoriesView extends StackedView<CategoriesViewModel> {
  final String? selectedCategory;

  const CategoriesView({super.key, this.selectedCategory});

  @override
  Widget builder(
    BuildContext context,
    CategoriesViewModel viewModel,
    Widget? child,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.categoryParts.isEmpty) {
        viewModel.fetchCategoryParts(viewModel.selectedCategory);
      }
    });
    return ScreenTypeLayout.builder(
      mobile: (_) => const CategoriesViewMobile(),
      tablet: (_) => const CategoriesViewTablet(),
      desktop: (_) => const CategoriesViewDesktop(),
    );
  }

  @override
  CategoriesViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      CategoriesViewModel(selectedCategory: selectedCategory);
}
