import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/screen_types/index.dart';
import 'package:project_micah/ui/widgets/common/categories_card/categories_list.dart';
import 'package:project_micah/ui/widgets/common/home_banner/home_banner.dart';
import 'package:project_micah/ui/widgets/common/motorcycle_big_card/motorcycle_big_card_list.dart';
import 'package:stacked/stacked.dart';

import 'home_viewmodel.dart';

class HomeViewDesktop extends ViewModelWidget<HomeViewModel> {
  const HomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context, HomeViewModel viewModel) {
    return DesktopView(
      padding: EdgeInsets.zero,
      body: Column(
        children: [
          HomeBanner(),
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: Column(
              children: [
                CategoriesList(categories: viewModel.categories),
                UIHelpers.verticalSpace24,
                MotorcycleBigCardList(items: viewModel.featuredMotorcycles),
              ],
            ),
          )
        ],
      ),
    );
  }
}
