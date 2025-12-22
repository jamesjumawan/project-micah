import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: UIHelpers.spacing24,
        vertical: UIHelpers.spacing20,
      ),
      color: AppColors.surface,
      child: Center(
        child: Text(
          '© ${DateTime.now().year} Project Micah. All rights reserved.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
    );
  }
}
