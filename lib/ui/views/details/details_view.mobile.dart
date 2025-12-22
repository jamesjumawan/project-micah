import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/screen_types/mobile_view.dart';
import 'package:project_micah/ui/widgets/common/breadcrumbs/breadcrumbs.dart';
import 'package:project_micah/ui/widgets/common/accordion/accordion.dart';
import 'package:project_micah/ui/widgets/common/accordion/accordion_card.dart';
import 'package:project_micah/ui/widgets/common/parts_description/parts_description.dart';
import 'package:project_micah/ui/widgets/common/table/table.dart';
import 'package:project_micah/ui/widgets/common/categories_card/categories_list.dart';
import 'package:stacked/stacked.dart';

import 'details_viewmodel.dart';
import 'package:project_micah/ui/widgets/common/three_d/three_d_viewer.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class DetailsViewMobile extends ViewModelWidget<DetailsViewModel> {
  const DetailsViewMobile({super.key});

  @override
  Widget build(BuildContext context, DetailsViewModel viewModel) {
    return MobileView(
      breadcrumbs: const Breadcrumbs(items: ['Home', '3D']),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INTERACTIVE 3D MOTORCYCLE VIEWER',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  UIHelpers.verticalSpace8,
                  Text(
                    'Zoom, rotate, and explore each part in full 3D detail.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),

            // Main content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 3D viewer card
                  Card(
                    clipBehavior: Clip.hardEdge,
                    elevation: 2,
                    child: Column(
                      children: [
                        // 3D Viewer with integrated toggle buttons
                        ThreeDViewer(
                          modelPaths: viewModel.currentModelPaths,
                          mtlPaths: viewModel.currentMtlPaths,
                          modelName: viewModel.isAssembleMode
                              ? '${viewModel.selectedMotorcycle} - Full Assembly'
                              : '${viewModel.selectedMotorcycle} - ${viewModel.selectedPart ?? "Parts View"}',
                          height: UIHelpers.screenHeight(context) * 0.4,
                          isAssembleMode: viewModel.isAssembleMode,
                          onToggleMode: (mode) => viewModel.toggleMode(mode),
                          onPartSelected: (modelPath) {
                            String? matchedKey;
                            viewModel.partsModels.forEach((k, v) {
                              if (v['obj'] == modelPath) matchedKey = k;
                            });
                            if (matchedKey != null)
                              viewModel.selectPart(matchedKey!);
                          },
                        ),
                        // Part label (shown when in disassemble mode)
                        if (!viewModel.isAssembleMode &&
                            viewModel.selectedPart != null)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            color: Colors.amber,
                            child: Text(
                              'PART\n${viewModel.partsLabel}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  UIHelpers.verticalSpace16,

                  // Motorcycle selector (categories list)
                  CategoriesList(
                    categories: viewModel.motorcycles,
                    padding: EdgeInsets.zero,
                    selectedCategory: viewModel.selectedMotorcycle,
                    onCategoryTap: (motorcycleName) =>
                        viewModel.selectMotorcycle(motorcycleName),
                  ),

                  UIHelpers.verticalSpace16,

                  // Loading indicator or accordion content
                  if (viewModel.isBusy)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    Accordion(
                      items: [
                        // Specifications accordion (open in assemble mode)
                        AccordionCard(
                          title: const Text('Specifications'),
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Engine specifications
                              SimpleTable(
                                title: const Text('ENGINE'),
                                items: viewModel.engineSpecs
                                    .map((spec) => Text(spec))
                                    .toList(),
                              ),
                              UIHelpers.verticalSpace16,
                              // Accessories specifications
                              SimpleTable(
                                title: const Text('ACCESSORIES'),
                                items: viewModel.accessoriesSpecs
                                    .map((spec) => Text(spec))
                                    .toList(),
                              ),
                            ],
                          ),
                          isOpen: viewModel.isAssembleMode,
                        ),
                        // Parts accordion (open in disassemble mode)
                        AccordionCard(
                          title: const Text('Parts'),
                          body: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PartsDescription(
                                label: viewModel.partsLabel,
                                imageUrl: viewModel.partsImageUrl,
                                partsName: viewModel.partsName,
                                sku: viewModel.partsSku,
                                category: viewModel.partsCategory,
                                description: viewModel.partsDescription,
                                partNo: viewModel.partsPartNo,
                                quantity: viewModel.partsQuantity,
                                groupNo: viewModel.partsGroupNo,
                              )
                            ],
                          ),
                          isOpen: !viewModel.isAssembleMode,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
