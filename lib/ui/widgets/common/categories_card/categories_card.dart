import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:stacked/stacked.dart';

import 'categories_card_model.dart';

class CategoriesCard extends StackedView<CategoriesCardModel> {
  final String title;
  final String? imagePath;
  final VoidCallback? onTap;
  final bool isSelected;
  final String? categoryName;

  const CategoriesCard({
    super.key,
    required this.title,
    this.imagePath,
    this.onTap,
    this.isSelected = false,
    this.categoryName,
  });

  @override
  Widget builder(
    BuildContext context,
    CategoriesCardModel viewModel,
    Widget? child,
  ) {
    Widget imageWidget;
    if (imagePath != null && imagePath!.isNotEmpty) {
      if (imagePath!.startsWith('assets/')) {
        imageWidget = Image.asset(
          imagePath!,
          fit: BoxFit.contain,
        );
      } else {
        imageWidget = Image.network(
          imagePath!,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
        );
      }
    } else {
      imageWidget = Icon(
        Icons.image,
        size: UIHelpers.iconXLarge,
        color: AppColors.textHint,
      );
    }

    return InkWell(
      onTap: onTap ??
          (categoryName != null
              ? () => viewModel.navigateToCategory(categoryName!)
              : null),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // image area
          Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withAlpha(20)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Center(child: imageWidget),
            ),
          ),

          // title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  CategoriesCardModel viewModelBuilder(
    BuildContext context,
  ) =>
      CategoriesCardModel();
}
