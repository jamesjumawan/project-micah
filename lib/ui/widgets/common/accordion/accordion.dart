import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'package:project_micah/ui/utils/constants/app_colors.dart';

import 'accordion_model.dart';
import 'accordion_card.dart';

class Accordion extends StackedView<AccordionModel> {
  final List<AccordionCard> items;

  const Accordion({super.key, required this.items});

  @override
  Widget builder(
    BuildContext context,
    AccordionModel viewModel,
    Widget? child,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      ),
    );
  }

  @override
  AccordionModel viewModelBuilder(BuildContext context) => AccordionModel();
}
