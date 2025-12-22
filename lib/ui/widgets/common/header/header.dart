import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/text_strings.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:stacked/stacked.dart';

import 'header_model.dart';

class Header extends StackedView<HeaderModel> {
  final String? title;

  const Header({
    super.key,
    this.title,
  });

  @override
  Widget builder(
    BuildContext context,
    HeaderModel viewModel,
    Widget? child,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: UIHelpers.spacing24,
        vertical: UIHelpers.spacing16,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left aligned logo
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: UIHelpers.iconMedium,
                  fit: BoxFit.contain,
                ),
                UIHelpers.horizontalSpace8,
                Text(
                  TTexts.logoText,
                  style: Theme.of(context).textTheme.titleLarge?.primary,
                ),
              ],
            ),
          ),

          if (title != null)
            Align(
              alignment: Alignment.center,
              child: Text(
                title!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  HeaderModel viewModelBuilder(
    BuildContext context,
  ) =>
      HeaderModel();
}
