import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/text_strings.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';

import 'home_banner_model.dart';
import 'package:project_micah/ui/widgets/common/custom_form_field/custom_form_field.dart';

class HomeBanner extends StackedView<HomeBannerModel> {
  const HomeBanner({super.key});

  @override
  Widget builder(
    BuildContext context,
    HomeBannerModel viewModel,
    Widget? child,
  ) {
    final isDesktop = UIHelpers.isDesktop(context);

    final content = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage('assets/images/overlay.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Decorative image
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset(
                'assets/images/banner_decoration.png',
                fit: BoxFit.fitHeight,
                height: double.infinity,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    TTexts.findMotorcyclePartsTitle,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  UIHelpers.verticalSpace32,

                  // Search form
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: UIHelpers.contentWidth(context) * 0.8,
                    ),
                    child: UIHelpers.isDesktop(context)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Motorcycle dropdown
                              Expanded(
                                flex: 2,
                                child: CustomFormField(
                                  label: TTexts.motorcycleLabel,
                                  formType: FormType.dropdown,
                                  height: 58,
                                  dropdownItems: viewModel.motorcycleItems
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  dropdownValue: viewModel.selectedMotorcycle,
                                  onDropdownChanged: (val) =>
                                      viewModel.setMotorcycle(val as String?),
                                ),
                              ),

                              // Category dropdown
                              Expanded(
                                flex: 2,
                                child: CustomFormField(
                                  label: TTexts.categoryLabel,
                                  formType: FormType.dropdown,
                                  height: 58,
                                  dropdownItems: viewModel.categoryItems
                                      .map((e) => DropdownMenuItem(
                                          value: e, child: Text(e)))
                                      .toList(),
                                  dropdownValue: viewModel.selectedCategory,
                                  onDropdownChanged: (val) =>
                                      viewModel.setCategory(val as String?),
                                ),
                              ),

                              // Part number text field
                              Expanded(
                                flex: 3,
                                child: CustomFormField(
                                  label: TTexts.partNumberLabel,
                                  formType: FormType.text,
                                  height: 58,
                                  controller: viewModel.partNumberController,
                                  hintText: TTexts.partNumberHint,
                                ),
                              ),

                              // Search button
                              SizedBox(
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      viewModel.navigateToSearchView(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                  ),
                                  child: const Text(TTexts.searchPartsButton),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              CustomFormField(
                                label: TTexts.motorcycleLabel,
                                formType: FormType.dropdown,
                                height: 58,
                                dropdownItems: viewModel.motorcycleItems
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
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
                                    .map((e) => DropdownMenuItem(
                                        value: e, child: Text(e)))
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
                                  onPressed: () =>
                                      viewModel.navigateToSearchView(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                  ),
                                  child: const Text(TTexts.searchPartsButton),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return isDesktop
        ? AspectRatio(
            aspectRatio: 1.91 / 0.7,
            child: content,
          )
        : content;
  }

  @override
  HomeBannerModel viewModelBuilder(BuildContext context) => HomeBannerModel();
}
