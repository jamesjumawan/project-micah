import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/screen_types/desktop_view.dart';
import 'package:project_micah/ui/widgets/common/motorcycle_showcase/motorcycle_showcase.dart';
import 'package:project_micah/ui/widgets/common/parts_overlay/parts_overlay.dart';
import 'package:project_micah/ui/widgets/common/parts_description/parts_description.dart';
import 'package:stacked/stacked.dart';

import 'details_viewmodel.dart';
import 'details_view_helpers.dart';
import 'package:project_micah/ui/widgets/common/three_d/three_d_viewer.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class DetailsViewDesktop extends ViewModelWidget<DetailsViewModel> {
  const DetailsViewDesktop({super.key});

  @override
  Widget build(BuildContext context, DetailsViewModel viewModel) {
    return DesktopView(
      padding: EdgeInsets.zero,
      isScrollable: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left sidebar - Motorcycle catalog with collapse toggle
                    Stack(
                      children: [
                        MotorcycleShowcase(
                          motorcycles: viewModel.motorcycles,
                          selectedMotorcycle: viewModel.selectedMotorcycle,
                          isCollapsed: viewModel.isMotorcycleShowcaseCollapsed,
                          onMotorcycleSelected: (name) =>
                              viewModel.selectMotorcycle(name),
                        ),
                          Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton(
                            icon: Icon(
                              viewModel.isMotorcycleShowcaseCollapsed
                                  ? Icons.chevron_right
                                  : Icons.chevron_left,
                              size: 20,
                            ),
                            onPressed: viewModel.toggleMotorcycleShowcase,
                            tooltip: viewModel.isMotorcycleShowcaseCollapsed
                                ? 'Expand'
                                : 'Collapse',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Center - 3D Viewer with bottom controls
                    //TODO: fix overflow when sidebar is opened
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: viewModel.isPartsOverlayOpen
                                ? const SizedBox.shrink()
                                : ThreeDViewer(
                                    assemblyModelPaths:
                                        viewModel.allAssemblyModelPaths,
                                    assemblyMtlPaths:
                                        viewModel.allAssemblyMtlPaths,
                                    // Phase 4: pass all disassembly paths; Phase 5: empty (lazy)
                                    disassemblyModelPaths:
                                        viewModel.partsHierarchy == null
                                            ? viewModel.allDisassemblyModelPaths
                                            : const [],
                                    disassemblyMtlPaths:
                                        viewModel.partsHierarchy == null
                                            ? viewModel.allDisassemblyMtlPaths
                                            : const [],
                                    modelName: viewModel.isAssembleMode
                                        ? '${viewModel.selectedMotorcycle} - Full Assembly'
                                        : '${viewModel.selectedMotorcycle} - ${viewModel.selectedPart ?? "Parts View"}',
                                    height: double.infinity,
                                    isAssembleMode: viewModel.isAssembleMode,
                                    disassemblyDistance: viewModel.partDistance,
                                    onToggleMode: (mode) =>
                                        viewModel.toggleMode(mode),
                                    onResetToAssemble:
                                        viewModel.resetToAssembleMode,
                                    // Phase 5 params
                                    hierarchyMode:
                                        viewModel.partsHierarchy != null,
                                    groupLoadCommand:
                                        viewModel.groupLoadCommand,
                                    partLoadCommand: viewModel.partLoadCommand,
                                    onGroupLoaded: viewModel.onGroupLoaded,
                                    onPartSelected: (modelPath) {
                                      // Both Phase 4 and 5: match obj URL → display name key
                                      String? matchedKey;
                                      viewModel.partsModels.forEach((k, v) {
                                        if (v['obj'] == modelPath) {
                                          matchedKey = k;
                                        }
                                      });
                                      if (matchedKey != null) {
                                        viewModel.selectPart(matchedKey!);
                                      }
                                    },
                                    pointerEventsDisabled:
                                        viewModel.isPartsOverlayOpen ||
                                            viewModel.isHierarchyDialogOpen,
                                  ),
                          ),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      UIHelpers.spacing12,
                                      UIHelpers.spacing8,
                                      UIHelpers.spacing12,
                                      0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border(
                                      top: BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          if (viewModel.partsHierarchy !=
                                              null) {
                                            showPartsHierarchyDialog(
                                                context, viewModel);
                                          } else {
                                            viewModel.togglePartsOverlay();
                                          }
                                        },
                                        icon: const Icon(Icons.view_module),
                                        label: const Text('SEE ALL PARTS'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: UIHelpers.spacing16,
                                            vertical: UIHelpers.spacing12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                  UIHelpers.spacing12,
                                  0,
                                  UIHelpers.spacing12,
                                  UIHelpers.spacing8,
                                ),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ToggleButton(
                                        isAssembleMode:
                                            viewModel.isAssembleMode,
                                        isEnabled: viewModel.has3DModel,
                                        onToggle: () => viewModel.toggleMode(
                                            !viewModel.isAssembleMode),
                                      ),
                                      if (!viewModel.isAssembleMode) ...[
                                        UIHelpers.horizontalSpace20,
                                        Text(
                                          'Parts Distance:',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        Slider(
                                          padding: EdgeInsets.all(4),
                                          value: viewModel.partDistance,
                                          min: 0.0,
                                          max: 20.0,
                                          divisions: 100,
                                          label: viewModel.partDistance
                                              .toStringAsFixed(1),
                                          onChanged: (value) => viewModel
                                              .updatePartDistance(value),
                                        ),
                                        SizedBox(
                                          width: 30,
                                          child: Text(
                                            viewModel.partDistance
                                                .toStringAsFixed(1),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ),
                                      ],
                                      UIHelpers.horizontalSpace24,
                                      const ControlItem(
                                        icon: Icons.mouse,
                                        label: 'Left Click +Drag',
                                        action: 'Rotate',
                                      ),
                                      UIHelpers.horizontalSpace12,
                                      const ControlItem(
                                        icon: Icons.zoom_in,
                                        label: 'Mouse Wheel',
                                        action: 'Zoom',
                                      ),
                                      UIHelpers.horizontalSpace12,
                                      const ControlItem(
                                        icon: Icons.refresh,
                                        label: 'R Key',
                                        action: 'Reset',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (viewModel.selectedPart != null)
                      GestureDetector(
                        onTap: viewModel.toggleRightSidebar,
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Container(
                            width: 20,
                            decoration: BoxDecoration(color: AppColors.border),
                            child: Center(
                              child: Icon(
                                viewModel.isRightSidebarVisible
                                    ? Icons.chevron_right
                                    : Icons.chevron_left,
                                color: AppColors.borderDark,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (!viewModel.isAssembleMode &&
                        viewModel.selectedPart != null)
                      SizedBox(
                        width: 300,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: AppColors.surface,
                            border: Border(
                                left: BorderSide(color: AppColors.border)),
                          ),
                          child: viewModel.isBusy
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : PartsDescription(
                                  imageUrl: viewModel.partsImageUrl,
                                  partsName: viewModel.partsName,
                                  sku: viewModel.partsSku,
                                  category: viewModel.partsCategory,
                                  description: viewModel.partsDescription,
                                  partNo: viewModel.partsPartNo,
                                  quantity: viewModel.partsQuantity,
                                  groupNo: viewModel.partsGroupNo,
                                  label: 'PART DETAILS',
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          if (viewModel.isPartsOverlayOpen && viewModel.partsHierarchy == null)
            Positioned.fill(
              child: PartsOverlay(
                engineParts: viewModel.engineSpecs,
                accessoryParts: viewModel.accessoriesSpecs,
                selectedPart: viewModel.selectedPart,
                onPartSelected: (part) => viewModel.selectPart(part),
                onClose: viewModel.togglePartsOverlay,
              ),
            ),
        ],
      ),
    );
  }
}
