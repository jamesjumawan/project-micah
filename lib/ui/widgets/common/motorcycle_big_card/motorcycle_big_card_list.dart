import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/widgets/common/motorcycle_big_card/motorcycle_big_card.dart';

class MotorcycleBigCardList extends StatelessWidget {
  final List<MotorcycleBigCard> items;
  final EdgeInsetsGeometry padding;
  final int maxDesktopColumns;
  final double desktopChildAspectRatio;

  const MotorcycleBigCardList({
    super.key,
    required this.items,
    this.padding = const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    this.maxDesktopColumns = 3,
    this.desktopChildAspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    if (UIHelpers.isDesktop(context)) {
      final crossCount = min(items.length, maxDesktopColumns);
      return Padding(
        padding: padding,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossCount,
            mainAxisSpacing: UIHelpers.spacing24,
            crossAxisSpacing: UIHelpers.spacing24,
            childAspectRatio: desktopChildAspectRatio,
          ),
          itemBuilder: (context, index) => items[index],
        ),
      );
    }

    // Tablet / Mobile: vertical, single-column list
    return Padding(
      padding: padding,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            items[i],
            if (i != items.length - 1) SizedBox(height: UIHelpers.spacing24),
          ]
        ],
      ),
    );
  }
}
