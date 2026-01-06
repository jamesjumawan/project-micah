import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:project_micah/models/category_model.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

import 'motorcycle_showcase_model.dart';

class MotorcycleShowcase extends StackedView<MotorcycleShowcaseModel> {
  final List<CategoryModel> motorcycles;
  final String? selectedMotorcycle;
  final Function(String) onMotorcycleSelected;
  final bool isCollapsed;

  const MotorcycleShowcase({
    super.key,
    required this.motorcycles,
    this.selectedMotorcycle,
    required this.onMotorcycleSelected,
    this.isCollapsed = false,
  });

  @override
  Widget builder(
    BuildContext context,
    MotorcycleShowcaseModel viewModel,
    Widget? child,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 200,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: UIHelpers.spacing8),
              itemCount: motorcycles.length,
              itemBuilder: (context, index) {
                final motorcycle = motorcycles[index];
                final isSelected = motorcycle.name == selectedMotorcycle;

                return _MotorcycleCard(
                  motorcycle: motorcycle,
                  isSelected: isSelected,
                  isCollapsed: isCollapsed,
                  onTap: () => onMotorcycleSelected(motorcycle.name),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  MotorcycleShowcaseModel viewModelBuilder(
    BuildContext context,
  ) =>
      MotorcycleShowcaseModel();
}

class _MotorcycleCard extends StatefulWidget {
  final CategoryModel motorcycle;
  final bool isSelected;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _MotorcycleCard({
    required this.motorcycle,
    required this.isSelected,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  State<_MotorcycleCard> createState() => _MotorcycleCardState();
}

class _MotorcycleCardState extends State<_MotorcycleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.isCollapsed ? widget.motorcycle.name : '',
      child: GestureDetector(
        onTap: widget.onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: UIHelpers.spacing8,
              vertical: UIHelpers.spacing4,
            ),
            padding: const EdgeInsets.all(UIHelpers.spacing12),
            child: Column(
              children: [
                // Thumbnail with border (larger when expanded)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: widget.isCollapsed ? 40 : 100,
                  width: widget.isCollapsed ? 40 : 100,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(UIHelpers.radiusSmall),
                    border: Border.all(
                      color: widget.isSelected
                          ? AppColors.primary
                          : _isHovered
                              ? AppColors.border
                              : Colors.transparent,
                      width: widget.isSelected ? 3 : 2,
                    ),
                    image: DecorationImage(
                      image: widget.motorcycle.imageUrl.startsWith('http')
                          ? NetworkImage(widget.motorcycle.imageUrl)
                          : AssetImage(widget.motorcycle.imageUrl)
                              as ImageProvider,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                if (!widget.isCollapsed) ...[
                  UIHelpers.verticalSpace8,
                  Text(
                    widget.motorcycle.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: widget.isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: widget.isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (!widget.motorcycle.has3DModel) ...[
                    UIHelpers.verticalSpace4,
                    Text(
                      '3D Model Coming Soon!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: AppColors.warning,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
