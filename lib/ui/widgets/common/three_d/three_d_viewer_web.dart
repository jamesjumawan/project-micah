// ignore_for_file: deprecated_member_use
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class ThreeDViewer extends StatefulWidget {
  /// Accepts one or more model OBJ paths. For assemble mode this will usually
  /// be a single full-assembly model. For disassemble it can be multiple part
  /// models displayed together.
  final List<String> modelPaths;

  /// Optional matching list of MTL paths aligned with [modelPaths]. Use null or
  /// empty string for entries without an MTL.
  final List<String?>? mtlPaths;
  final String modelName;
  final double height;
  final bool isAssembleMode;
  final Function(bool)? onToggleMode;

  /// Called when the embedded web viewer posts a `partClick` message with
  /// the model path. Receives the model path string as provided by the
  /// iframe (e.g. 'assets/sample_3d_object/blt150_rearShockAbsorber_final_00.obj').
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
  State<ThreeDViewer> createState() => _ThreeDViewerState();
}

class _ThreeDViewerState extends State<ThreeDViewer> {
  late String viewType;
  String? currentModelPath;
  String? currentMtlPath;
  StreamSubscription<html.MessageEvent>? _messageSub;

  @override
  void initState() {
    super.initState();
    _registerViewer();
    // Listen for postMessage events from the iframe (Three.js viewer).
    // Expect payloads like: { type: 'partClick', model: '<path>' }
    _messageSub = html.window.onMessage.listen((html.MessageEvent event) {
      try {
        final dynamic data = event.data;
        String? type;
        String? model;
        if (data is String) {
          final parsed = json.decode(data);
          if (parsed is Map) {
            type = parsed['type']?.toString();
            model = parsed['model']?.toString();
          }
        } else if (data is Map) {
          type = data['type']?.toString();
          model = data['model']?.toString();
        }

        if (type == 'partClick' &&
            model != null &&
            widget.onPartSelected != null) {
          widget.onPartSelected!(model);
        }
      } catch (e) {
        // Ignore malformed messages
        debugPrint('three_d_viewer: failed to handle message: $e');
      }
    });
  }

  @override
  void didUpdateWidget(ThreeDViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-register viewer if model paths changed
    final oldModels = oldWidget.modelPaths.join('|');
    final newModels = widget.modelPaths.join('|');
    final oldMtls = (oldWidget.mtlPaths ?? []).join('|');
    final newMtls = (widget.mtlPaths ?? []).join('|');
    if (oldModels != newModels || oldMtls != newMtls) {
      debugPrint('🎨 Model paths changed! Re-registering viewer...');
      _registerViewer();
    }
  }

  void _registerViewer() {
    // Keep a reference to the first model for legacy usages/debugging
    currentModelPath =
        widget.modelPaths.isNotEmpty ? widget.modelPaths.first : null;
    currentMtlPath = (widget.mtlPaths != null && widget.mtlPaths!.isNotEmpty)
        ? widget.mtlPaths!.first
        : null;
    viewType = 'three-d-viewer-${DateTime.now().microsecondsSinceEpoch}';

    // Build a comma-separated list of encoded model paths and optional mtls
    final encodedModels = widget.modelPaths.map(Uri.encodeComponent).join(',');
    String src = 'three_viewer_obj.html?models=$encodedModels';
    if (widget.mtlPaths != null && widget.mtlPaths!.isNotEmpty) {
      final encodedMtls = widget.mtlPaths!
          .map((m) => m != null && m.isNotEmpty ? Uri.encodeComponent(m) : '')
          .join(',');
      src = '$src&mtls=$encodedMtls';
    }

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent';

      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.backgroundColor = 'transparent'
        ..style.pointerEvents = 'auto' // Allow interaction with 3D model
        ..src = src;
      iframe.setAttribute('allowTransparency', 'true');

      element.append(iframe);
      return element;
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: Column(
        children: [
          // Top control bar with toggle buttons
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.modelName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Assemble/Disassemble toggle buttons
                if (widget.onToggleMode != null) ...[
                  _ToggleButton(
                    label: 'ASSEMBLE',
                    isSelected: widget.isAssembleMode,
                    onTap: () => widget.onToggleMode!(true),
                  ),
                  const SizedBox(width: 8),
                  _ToggleButton(
                    label: 'DISASSEMBLE',
                    isSelected: !widget.isAssembleMode,
                    onTap: () => widget.onToggleMode!(false),
                  ),
                ],
              ],
            ),
          ),

          // 3D Viewer
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.surface),

                // overlay image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/overlay.jpg',
                    fit: BoxFit.fill,
                  ),
                ),

                // content
                Positioned.fill(
                  child: HtmlElementView(viewType: viewType),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Toggle button widget for Assemble/Disassemble
class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          border: Border.all(
            color: AppColors.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
