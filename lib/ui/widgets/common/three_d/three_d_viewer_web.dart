// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class ThreeDViewer extends StatefulWidget {
  /// Assembly model paths (for assemble mode)
  final List<String> assemblyModelPaths;

  /// Assembly MTL paths aligned with assemblyModelPaths
  final List<String?>? assemblyMtlPaths;

  /// Disassembly model paths (for disassemble mode)
  final List<String> disassemblyModelPaths;

  /// Disassembly MTL paths aligned with disassemblyModelPaths
  final List<String?>? disassemblyMtlPaths;

  final String modelName;
  final double height;
  final bool isAssembleMode;
  final Function(bool)? onToggleMode;

  /// Distance multiplier for disassembled parts (0.0 to 3.0)
  final double disassemblyDistance;

  /// Called when the embedded web viewer posts a `partClick` message with
  /// the model path. Receives the model path string as provided by the
  /// iframe (e.g. 'assets/sample_3d_object/blt150_rearShockAbsorber_final_00.obj').
  final void Function(String modelPath)? onPartSelected;

  /// Called when R key is pressed to reset to assemble mode
  final VoidCallback? onResetToAssemble;

  const ThreeDViewer({
    super.key,
    required this.assemblyModelPaths,
    this.assemblyMtlPaths,
    required this.disassemblyModelPaths,
    this.disassemblyMtlPaths,
    required this.modelName,
    this.height = 420,
    this.isAssembleMode = true,
    this.onToggleMode,
    this.onPartSelected,
    this.disassemblyDistance = 1.0,
    this.onResetToAssemble,
  });

  @override
  State<ThreeDViewer> createState() => _ThreeDViewerState();
}

class _ThreeDViewerState extends State<ThreeDViewer> {
  late String viewType;
  StreamSubscription<html.MessageEvent>? _messageSub;
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    _registerViewer();
    // Listen for postMessage events from the iframe (Three.js viewer).
    _messageSub = html.window.onMessage.listen((html.MessageEvent event) {
      try {
        final dynamic data = event.data;
        String? type;
        String? model;
        if (data is String) {
          // Ignore known non-JSON string messages
          final s = data.trim();

          // Ignore non-JSON messages
          if (!s.startsWith('{') && !s.startsWith('[')) {
            debugPrint('Ignored non-JSON message: $s');
            return;
          }

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
        // Silently ignore malformed messages from browser extensions/dev tools
      }
    });
  }

  @override
  void didUpdateWidget(ThreeDViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If mode changed, send toggle message instead of recreating iframe
    if (oldWidget.isAssembleMode != widget.isAssembleMode) {
      _sendToggleModeMessage();
    }

    // If disassembly distance changed, send update message
    if (oldWidget.disassemblyDistance != widget.disassemblyDistance) {
      _sendDisassemblyDistanceMessage(widget.disassemblyDistance);
    }

    // Only re-register if model paths actually changed (e.g., motorcycle changed)
    final oldAssembly = oldWidget.assemblyModelPaths.join('|');
    final newAssembly = widget.assemblyModelPaths.join('|');
    final oldDisassembly = oldWidget.disassemblyModelPaths.join('|');
    final newDisassembly = widget.disassemblyModelPaths.join('|');

    if (oldAssembly != newAssembly || oldDisassembly != newDisassembly) {
      debugPrint('🎨 Model paths changed! Re-registering viewer...');
      _registerViewer();
    }
  }

  void _sendToggleModeMessage() {
    final mode = widget.isAssembleMode ? 'assemble' : 'disassemble';
    final message = {'type': 'toggleMode', 'mode': mode};

    // Send message to iframe
    if (_iframe != null) {
      _iframe!.contentWindow?.postMessage(message, '*');
      debugPrint('three_d_viewer: Sent toggle message: $mode');
    }
  }

  void _sendDisassemblyDistanceMessage(double distance) {
    final message = {'type': 'updateDisassemblyDistance', 'distance': distance};

    // Send message to iframe
    if (_iframe != null) {
      _iframe!.contentWindow?.postMessage(message, '*');
      debugPrint('three_d_viewer: Sent disassembly distance: $distance');
    }
  }

  void _sendResetCameraMessage() {
    final message = {'type': 'resetCamera'};

    // Send message to iframe
    if (_iframe != null) {
      _iframe!.contentWindow?.postMessage(message, '*');
      debugPrint('three_d_viewer: Sent reset camera command');
    }
  }

  void _registerViewer() {
    viewType = 'three-d-viewer-${DateTime.now().microsecondsSinceEpoch}';

    // Build query params for both assembly and disassembly models
    final assemblyEncoded =
        widget.assemblyModelPaths.map(Uri.encodeComponent).join(',');
    final disassemblyEncoded =
        widget.disassemblyModelPaths.map(Uri.encodeComponent).join(',');

    String src =
        '/three_viewer_obj.html?assemblyModels=$assemblyEncoded&disassemblyModels=$disassemblyEncoded';

    // Add assembly MTLs if provided
    if (widget.assemblyMtlPaths != null &&
        widget.assemblyMtlPaths!.isNotEmpty) {
      final assemblyMtlsEncoded = widget.assemblyMtlPaths!
          .map((m) => m != null && m.isNotEmpty ? Uri.encodeComponent(m) : '')
          .join(',');
      src = '$src&assemblyMtls=$assemblyMtlsEncoded';
    }

    // Add disassembly MTLs if provided
    if (widget.disassemblyMtlPaths != null &&
        widget.disassemblyMtlPaths!.isNotEmpty) {
      final disassemblyMtlsEncoded = widget.disassemblyMtlPaths!
          .map((m) => m != null && m.isNotEmpty ? Uri.encodeComponent(m) : '')
          .join(',');
      src = '$src&disassemblyMtls=$disassemblyMtlsEncoded';
    }

    // Set initial mode
    final initialMode = widget.isAssembleMode ? 'assemble' : 'disassemble';
    src = '$src&mode=$initialMode';

    // Set disassembly distance
    src = '$src&disassemblyDistance=${widget.disassemblyDistance}';

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final element = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent';

      _iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.backgroundColor = 'transparent'
        ..style.pointerEvents = 'auto' // Allow interaction with 3D model
        ..src = src;
      _iframe!.setAttribute('allowTransparency', 'true');

      element.append(_iframe!);
      return element;
    });
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _iframe = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.keyR)) {
          _sendResetCameraMessage();
          if (widget.onResetToAssemble != null) {
            widget.onResetToAssemble!();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
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

            // Title overlay at top left
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.modelName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
