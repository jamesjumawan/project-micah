import 'package:flutter/material.dart';
import 'package:project_micah/ui/widgets/common/breadcrumbs/breadcrumbs.dart';
// app colors import removed (not needed here)
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/screen_types/desktop_view.dart';
import 'package:project_micah/ui/widgets/common/categories_card/categories_card.dart';
import 'package:project_micah/ui/widgets/common/parts_card/parts_card.dart';
import 'package:stacked/stacked.dart';

import 'categories_viewmodel.dart';

class CategoriesViewTablet extends ViewModelWidget<CategoriesViewModel> {
  const CategoriesViewTablet({super.key});

  @override
  Widget build(BuildContext context, CategoriesViewModel viewModel) {
    return DesktopView(
      breadcrumbs: const Breadcrumbs(items: ['Home', 'Categories']),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categories section
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: Text(
              'CATEGORIES',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
            ),
          ),

          UIHelpers.verticalSpace24,

          // Categories grid
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: UIHelpers.spacing16,
                crossAxisSpacing: UIHelpers.spacing16,
                childAspectRatio: 0.75,
              ),
              itemCount: viewModel.categories.length,
              itemBuilder: (context, index) {
                final category = viewModel.categories[index];
                final isSelected = category.name == viewModel.selectedCategory;
                return CategoriesCard(
                  title: category.name,
                  imagePath: category.imageUrl,
                  isSelected: isSelected,
                  onTap: () {
                    viewModel.selectCategory(category.name);
                  },
                );
              },
            ),
          ),

          UIHelpers.verticalSpace32,

          // Selected category title
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: Text(
              viewModel.selectedCategory.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
            ),
          ),

          UIHelpers.verticalSpace24,

          // Category parts grid (or loading indicator while fetching)
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: viewModel.isBusy
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: UIHelpers.spacing16,
                      crossAxisSpacing: UIHelpers.spacing16,
                      childAspectRatio: 2 / 3,
                    ),
                    itemCount: viewModel.categoryParts.length,
                    itemBuilder: (context, index) {
                      final part = viewModel.categoryParts[index];
                      return PartsCard(
                        imageUrl: part['imageUrl']!,
                        partNo: part['partNo']!,
                        partsName: part['partsName']!,
                        onTap: () {
                          // Navigate to details
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
