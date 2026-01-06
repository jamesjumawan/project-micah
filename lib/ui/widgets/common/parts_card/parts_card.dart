import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';

import 'parts_card_model.dart';

class PartsCard extends StackedView<PartsCardModel> {
  final String imageUrl;
  final String partNo;
  final String partsName;
  final VoidCallback? onTap;

  const PartsCard({
    super.key,
    required this.imageUrl,
    required this.partNo,
    required this.partsName,
    this.onTap,
  });

  @override
  Widget builder(
    BuildContext context,
    PartsCardModel viewModel,
    Widget? child,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: imageUrl.startsWith('http')
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: AppColors.textHint,
                            ),
                          )
                        : Image.asset(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.broken_image,
                              size: 60,
                              color: AppColors.textHint,
                            ),
                          ),
                  ),
                ),
              ),

              UIHelpers.verticalSpace12,

              // Content area
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PART NO: $partNo',
                          style:
                              Theme.of(context).textTheme.bodySmall.bold.black),
                      UIHelpers.verticalSpace16,
                      Text(partsName,
                          style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  PartsCardModel viewModelBuilder(
    BuildContext context,
  ) =>
      PartsCardModel();
}
