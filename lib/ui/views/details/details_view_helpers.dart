import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/views/details/details_viewmodel.dart';
import 'package:project_micah/ui/widgets/common/parts_hierarchy/parts_hierarchy_tree.dart';

class ToggleButton extends StatelessWidget {
  final bool isAssembleMode;
  final bool isEnabled;
  final VoidCallback onToggle;

  const ToggleButton({
    super.key,
    required this.isAssembleMode,
    this.isEnabled = true,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Switch(
          value: !isAssembleMode,
          onChanged: isEnabled ? (_) => onToggle() : null,
          activeThumbColor: AppColors.primary,
        ),
        UIHelpers.horizontalSpace4,
        Text(
          !isAssembleMode ? 'DISASSEMBLE' : 'ASSEMBLE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight:
                    !isAssembleMode ? FontWeight.bold : FontWeight.normal,
                color: !isAssembleMode
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

class ControlItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String action;

  const ControlItem({
    super.key,
    required this.icon,
    required this.label,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        UIHelpers.horizontalSpace4,
        Text(
          '$label: $action',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }
}

/// Shows the Phase 5 parts hierarchy in a dialog. Selecting a part closes
/// the dialog and shows its description in the right panel.
void showPartsHierarchyDialog(
    BuildContext context, DetailsViewModel viewModel) {
  final nav = Navigator.of(context);
  viewModel.openHierarchyDialog();
  showDialog(
    context: context,
    builder: (_) => Dialog(
      child: SizedBox(
        width: 480,
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: UIHelpers.spacing16,
                vertical: UIHelpers.spacing12,
              ),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Text(
                    'ALL PARTS',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: nav.pop,
                    child: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
            // Tree (reactive)
            Expanded(
              child: ListenableBuilder(
                listenable: viewModel,
                builder: (_, __) => PartsHierarchyTree(
                  hierarchy: viewModel.partsHierarchy!,
                  expandedGroups: viewModel.expandedGroups,
                  loadedGroups: viewModel.loadedGroups,
                  loadingGroups: viewModel.loadingGroups,
                  selectedPartId: viewModel.selectedPart,
                  onExpandGroup: viewModel.expandGroup,
                  onCollapseGroup: viewModel.collapseGroup,
                  onPartTap: (partId, modelCode, item) {
                    viewModel.loadPartOnDemand(partId, modelCode);
                    viewModel.selectPartItemFromTree(partId, item);
                    nav.pop();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ).then((_) => viewModel.closeHierarchyDialog());
}
