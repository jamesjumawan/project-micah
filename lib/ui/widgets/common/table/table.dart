import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';

class SimpleTable extends StatelessWidget {
  final Widget title;
  final List<Widget> items;
  final Color? borderColor;

  const SimpleTable({
    super.key,
    required this.title,
    required this.items,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final bc = borderColor ?? AppColors.divider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header band
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: UIHelpers.spacing8,
            horizontal: UIHelpers.spacing8,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primary,
          ),
          child: DefaultTextStyle.merge(
            style: UIHelpers.applyTextStyle(
              null,
              color: AppColors.textWhite,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
            child: Center(child: title),
          ),
        ),

        // Body with outer border
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            border: Border.all(color: bc),
            borderRadius: BorderRadius.circular(UIHelpers.radiusSmall),
          ),
          clipBehavior: Clip.hardEdge,
          child: Column(
            children: List.generate(items.length, (i) {
              final isLast = i == items.length - 1;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: UIHelpers.spacing8,
                  vertical: UIHelpers.spacing8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                ),
                child: items[i],
              );
            }),
          ),
        ),
      ],
    );
  }
}
