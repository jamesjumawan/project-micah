import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/screen_types/desktop_view.dart';
import 'package:project_micah/ui/widgets/common/motorcycle_showcase/motorcycle_showcase.dart';
import 'package:project_micah/ui/widgets/common/parts_overlay/parts_overlay.dart';
import 'package:project_micah/ui/widgets/common/parts_description/parts_description.dart';
import 'package:project_micah/ui/widgets/common/loading/cog_loader.dart';
import 'package:stacked/stacked.dart';

import 'details_viewmodel.dart';
import 'details_view_helpers.dart';
import 'package:project_micah/ui/widgets/common/three_d/three_d_viewer.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/text_strings.dart';

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
                            child: viewModel.isSubAssemblyFocused
                                ? _SubAssemblyFocusOverlay(
                                    saCode: viewModel.focusedSubAssembly ?? '',
                                    objPath:
                                        viewModel.focusedSubAssemblyObjPath,
                                    mtlPath:
                                        viewModel.focusedSubAssemblyMtlPath,
                                    onBack: viewModel.clearSubAssemblyFocus,
                                  )
                                : viewModel.isPartsOverlayOpen
                                    ? const SizedBox.shrink()
                                    : ThreeDViewer(
                                        assemblyModelPaths:
                                            viewModel.allAssemblyModelPaths,
                                        assemblyMtlPaths:
                                            viewModel.allAssemblyMtlPaths,
                                        // BLT150: always pass Blender explosion OBJs.
                                        // Other motorcycles: Phase 4 eager or Phase 5 lazy.
                                        disassemblyModelPaths: (viewModel
                                                        .partsHierarchy ==
                                                    null ||
                                                viewModel.hasExplosionModels)
                                            ? viewModel.allDisassemblyModelPaths
                                            : const [],
                                        disassemblyMtlPaths: (viewModel
                                                        .partsHierarchy ==
                                                    null ||
                                                viewModel.hasExplosionModels)
                                            ? viewModel.allDisassemblyMtlPaths
                                            : const [],
                                        modelName: viewModel.selectedMotorcycle,
                                        height: double.infinity,
                                        isAssembleMode:
                                            viewModel.isAssembleMode,
                                        disassemblyDistance:
                                            viewModel.partDistance,
                                        partsMeta: viewModel.partsMeta,
                                        onToggleMode: (mode) =>
                                            viewModel.toggleMode(mode),
                                        onResetToAssemble:
                                            viewModel.resetToAssembleMode,
                                        // Phase 5 params
                                        hierarchyMode:
                                            viewModel.partsHierarchy != null &&
                                                !viewModel.hasExplosionModels,
                                        groupLoadCommand:
                                            viewModel.groupLoadCommand,
                                        partLoadCommand:
                                            viewModel.partLoadCommand,
                                        onGroupLoaded: viewModel.onGroupLoaded,
                                        onPartSelected: (payload) {
                                          final parts = payload.split('|||');
                                          final itemCode = parts[0];
                                          final meshName = parts.length > 1
                                              ? parts[1]
                                              : null;
                                          // Parse human-readable display name from meshName
                                          // e.g. "SPD-45467X-B_—_Guard,_Front_Cover" → "Guard, Front Cover"
                                          String? displayName;
                                          if (meshName != null &&
                                              meshName.contains('_\u2014_')) {
                                            displayName = meshName
                                                .split('_\u2014_')
                                                .skip(1)
                                                .join(' \u2014 ')
                                                .replaceAll('_', ' ');
                                          }
                                          // Try JSON match first; fallback opens sidebar with code
                                          String? matchedKey;
                                          viewModel.partsModels.forEach((k, v) {
                                            if (v['obj'] == itemCode ||
                                                (v['item_code']?.isNotEmpty ==
                                                        true &&
                                                    v['item_code'] ==
                                                        itemCode)) {
                                              matchedKey = k;
                                            }
                                          });
                                          if (matchedKey != null) {
                                            viewModel.selectPart(matchedKey!);
                                          } else {
                                            viewModel.selectPartByCode(itemCode,
                                                displayName: displayName);
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

                    if (viewModel.selectedPart != null &&
                        !viewModel.isSubAssemblyFocused)
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
                        viewModel.selectedPart != null &&
                        !viewModel.isSubAssemblyFocused &&
                        viewModel.isRightSidebarVisible)
                      LayoutBuilder(builder: (context, _) {
                        final sidebarWidth =
                            MediaQuery.of(context).size.width * 0.35;
                        return SizedBox(
                          width: sidebarWidth,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: AppColors.surface,
                              border: Border(
                                  left: BorderSide(color: AppColors.border)),
                            ),
                            child: viewModel.isBusy
                                ? const Center(child: CogLoader())
                                : PartsDescription(
                                    imageUrl: viewModel.partsImageUrl,
                                    partsName: viewModel.partsName,
                                    sku: viewModel.partsSku,
                                    category: viewModel.partsCategory,
                                    description: viewModel.partsDescription,
                                    partNo: viewModel.partsPartNo,
                                    quantity: viewModel.partsQuantity,
                                    groupNo: viewModel.partsGroupNo,
                                    label: TTexts.partDetails,
                                    previewWidget: viewModel
                                            .selectedPartSingleObjPath
                                            .isNotEmpty
                                        ? ThreeDViewer(
                                            assemblyModelPaths: [
                                              viewModel
                                                  .selectedPartSingleObjPath
                                            ],
                                            assemblyMtlPaths: [
                                              viewModel
                                                  .selectedPartSingleMtlPath
                                            ],
                                            disassemblyModelPaths: const [],
                                            modelName: viewModel.partsName,
                                            height: 280,
                                            isAssembleMode: true,
                                          )
                                        : null,
                                  ),
                          ),
                        );
                      }),
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

/// Full-area overlay shown when a sub-assembly is clicked in disassembly mode.
/// Replaces the 3D viewer until the user presses Back.
class _SubAssemblyFocusOverlay extends StatelessWidget {
  final String saCode;
  final String objPath;
  final String? mtlPath;
  final VoidCallback onBack;

  const _SubAssemblyFocusOverlay({
    required this.saCode,
    required this.objPath,
    required this.onBack,
    this.mtlPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header bar ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: UIHelpers.spacing16,
              vertical: UIHelpers.spacing12,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_ios, size: 14),
                  label: Text(TTexts.back),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIHelpers.spacing8,
                      vertical: 4,
                    ),
                  ),
                ),
                UIHelpers.horizontalSpace12,
                Text(
                  saCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
              ],
            ),
          ),

          // ── Body: 3D viewer or Coming Soon ────────────────────────────
          Expanded(
            child: objPath.isNotEmpty
                ? ThreeDViewer(
                    assemblyModelPaths: [objPath],
                    assemblyMtlPaths: [mtlPath],
                    disassemblyModelPaths: const [],
                    disassemblyMtlPaths: const [],
                    modelName: saCode,
                    height: double.infinity,
                    isAssembleMode: true,
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.construction_outlined,
                            size: 48, color: AppColors.textHint),
                        UIHelpers.verticalSpace16,
                        Text(
                          TTexts.comingSoon,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                        UIHelpers.verticalSpace8,
                        Text(
                          TTexts.comingSoonSubtitle,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textHint),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
