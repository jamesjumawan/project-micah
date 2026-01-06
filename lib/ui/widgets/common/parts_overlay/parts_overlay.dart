import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/widgets/common/table/table.dart';

class PartsOverlay extends StatelessWidget {
  final List<String> engineParts;
  final List<String> accessoryParts;
  final String? selectedPart;
  final Function(String) onPartSelected;
  final VoidCallback onClose;

  const PartsOverlay({
    super.key,
    required this.engineParts,
    required this.accessoryParts,
    this.selectedPart,
    required this.onPartSelected,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: onClose,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent closing when clicking on content
            child: Container(
              width: UIHelpers.screenWidth(context) * 0.8,
              height: UIHelpers.screenHeight(context) * 0.8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(UIHelpers.radiusLarge),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(UIHelpers.spacing24),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ALL PARTS',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: onClose,
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(UIHelpers.spacing24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Engine specifications
                          Expanded(
                            child: SimpleTable(
                              title: const Text('ENGINE'),
                              items: engineParts
                                  .map((part) => _PartItem(
                                        label: part,
                                        isSelected: part == selectedPart,
                                        onTap: () {
                                          onPartSelected(part);
                                          onClose();
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                          UIHelpers.horizontalSpace16,
                          // Accessories specifications
                          Expanded(
                            child: SimpleTable(
                              title: const Text('ACCESSORIES'),
                              items: accessoryParts
                                  .map((part) => _PartItem(
                                        label: part,
                                        isSelected: part == selectedPart,
                                        onTap: () {
                                          onPartSelected(part);
                                          onClose();
                                        },
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PartItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PartItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_PartItem> createState() => _PartItemState();
}

class _PartItemState extends State<_PartItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        //TODO: Fix gesture detector conflict
        //onTap: widget.onTap,
        child: Container(
          color: widget.isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : _isHovered
                  ? AppColors.surface
                  : Colors.transparent,
          child: Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary,
                  fontWeight: widget.isSelected || _isHovered
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}
