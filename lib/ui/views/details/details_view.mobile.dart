import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/screen_types/mobile_view.dart';
import 'package:stacked/stacked.dart';

import 'details_viewmodel.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class DetailsViewMobile extends ViewModelWidget<DetailsViewModel> {
  const DetailsViewMobile({super.key});

  @override
  Widget build(BuildContext context, DetailsViewModel viewModel) {
    return MobileView(
      body: Padding(
        padding: const EdgeInsets.all(UIHelpers.spacing24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.phone_android,
                size: 80,
                color: AppColors.error,
              ),
              UIHelpers.verticalSpace24,
              Text(
                'Mobile view not supported',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              UIHelpers.verticalSpace16,
              Text(
                '3D viewing is not supported on mobile devices.\nPlease use a tablet or desktop for the best experience.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
