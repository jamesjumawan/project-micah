import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:project_micah/app/app.locator.dart';
import 'package:project_micah/models/motorcycle_model.dart';
import 'package:project_micah/models/hierarchy_load_command.dart';
import 'package:project_micah/models/parts_hierarchy_model.dart';
import 'package:project_micah/services/motorcycle_service.dart';

class DetailsViewModel extends BaseViewModel {
  static const String _assetsBaseUrl =
      'https://micah-assets.s3.us-east-1.amazonaws.com/assets';

  final _motorcycleService = locator<MotorcycleService>();

  bool _isAssembleMode = true;
  bool get isAssembleMode => _isAssembleMode;

  /// Name of the currently selected motorcycle. Defaults to the first entry
  /// in the catalogue so the viewer is never empty.
  String _selectedMotorcycle = '';
  String get selectedMotorcycle => _selectedMotorcycle;

  String? _selectedPart;
  String? get selectedPart => _selectedPart;

  bool _isPartsOverlayOpen = false;
  bool get isPartsOverlayOpen => _isPartsOverlayOpen;

  // Hierarchy dialog open state (used to disable iframe pointer-events)
  bool _isHierarchyDialogOpen = false;
  bool get isHierarchyDialogOpen => _isHierarchyDialogOpen;
  void openHierarchyDialog() {
    _isHierarchyDialogOpen = true;
    notifyListeners();
  }

  void closeHierarchyDialog() {
    _isHierarchyDialogOpen = false;
    notifyListeners();
  }

  double _partDistance = 0.4;
  double get partDistance => _partDistance;

  bool _isRightSidebarVisible = false;
  bool get isRightSidebarVisible =>
      _isAssembleMode ? false : _isRightSidebarVisible;

  /// Item code of the last clicked part — used to resolve single-part OBJ for sidebar 3D viewer.
  String? _selectedItemCode;
  String? get selectedItemCode => _selectedItemCode;

  /// Sub-assembly code currently focused (e.g. 'SA-F05-01').
  /// When non-null, the sidebar shows that sub-assembly's parts list.
  String? _focusedSubAssembly;
  String? get focusedSubAssembly => _focusedSubAssembly;

  bool get isSubAssemblyFocused => _focusedSubAssembly != null;

  bool _isMotorcycleShowcaseCollapsed = false;
  bool get isMotorcycleShowcaseCollapsed => _isMotorcycleShowcaseCollapsed;

  // ── Phase 5: parts hierarchy ────────────────────────────────────────────
  PartsHierarchy? _partsHierarchy;
  PartsHierarchy? get partsHierarchy => _partsHierarchy;

  /// Groups whose parts are expanded/visible in the tree
  final Set<String> _expandedGroups = {};
  Set<String> get expandedGroups => Set.unmodifiable(_expandedGroups);

  /// Groups whose 3D parts have been requested to load in the viewer
  final Set<String> _loadedGroups = {};
  Set<String> get loadedGroups => Set.unmodifiable(_loadedGroups);

  /// Groups currently loading (progress indicator)
  final Set<String> _loadingGroups = {};
  Set<String> get loadingGroups => Set.unmodifiable(_loadingGroups);

  /// The most recent group-load command sent to the viewer.
  HierarchyGroupLoadCommand? _groupLoadCommand;
  HierarchyGroupLoadCommand? get groupLoadCommand => _groupLoadCommand;

  /// The most recent single-part-load command sent to the viewer.
  HierarchyPartLoadCommand? _partLoadCommand;
  HierarchyPartLoadCommand? get partLoadCommand => _partLoadCommand;

  /// Phase 5: the PartItem currently selected from the hierarchy tree.
  PartItem? _selectedPartItem;
  PartItem? get selectedPartItem => _selectedPartItem;

  bool get has3DModel => _currentMotorcycle?.has3DModel ?? false;

  List<MotorcycleModel> _motorcycles = [];

  List<MotorcycleModel> get motorcycles => _motorcycles;

  /// The [MotorcycleModel] matching [_selectedMotorcycle], or the first entry
  /// when no match is found (guards against empty state).
  MotorcycleModel? get _currentMotorcycle {
    if (_motorcycles.isEmpty) return null;
    return _motorcycles.firstWhere(
      (m) => m.name == _selectedMotorcycle,
      orElse: () => _motorcycles.first,
    );
  }

  // Resolved explosion model paths for the current motorcycle (auto-discovered)
  List<String> _explosionObjPaths = [];
  List<String?> _explosionMtlPaths = [];

  // ── Per-motorcycle parts catalog ─────────────────────────────────────────
  List<Map<String, dynamic>> _catalogGroups = [];

  /// Finds a part in the active catalog by item_code.
  Map<String, dynamic>? _findCatalogItem(String itemCode) {
    for (final group in _catalogGroups) {
      final items = group['items'] as List? ?? [];
      for (final raw in items) {
        final item = Map<String, dynamic>.from(raw as Map);
        if (item['item_code'] == itemCode) return item;
      }
    }
    return null;
  }

  /// Finds the group containing [itemCode] in the catalog.
  Map<String, dynamic>? _findCatalogGroupForItem(String itemCode) {
    for (final group in _catalogGroups) {
      final items = group['items'] as List? ?? [];
      for (final raw in items) {
        final item = Map<String, dynamic>.from(raw as Map);
        if (item['item_code'] == itemCode) {
          return Map<String, dynamic>.from(group);
        }
      }
    }
    return null;
  }

  Future<void> initialize() async {
    try {
      final response = await _motorcycleService.getMotorcycles();
      _motorcycles = response.motorcycles.map(MotorcycleModel.fromMap).toList();
      // Default to first motorcycle so the viewer is never empty.
      if (_motorcycles.isNotEmpty) {
        _selectedMotorcycle = _motorcycles.first.name;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading motorcycle data: $e');
    }

    // Auto-discover explosion models, load hierarchy and catalog in parallel.
    await Future.wait([
      _discoverExplosionModels(),
      _loadPartsHierarchy(),
      _loadCatalog(),
    ]);
  }

  /// Scans `assets/models/{modelKey}/` for `*_assembled.obj` files.
  /// Adding a new motorcycle's exports to that folder is all that is needed.
  Future<void> _discoverExplosionModels() async {
    final key = _currentMotorcycle?.modelKey;
    if (!hasExplosionModels || key == null) return;
    final objs = await _motorcycleService.getLocalExplosionModels(key);
    final mtls = await Future.wait(objs.map(_motorcycleService.mtlForObj));
    _explosionObjPaths = objs;
    _explosionMtlPaths = mtls;
    notifyListeners();
  }

  /// Loads the parts catalog for the current motorcycle.
  /// The path is declared in [MotorcycleModel.catalogAsset] — no code changes
  /// are needed when adding a new motorcycle with its own catalog.
  Future<void> _loadCatalog() async {
    _catalogGroups = [];
    final assetPath = _currentMotorcycle?.catalogAsset;
    if (assetPath == null) return;
    try {
      final raw = await rootBundle.loadString(assetPath);
      final data = Map<String, dynamic>.from(json.decode(raw) as Map);
      final groups = data['groups'] as List? ?? [];
      _catalogGroups =
          groups.map((g) => Map<String, dynamic>.from(g as Map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load parts catalog for $_selectedMotorcycle: $e');
    }
  }

  /// Loads the parts hierarchy for the current motorcycle.
  /// The path is declared in [MotorcycleModel.hierarchyAsset].
  Future<void> _loadPartsHierarchy() async {
    _partsHierarchy = null;
    final assetPath = _currentMotorcycle?.hierarchyAsset;
    if (assetPath == null) return;
    try {
      final raw = await rootBundle.loadString(assetPath);
      _partsHierarchy = PartsHierarchy.fromMap(
          Map<String, dynamic>.from(json.decode(raw) as Map));
      notifyListeners();
    } catch (_) {
      // Asset not yet bundled — hierarchy will be null until it is.
    }
  }

  List<String> get engineSpecs => _currentMotorcycle?.engineSpecs ?? [];

  List<String> get accessoriesSpecs =>
      _currentMotorcycle?.accessoriesSpecs ?? [];

  Map<String, dynamic> get currentPartData {
    final parts = _currentMotorcycle?.parts ?? {};

    if (_selectedPart != null) {
      // Direct display-name key lookup (from parts overlay)
      if (parts.containsKey(_selectedPart)) {
        return Map<String, dynamic>.from(parts[_selectedPart] as Map);
      }
      // Search by item_code / internal_code in motorcycles_data.json
      final code = _selectedPartItem?.modelCode ?? _selectedPart!;
      for (final value in parts.values) {
        final partData = Map<String, dynamic>.from(value as Map);
        if (partData['item_code'] == code ||
            partData['internal_code'] == code) {
          return partData;
        }
      }
    }

    // Look up by _selectedItemCode in the active parts catalog
    final lookupCode = _selectedItemCode ?? _selectedPart;
    if (lookupCode != null && _catalogGroups.isNotEmpty) {
      final item = _findCatalogItem(lookupCode);
      if (item != null) {
        final group = _findCatalogGroupForItem(lookupCode);
        final rawType = item['part_type'] as String? ?? '';
        final category = rawType.replaceAll('_', ' ').toUpperCase();
        return {
          'name': item['description'] as String? ?? lookupCode,
          'displayName': item['description'] as String? ?? lookupCode,
          'label': group?['part_type']
                  ?.toString()
                  .replaceAll('_', ' ')
                  .toUpperCase() ??
              '',
          'category': category,
          'groupNo': group?['group'] as String? ?? '',
          'sku': item['item_code'] as String? ?? '',
          'partNo': item['id'] as String? ?? item['item_code'] as String? ?? '',
          'quantity': (item['quantity'] as num?)?.toInt() ?? 1,
          'description': group?['group_header'] as String? ?? '',
          'imageUrl': '',
          'sub_assembly': item['sub_assembly'] as String? ?? '',
        };
      }
    }

    return {};
  }

  // Parts models mapping from current motorcycle
  Map<String, Map<String, String>> get partsModels {
    final parts = _currentMotorcycle?.parts ?? {};
    return parts.map((key, value) {
      final partData = Map<String, dynamic>.from(value as Map);
      return MapEntry(
        key,
        {
          'displayName': partData['displayName'] as String? ?? key,
          'obj': partData['obj'] as String? ?? '',
          'mtl': partData['mtl'] as String? ?? '',
          'item_code': partData['item_code'] as String? ?? '',
          'sub_assembly': partData['sub_assembly'] as String? ?? '',
        },
      );
    });
  }

  /// Metadata passed to the 3D viewer for rich tooltips.
  /// Keyed by OBJ filename (no extension) → {item_code, description, displayName}.
  Map<String, Map<String, String>> get partsMeta {
    final parts = _currentMotorcycle?.parts ?? {};
    final result = <String, Map<String, String>>{};
    for (final entry in parts.entries) {
      final partData = Map<String, dynamic>.from(entry.value as Map);
      final objUrl = partData['obj'] as String? ?? '';
      if (objUrl.isEmpty) continue;
      final key = objUrl
          .split('/')
          .last
          .replaceAll(RegExp(r'\.(obj|glb|gltf)$', caseSensitive: false), '');
      result[key] = {
        'item_code': partData['item_code'] as String? ?? '',
        'description': partData['description'] as String? ?? '',
        'displayName': partData['displayName'] as String? ?? entry.key,
      };
    }
    return result;
  }

  /// All parts whose sub_assembly field matches [saCode].
  /// Uses the active catalog when available, falling back to the inline
  /// parts map from motorcycles_data.json.
  List<Map<String, String>> partsForSubAssembly(String saCode) {
    if (hasExplosionModels && _catalogGroups.isNotEmpty) {
      final results = <Map<String, String>>[];
      for (final group in _catalogGroups) {
        final items = group['items'] as List? ?? [];
        for (final raw in items) {
          final item = Map<String, dynamic>.from(raw as Map);
          if (item['sub_assembly'] == saCode) {
            final code = item['item_code'] as String? ?? '';
            results.add({
              'item_code': code,
              'displayName': item['description'] as String? ?? code,
              'obj': code.isNotEmpty ? 'assets/Objects/$code.obj' : '',
              'mtl': code.isNotEmpty ? 'assets/Objects/$code.mtl' : '',
              'sub_assembly': saCode,
            });
          }
        }
      }
      return results;
    }
    return partsModels.values
        .where((m) => m['sub_assembly'] == saCode)
        .toList();
  }

  /// OBJ/MTL paths for the focused sub-assembly 3D viewer.
  /// Returns empty string when no sub-assembly is focused.
  String get focusedSubAssemblyObjPath => _focusedSubAssembly != null
      ? 'assets/Objects/$_focusedSubAssembly.obj'
      : '';

  String? get focusedSubAssemblyMtlPath => _focusedSubAssembly != null
      ? 'assets/Objects/$_focusedSubAssembly.mtl'
      : null;

  /// OBJ path for the currently selected individual part (for sidebar 3D viewer).
  String get selectedPartSingleObjPath {
    if (_selectedItemCode != null) {
      if (hasExplosionModels) return 'assets/Objects/$_selectedItemCode.obj';
    }
    return partsModels[_selectedPart]?['obj'] ?? '';
  }

  String? get selectedPartSingleMtlPath {
    if (_selectedItemCode != null) {
      if (hasExplosionModels) return 'assets/Objects/$_selectedItemCode.mtl';
    }
    final mtl = partsModels[_selectedPart]?['mtl'];
    return (mtl != null && mtl.isNotEmpty) ? mtl : null;
  }

  String get assembleModelPath {
    if (!has3DModel) return '';
    final path = _currentMotorcycle?.assembleObjPath;
    return path != null ? '$_assetsBaseUrl/$path' : '';
  }

  String? get assembleMtlPath {
    if (!has3DModel) return null;
    final path = _currentMotorcycle?.assembleMtlPath;
    return path != null ? '$_assetsBaseUrl/$path' : null;
  }

  List<String> get allAssemblyModelPaths {
    if (!has3DModel) return [];
    return [assembleModelPath];
  }

  List<String?> get allAssemblyMtlPaths {
    if (!has3DModel) return [];
    return [assembleMtlPath];
  }

  /// True when this motorcycle has Blender-exported per-group explosion OBJs
  /// in `assets/models/{modelKey}/`. Declared per-motorcycle in the JSON data.
  bool get hasExplosionModels =>
      _currentMotorcycle?.hasExplosionModels ?? false;

  List<String> get allDisassemblyModelPaths {
    if (!has3DModel) return [];
    if (hasExplosionModels) return _explosionObjPaths;
    return partsModels.values.map((m) => m['obj']!).toList(growable: false);
  }

  List<String?> get allDisassemblyMtlPaths {
    if (!has3DModel) return [];
    if (hasExplosionModels) return _explosionMtlPaths;
    return partsModels.values
        .map(
            (m) => (m['mtl'] != null && m['mtl']!.isNotEmpty) ? m['mtl'] : null)
        .toList(growable: false);
  }

  String get partsLabel =>
      currentPartData['label'] as String? ?? _selectedPartItem?.partType ?? '';
  String get partsImageUrl => currentPartData['imageUrl'] as String? ?? '';
  String get partsName =>
      currentPartData['name'] as String? ??
      _selectedPartItem?.displayName ??
      'Unknown Part';
  String get partsSku =>
      currentPartData['sku'] as String? ?? _selectedPartItem?.itemCode ?? '';
  String get partsCategory =>
      currentPartData['category'] as String? ??
      _selectedPartItem?.partType ??
      '';
  String get partsGroupNo =>
      currentPartData['groupNo'] as String? ??
      _selectedPartItem?.subAssembly ??
      '';
  String get partsPartNo =>
      currentPartData['partNo'] as String? ??
      _selectedPartItem?.itemCode ??
      _selectedPartItem?.internalCode ??
      '';
  int get partsQuantity =>
      currentPartData['quantity'] as int? ?? _selectedPartItem?.quantity ?? 0;
  String get partsDescription =>
      currentPartData['description'] as String? ??
      _selectedPartItem?.description ??
      '';

  Future<void> toggleMode(bool isAssemble) async {
    _isAssembleMode = isAssemble;

    if (isAssemble) {
      _selectedPart = null;
      _selectedPartItem = null;
      _isRightSidebarVisible = false;
    } else {
      _partDistance = 0.4;
    }

    notifyListeners();
  }

  Future<void> selectMotorcycle(String motorcycleName) async {
    if (_selectedMotorcycle == motorcycleName) return;

    _selectedMotorcycle = motorcycleName;
    _selectedPart = null;
    _selectedPartItem = null;
    _isRightSidebarVisible = false;
    _isAssembleMode = true;
    _expandedGroups.clear();
    _loadedGroups.clear();
    _loadingGroups.clear();
    _groupLoadCommand = null;
    _partLoadCommand = null;
    _explosionObjPaths = [];
    _explosionMtlPaths = [];
    _catalogGroups = [];
    _partsHierarchy = null;
    notifyListeners();

    setBusy(true);
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1000)),
      _discoverExplosionModels(),
      _loadCatalog(),
      _loadPartsHierarchy(),
    ]);
    setBusy(false);
  }

  Future<void> selectPart(String partName) async {
    if (!_isAssembleMode && _selectedPart == partName) return;

    _isAssembleMode = false;
    _selectedPart = partName;
    _isPartsOverlayOpen = false;
    _isRightSidebarVisible = true;
    _focusedSubAssembly = null;
    notifyListeners();

    setBusy(true);
    await Future.delayed(const Duration(milliseconds: 600));
    setBusy(false);
  }

  /// Select a part by item_code (from assembled OBJ mesh click).
  /// SA- codes switch to sub-assembly focus mode (main viewer replaced).
  /// Regular codes find and select the matching part.
  Future<void> selectPartByCode(String itemCode, {String? displayName}) async {
    _selectedItemCode = itemCode;
    // Sub-assembly codes start with 'SA-'
    if (itemCode.startsWith('SA-')) {
      _focusedSubAssembly = itemCode;
      _isAssembleMode = false;
      // Close/hide right sidebar — sub-assembly is shown in main area
      _isRightSidebarVisible = false;
      _selectedPart = null;
      notifyListeners();
      return;
    }
    String? matchedKey;
    partsModels.forEach((k, v) {
      if (v['item_code'] == itemCode) matchedKey = k;
    });
    if (matchedKey != null) {
      return selectPart(matchedKey!);
    }
    return selectPart(displayName ?? itemCode);
  }

  void clearSubAssemblyFocus() {
    _focusedSubAssembly = null;
    _selectedPart = null;
    _selectedItemCode = null;
    _partDistance = 0.4;
    // Return to full disassembly view (don't go back to assemble mode)
    notifyListeners();
  }

  void togglePartsOverlay() {
    _isPartsOverlayOpen = !_isPartsOverlayOpen;
    notifyListeners();
  }

  /// Phase 5: select a leaf part from the hierarchy tree.
  void selectPartItemFromTree(String partId, PartItem item) {
    _selectedPart = partId;
    _selectedPartItem = item;
    _isRightSidebarVisible = true;
    notifyListeners();
  }

  /// Phase 5: clear selected part (go back to tree view).
  void clearSelectedPartItem() {
    _selectedPart = null;
    _selectedPartItem = null;
    notifyListeners();
  }

  void updatePartDistance(double distance) {
    _partDistance = distance;
    notifyListeners();
  }

  void toggleRightSidebar() {
    _isRightSidebarVisible = !_isRightSidebarVisible;
    if (!_isRightSidebarVisible) {
      _focusedSubAssembly = null;
      _selectedPart = null;
      _selectedItemCode = null;
    }
    notifyListeners();
  }

  void toggleMotorcycleShowcase() {
    _isMotorcycleShowcaseCollapsed = !_isMotorcycleShowcaseCollapsed;
    notifyListeners();
  }

  // ── Phase 5: hierarchy tree methods ─────────────────────────────────────

  /// Expand a group in the tree. If not yet loaded, sends a load command to
  /// the 3D viewer. Safe to call multiple times (idempotent after first load).
  void expandGroup(String groupCode) {
    _expandedGroups.add(groupCode);
    notifyListeners();

    if (!_loadedGroups.contains(groupCode) &&
        !_loadingGroups.contains(groupCode)) {
      _requestGroupLoad(groupCode);
    }
  }

  void collapseGroup(String groupCode) {
    _expandedGroups.remove(groupCode);
    notifyListeners();
  }

  void _requestGroupLoad(String groupCode) {
    final group =
        _partsHierarchy?.groups.where((g) => g.group == groupCode).firstOrNull;
    if (group == null) return;

    _loadingGroups.add(groupCode);
    notifyListeners();

    final parts = group.loadableItems.map((item) {
      final objUrl = _getPartObjUrl(item.modelCode!);
      final mtlUrl = _getPartMtlUrl(item.modelCode!);
      return HierarchyPartLoad(
        partId: item.id ?? item.modelCode!,
        objUrl: objUrl,
        mtlUrl: mtlUrl,
      );
    }).toList();

    _groupLoadCommand =
        HierarchyGroupLoadCommand(groupCode: groupCode, parts: parts);
    notifyListeners();
  }

  /// Called by the view when the viewer reports a group finished loading.
  void onGroupLoaded(String groupCode) {
    _loadingGroups.remove(groupCode);
    _loadedGroups.add(groupCode);
    notifyListeners();
  }

  /// Load a single part on demand (e.g., user taps a part in the tree).
  void loadPartOnDemand(String partId, String modelCode) {
    _partLoadCommand = HierarchyPartLoadCommand(
      partId: partId,
      objUrl: _getPartObjUrl(modelCode),
      mtlUrl: _getPartMtlUrl(modelCode),
    );
    notifyListeners();
  }

  bool isGroupExpanded(String groupCode) => _expandedGroups.contains(groupCode);
  bool isGroupLoaded(String groupCode) => _loadedGroups.contains(groupCode);
  bool isGroupLoading(String groupCode) => _loadingGroups.contains(groupCode);

  // ── URL helpers (swap these for real BE endpoints when ready) ────────────
  String _getPartObjUrl(String modelCode) {
    // TODO: Replace with real API endpoint when BE is ready.
    return '$_assetsBaseUrl/parts/$modelCode.obj';
  }

  String? _getPartMtlUrl(String modelCode) {
    return '$_assetsBaseUrl/parts/$modelCode.mtl';
  }

  void resetToAssembleMode() {
    _isAssembleMode = true;
    _selectedPart = null;
    _isRightSidebarVisible = false;
    notifyListeners();
  }
}
