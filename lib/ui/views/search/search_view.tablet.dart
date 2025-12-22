import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/text_strings.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/screen_types/desktop_view.dart';
import 'package:project_micah/ui/widgets/common/breadcrumbs/breadcrumbs.dart';
import 'package:project_micah/ui/widgets/common/custom_form_field/custom_form_field.dart';
import 'package:project_micah/ui/widgets/common/parts_card/parts_card.dart';
import 'package:stacked/stacked.dart';
import 'search_viewmodel.dart';

class SearchViewTablet extends ViewModelWidget<SearchViewModel> {
  const SearchViewTablet({super.key});

  @override
  Widget build(BuildContext context, SearchViewModel viewModel) {
    return DesktopView(
      breadcrumbs: const Breadcrumbs(items: ['Home', 'Search']),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // breadcrumbs provided by screen type

          // Search section title
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: Text(
              'SEARCH FOR PARTS',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
            ),
          ),

          UIHelpers.verticalSpace24,

          // Search form
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: Column(
              children: [
                CustomFormField(
                  label: TTexts.motorcycleLabel,
                  formType: FormType.dropdown,
                  height: 58,
                  dropdownItems: viewModel.motorcycleItems
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  dropdownValue: viewModel.selectedMotorcycle,
                  onDropdownChanged: (val) =>
                      viewModel.setMotorcycle(val as String?),
                ),
                UIHelpers.verticalSpace12,
                CustomFormField(
                  label: TTexts.categoryLabel,
                  formType: FormType.dropdown,
                  height: 58,
                  dropdownItems: viewModel.categoryItems
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  dropdownValue: viewModel.selectedCategory,
                  onDropdownChanged: (val) =>
                      viewModel.setCategory(val as String?),
                ),
                UIHelpers.verticalSpace12,
                CustomFormField(
                  label: TTexts.partNumberLabel,
                  formType: FormType.text,
                  height: 58,
                  controller: viewModel.partNumberController,
                  hintText: TTexts.partNumberHint,
                ),
                UIHelpers.verticalSpace12,
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(TTexts.searchPartsButton),
                  ),
                ),
              ],
            ),
          ),

          UIHelpers.verticalSpace32,

          // Results count
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: Text(
              'RESULTS (${viewModel.resultsCount})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
            ),
          ),

          UIHelpers.verticalSpace24,

          // Results grid
          Padding(
            padding: UIHelpers.pagePadding(context),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: UIHelpers.spacing16,
                crossAxisSpacing: UIHelpers.spacing16,
                childAspectRatio: 2 / 3,
              ),
              itemCount: viewModel.searchResults.length,
              itemBuilder: (context, index) {
                final result = viewModel.searchResults[index];
                return PartsCard(
                  imageUrl: result['imageUrl']!,
                  partNo: result['partNo']!,
                  partsName: result['partsName']!,
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
