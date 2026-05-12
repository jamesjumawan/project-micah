// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_micah/models/hierarchy_load_command.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';

class ThreeDViewer extends StatefulWidget {
  // ── Phase 4 (eager load) params ─────────────────────────────────────────
  /// Assembly model paths (for assemble mode)
  final List<String> assemblyModelPaths;

  /// Assembly MTL paths aligned with assemblyModelPaths
  final List<String?>? assemblyMtlPaths;

  /// Disassembly model paths (for disassemble mode) — Phase 4 only
  final List<String> disassemblyModelPaths;

  /// Disassembly MTL paths aligned with disassemblyModelPaths — Phase 4 only
  final List<String?>? disassemblyMtlPaths;

  /// Metadata for disassembly parts: map of OBJ filename (no ext) → {item_code, description, displayName}
  /// Used by the viewer to show rich tooltips and populate the right-side details panel.
  final Map<String, Map<String, String>>? partsMeta;

  final String modelName;
  final double height;
  final bool isAssembleMode;
  final Function(bool)? onToggleMode;

  /// Distance multiplier for disassembled parts
  final double disassemblyDistance;

  /// Called when a part is clicked in the viewer
  final void Function(String modelPath)? onPartSelected;

  /// Called when R key resets to assemble mode
  final VoidCallback? onResetToAssemble;

  // ── Phase 5 (lazy load + IndexedDB) params ──────────────────────────────
  /// When true, uses three_viewer_v5.html with IndexedDB + lazy loading.
  final bool hierarchyMode;

  /// Send this command to trigger loading a group's parts in the v5 viewer.
  /// A new object identity each time triggers a send (use a fresh instance).
  final HierarchyGroupLoadCommand? groupLoadCommand;

  /// Send this command to load a single part on demand in the v5 viewer.
  final HierarchyPartLoadCommand? partLoadCommand;

  /// Called when v5 viewer finishes loading a group.
  final void Function(String groupCode)? onGroupLoaded;

  /// Called when v5 viewer loads a part (fromCache = true means IndexedDB hit).
  final void Function(String partId, {required bool fromCache})? onPartLoaded;

  /// When true, the iframe ignores all pointer events (use during dialogs/overlays).
  final bool pointerEventsDisabled;

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
    this.partsMeta,
    // Phase 5
    this.hierarchyMode = false,
    this.groupLoadCommand,
    this.partLoadCommand,
    this.onGroupLoaded,
    this.onPartLoaded,
    this.pointerEventsDisabled = false,
  });

  @override
  State<ThreeDViewer> createState() => _ThreeDViewerState();
}

class _ThreeDViewerState extends State<ThreeDViewer> {
  String viewType = '';
  StreamSubscription<html.MessageEvent>? _messageSub;
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    _registerViewer();
    _messageSub = html.window.onMessage.listen(_onIframeMessage);
  }

  void _onIframeMessage(html.MessageEvent event) {
    try {
      final dynamic raw = event.data;
      Map<String, dynamic>? data;

      if (raw is String) {
        final s = raw.trim();
        if (!s.startsWith('{') && !s.startsWith('[')) return;
        final parsed = json.decode(s);
        if (parsed is Map<String, dynamic>) data = parsed;
      } else if (raw is Map) {
        data = Map<String, dynamic>.from(raw);
      }

      if (data == null) return;
      final type = data['type']?.toString();
      final model = data['model']?.toString();
      final meshName = data['meshName']?.toString();

      switch (type) {
        case 'partClick':
          // Pass both itemCode and meshName separated by ||| so views can use selectPartByCode
          if (model != null) {
            final payload = meshName != null ? '$model|||$meshName' : model;
            widget.onPartSelected?.call(payload);
          }
          break;
        case 'groupLoaded':
          final groupCode = data['groupCode']?.toString();
          if (groupCode != null) widget.onGroupLoaded?.call(groupCode);
          break;
        case 'partLoaded':
          final partId = data['partId']?.toString();
          final fromCache = data['fromCache'] as bool? ?? false;
          if (partId != null)
            widget.onPartLoaded?.call(partId, fromCache: fromCache);
          break;
      }
    } catch (_) {
      // Silently ignore malformed messages
    }
  }

  @override
  void didUpdateWidget(ThreeDViewer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.disassemblyDistance != widget.disassemblyDistance) {
      _sendDisassemblyDistanceMessage(widget.disassemblyDistance);
    }

    if (oldWidget.pointerEventsDisabled != widget.pointerEventsDisabled) {
      _iframe?.style.pointerEvents =
          widget.pointerEventsDisabled ? 'none' : 'auto';
    }

    // Phase 5: send group load command when it changes to a new instance
    if (widget.hierarchyMode &&
        widget.groupLoadCommand != null &&
        !identical(oldWidget.groupLoadCommand, widget.groupLoadCommand)) {
      _postMessage(widget.groupLoadCommand!.toJson());
    }

    // Phase 5: send part load command when it changes to a new instance
    if (widget.hierarchyMode &&
        widget.partLoadCommand != null &&
        !identical(oldWidget.partLoadCommand, widget.partLoadCommand)) {
      _postMessage(widget.partLoadCommand!.toJson());
    }

    // Re-register if mode, assembly paths, or disassembly paths change.
    // Mode is baked into the URL so we always re-register rather than postMessage,
    // which avoids timing issues (iframe JS listener not ready yet).
    final oldAssembly = oldWidget.assemblyModelPaths.join('|');
    final newAssembly = widget.assemblyModelPaths.join('|');
    final oldDisassembly = oldWidget.disassemblyModelPaths.join('|');
    final newDisassembly = widget.disassemblyModelPaths.join('|');
    final modeChanged = oldWidget.isAssembleMode != widget.isAssembleMode;

    if (modeChanged ||
        oldAssembly != newAssembly ||
        (!widget.hierarchyMode && oldDisassembly != newDisassembly)) {
      debugPrint('ThreeDViewer: re-registering (modeChanged=$modeChanged)');
      _registerViewer();
    }
  }

  void _postMessage(Map<String, dynamic> message) {
    _iframe?.contentWindow?.postMessage(json.encode(message), '*');
  }

  void _sendDisassemblyDistanceMessage(double distance) {
    _postMessage({'type': 'updateDisassemblyDistance', 'distance': distance});
  }

  void _sendResetCameraMessage() {
    _postMessage({'type': 'resetCamera'});
  }

  void _registerViewer() {
    final newViewType =
        'three-d-viewer-${DateTime.now().microsecondsSinceEpoch}';

    final String src;

    if (widget.hierarchyMode) {
      // ── Phase 5: v5 viewer, assembly model only in query params ──────────
      final assemblyModel = widget.assemblyModelPaths.isNotEmpty
          ? Uri.encodeComponent(widget.assemblyModelPaths.first)
          : '';
      final assemblyMtl = (widget.assemblyMtlPaths?.isNotEmpty == true &&
              widget.assemblyMtlPaths!.first != null)
          ? Uri.encodeComponent(widget.assemblyMtlPaths!.first!)
          : '';
      final initialMode = widget.isAssembleMode ? 'assemble' : 'disassemble';
      src = '/three_viewer_v5.html'
          '?assemblyModel=$assemblyModel'
          '&assemblyMtl=$assemblyMtl'
          '&mode=$initialMode'
          '&disassemblyDistance=${widget.disassemblyDistance}';
    } else {
      // ── Phase 4: original viewer, all disassembly paths in query params ──
      final assemblyEncoded =
          widget.assemblyModelPaths.map(Uri.encodeComponent).join(',');
      final disassemblyEncoded =
          widget.disassemblyModelPaths.map(Uri.encodeComponent).join(',');
      debugPrint(
          '[ThreeDViewer] assembly paths (${widget.assemblyModelPaths.length}): ${widget.assemblyModelPaths}');
      debugPrint(
          '[ThreeDViewer] disassembly paths (${widget.disassemblyModelPaths.length}): ${widget.disassemblyModelPaths}');
      var p4src =
          '/three_viewer_obj.html?assemblyModels=$assemblyEncoded&disassemblyModels=$disassemblyEncoded';

      if (widget.assemblyMtlPaths != null &&
          widget.assemblyMtlPaths!.isNotEmpty) {
        final enc = widget.assemblyMtlPaths!
            .map((m) => m != null && m.isNotEmpty ? Uri.encodeComponent(m) : '')
            .join(',');
        p4src = '$p4src&assemblyMtls=$enc';
      }
      if (widget.disassemblyMtlPaths != null &&
          widget.disassemblyMtlPaths!.isNotEmpty) {
        final enc = widget.disassemblyMtlPaths!
            .map((m) => m != null && m.isNotEmpty ? Uri.encodeComponent(m) : '')
            .join(',');
        p4src = '$p4src&disassemblyMtls=$enc';
      }
      if (widget.partsMeta != null && widget.partsMeta!.isNotEmpty) {
        p4src =
            '$p4src&partsMeta=${Uri.encodeComponent(json.encode(widget.partsMeta))}';
      }
      p4src =
          '$p4src&mode=${widget.isAssembleMode ? 'assemble' : 'disassemble'}';
      p4src = '$p4src&disassemblyDistance=${widget.disassemblyDistance}';
      p4src = '$p4src&_t=${DateTime.now().millisecondsSinceEpoch}';
      src = p4src;
    }

    ui_web.platformViewRegistry.registerViewFactory(newViewType, (int viewId) {
      final element = html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent';

      _iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..style.backgroundColor = 'transparent'
        ..style.pointerEvents = widget.pointerEventsDisabled ? 'none' : 'auto'
        ..src = src;
      _iframe!.setAttribute('allowTransparency', 'true');

      element.append(_iframe!);
      return element;
    });

    // Update viewType and rebuild so HtmlElementView uses the new iframe.
    // During initState the first build hasn't run yet — just assign directly.
    // On re-registration (didUpdateWidget), setState triggers a rebuild.
    if (mounted && viewType != newViewType) {
      setState(() => viewType = newViewType);
    } else {
      viewType = newViewType;
    }
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
