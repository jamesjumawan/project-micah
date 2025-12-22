import 'package:flutter/material.dart';

class ThreeDViewer extends StatelessWidget {
  final List<String> modelPaths;
  final List<String?>? mtlPaths;
  final String modelName;
  final double height;
  final bool isAssembleMode;
  final Function(bool)? onToggleMode;
  final void Function(String modelPath)? onPartSelected;

  const ThreeDViewer({
    super.key,
    required this.modelPaths,
    this.mtlPaths,
    required this.modelName,
    this.height = 420,
    this.isAssembleMode = true,
    this.onToggleMode,
    this.onPartSelected,
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
            Text(
                '${modelPaths.length} model(s) - 3D viewer is only available on web'),
          ],
        ),
      ),
    );
  }
}
