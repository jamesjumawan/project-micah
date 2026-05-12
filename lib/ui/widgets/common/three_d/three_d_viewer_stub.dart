import 'package:flutter/material.dart';
import 'package:project_micah/models/hierarchy_load_command.dart';

class ThreeDViewer extends StatelessWidget {
  final List<String> assemblyModelPaths;
  final List<String?>? assemblyMtlPaths;
  final List<String> disassemblyModelPaths;
  final List<String?>? disassemblyMtlPaths;
  final String modelName;
  final double height;
  final bool isAssembleMode;
  final double disassemblyDistance;
  final Function(bool)? onToggleMode;
  final void Function(String modelPath)? onPartSelected;
  final VoidCallback? onResetToAssemble;
  // Phase 5
  final bool hierarchyMode;
  final HierarchyGroupLoadCommand? groupLoadCommand;
  final HierarchyPartLoadCommand? partLoadCommand;
  final void Function(String groupCode)? onGroupLoaded;
  final void Function(String partId, {required bool fromCache})? onPartLoaded;
  final bool pointerEventsDisabled;
  final Map<String, Map<String, String>>? partsMeta;

  const ThreeDViewer({
    super.key,
    required this.assemblyModelPaths,
    this.assemblyMtlPaths,
    required this.disassemblyModelPaths,
    this.disassemblyMtlPaths,
    required this.modelName,
    this.height = 420,
    this.isAssembleMode = true,
    this.disassemblyDistance = 1.0,
    this.onToggleMode,
    this.onPartSelected,
    this.onResetToAssemble,
    this.hierarchyMode = false,
    this.groupLoadCommand,
    this.partLoadCommand,
    this.onGroupLoaded,
    this.onPartLoaded,
    this.pointerEventsDisabled = false,
    this.partsMeta,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.threed_rotation, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(hierarchyMode
                ? '3D viewer (Phase 5 hierarchy mode) — web only'
                : '3D viewer — web only'),
          ],
        ),
      ),
    );
  }
}
