import 'package:flutter/material.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final totalModels =
        assemblyModelPaths.length + disassemblyModelPaths.length;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.threed_rotation, size: 48, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
                '$totalModels model(s) preloaded - 3D viewer is only available on web'),
          ],
        ),
      ),
    );
  }
}
