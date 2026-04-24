import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:project_micah/models/category_model.dart';
import 'package:project_micah/models/hierarchy_load_command.dart';
import 'package:project_micah/models/parts_hierarchy_model.dart';

class DetailsViewModel extends BaseViewModel {
  static const String _assetsBaseUrl =
      'https://micah-assets.s3.us-east-1.amazonaws.com/assets';

  bool _isAssembleMode = true;
  bool get isAssembleMode => _isAssembleMode;

  String _selectedMotorcycle = 'BLT150';
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

  double _partDistance = 2;
  double get partDistance => _partDistance;

  bool _isRightSidebarVisible = false;
  bool get isRightSidebarVisible =>
      _isAssembleMode ? false : _isRightSidebarVisible;

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

  bool get has3DModel {
    if (_motorcycles.isEmpty) return false;
    final motorcycle = _motorcycles.firstWhere(
      (m) => m.name == _selectedMotorcycle,
      orElse: () => _motorcycles.first,
    );
    return motorcycle.has3DModel;
  }

  List<CategoryModel> _motorcycles = [];
  Map<String, dynamic> _motorcycleData = {};

  List<CategoryModel> get motorcycles => _motorcycles;

  Future<void> initialize() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/motorcycles_data.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      _motorcycles = (data['motorcycles'] as List)
          .map((m) => CategoryModel.fromMap(m as Map<String, dynamic>))
          .toList();

      _motorcycleData = data;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading motorcycle data: $e');
    }

    // Load Phase 5 parts hierarchy (fire-and-forget)
    _loadPartsHierarchy();
  }

  Future<void> _loadPartsHierarchy() async {
    try {
      // TODO: Replace with API call when BE is ready.
      // Expected endpoint: GET /api/parts/hierarchy?model=BLT150
      // For now, load from bundled asset if present.
      const assetPath = 'assets/data/parts_hierarchy.json';
      final raw = await rootBundle.loadString(assetPath);
      _partsHierarchy =
          PartsHierarchy.fromMap(json.decode(raw) as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      // Asset not yet bundled — hierarchy will be null until BE provides it
    }
  }

  Map<String, dynamic> get _currentMotorcycleData {
    final motorcycles = _motorcycleData['motorcycles'] as List? ?? [];
    return motorcycles.firstWhere(
      (m) => m['name'] == _selectedMotorcycle,
      orElse: () => motorcycles.isNotEmpty ? motorcycles.first : {},
    ) as Map<String, dynamic>;
  }

  List<String> get engineSpecs {
    final specs = _currentMotorcycleData['engineSpecs'] as List?;
    return specs?.cast<String>() ?? [];
  }

  List<String> get accessoriesSpecs {
    final specs = _currentMotorcycleData['accessoriesSpecs'] as List?;
    return specs?.cast<String>() ?? [];
  }

  Map<String, dynamic> get currentPartData {
    final parts =
        _currentMotorcycleData['parts'] as Map<String, dynamic>? ?? {};
    if (_selectedPart != null) {
      // Phase 4: direct display-name key lookup
      if (parts.containsKey(_selectedPart)) {
        return parts[_selectedPart] as Map<String, dynamic>;
      }
      // Phase 5: _selectedPart is item_code/id — search by code
      final code = _selectedPartItem?.modelCode ?? _selectedPart!;
      for (final value in parts.values) {
        final partData = value as Map<String, dynamic>;
        if (partData['item_code'] == code ||
            partData['internal_code'] == code) {
          return partData;
        }
      }
    }
    return parts.isNotEmpty ? parts.values.first as Map<String, dynamic> : {};
  }

  // Parts models mapping from current motorcycle
  Map<String, Map<String, String>> get partsModels {
    final parts =
        _currentMotorcycleData['parts'] as Map<String, dynamic>? ?? {};
    return parts.map((key, value) {
      final partData = value as Map<String, dynamic>;
      return MapEntry(
        key,
        {
          'displayName': partData['displayName'] as String? ?? key,
          'obj': partData['obj'] as String? ?? '',
          'mtl': partData['mtl'] as String? ?? '',
        },
      );
    });
  }

  String get assembleModelPath {
    if (!has3DModel) return '';

    switch (_selectedMotorcycle) {
      case 'BLT150':
        return '$_assetsBaseUrl/sample_3d_object/blt150_01.obj';
      case 'Blink 124':
        return '$_assetsBaseUrl/sample_3d_object/blink124.obj';
      case 'Wizard 125':
        return '$_assetsBaseUrl/sample_3d_object/wizard125.obj';
      case 'King 150':
        return '$_assetsBaseUrl/sample_3d_object/king150.obj';
      default:
        return '';
    }
  }

  String? get assembleMtlPath {
    if (!has3DModel) return null;

    switch (_selectedMotorcycle) {
      case 'BLT150':
        return '$_assetsBaseUrl/sample_3d_object/blt150_01.mtl';
      case 'Blink 124':
        return '$_assetsBaseUrl/sample_3d_object/blink124.mtl';
      case 'Wizard 125':
        return '$_assetsBaseUrl/sample_3d_object/wizard125.mtl';
      case 'King 150':
        return '$_assetsBaseUrl/sample_3d_object/king150.mtl';
      default:
        return null;
    }
  }

  List<String> get allAssemblyModelPaths {
    if (!has3DModel) return [];
    return [assembleModelPath];
  }

  List<String?> get allAssemblyMtlPaths {
    if (!has3DModel) return [];
    return [assembleMtlPath];
  }

  List<String> get allDisassemblyModelPaths {
    if (!has3DModel) return [];
    return partsModels.values.map((m) => m['obj']!).toList(growable: false);
  }

  List<String?> get allDisassemblyMtlPaths {
    if (!has3DModel) return [];
    return partsModels.values
        .map(
            (m) => (m['mtl'] != null && m['mtl']!.isNotEmpty) ? m['mtl'] : null)
        .toList(growable: false);
  }

  String get partsLabel =>
      currentPartData['label'] as String? ?? _selectedPartItem?.partType ?? '';
  String get partsImageUrl => currentPartData['imageUrl'] as String? ?? '';
  String get partsName => currentPartData['name'] as String? ??
      _selectedPartItem?.displayName ??
      'Unknown Part';
  String get partsSku => currentPartData['sku'] as String? ??
      _selectedPartItem?.itemCode ??
      '';
  String get partsCategory => currentPartData['category'] as String? ??
      _selectedPartItem?.partType ??
      '';
  String get partsGroupNo => currentPartData['groupNo'] as String? ??
      _selectedPartItem?.subAssembly ??
      '';
  String get partsPartNo => currentPartData['partNo'] as String? ??
      _selectedPartItem?.itemCode ??
      _selectedPartItem?.internalCode ??
      '';
  int get partsQuantity =>
      currentPartData['quantity'] as int? ?? _selectedPartItem?.quantity ?? 0;
  String get partsDescription => currentPartData['description'] as String? ??
      _selectedPartItem?.description ??
      '';

  Future<void> toggleMode(bool isAssemble) async {
    _isAssembleMode = isAssemble;

    if (isAssemble) {
      _selectedPart = null;
      _selectedPartItem = null;
      _isRightSidebarVisible = false;
    } else {
      _partDistance = 2;
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
    notifyListeners();

    setBusy(true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setBusy(false);
  }

  Future<void> selectPart(String partName) async {
    if (!_isAssembleMode && _selectedPart == partName) return;

    _isAssembleMode = false;

    _selectedPart = partName;
    _isPartsOverlayOpen = false;
    _isRightSidebarVisible = true;
    notifyListeners();

    setBusy(true);
    await Future.delayed(const Duration(milliseconds: 600));
    setBusy(false);
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
