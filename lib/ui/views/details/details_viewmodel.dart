import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:project_micah/models/category_model.dart';

class DetailsViewModel extends BaseViewModel {
  // AWS S3 base URL for assets
  static const String _assetsBaseUrl =
      'https://micah-assets.s3.us-east-1.amazonaws.com/assets';

  // Mode: true = assemble (full motorcycle), false = disassemble (parts view)
  bool _isAssembleMode = true;
  bool get isAssembleMode => _isAssembleMode;

  // Selected motorcycle from the categories list
  String _selectedMotorcycle = 'BLT150';
  String get selectedMotorcycle => _selectedMotorcycle;

  // Selected part (when in disassemble mode)
  String? _selectedPart;
  String? get selectedPart => _selectedPart;

  // Parts overlay state
  bool _isPartsOverlayOpen = false;
  bool get isPartsOverlayOpen => _isPartsOverlayOpen;

  // Part distance (for display near toggle)
  double _partDistance = 2;
  double get partDistance => _partDistance;

  // Right sidebar visibility
  bool _isRightSidebarVisible = false;
  bool get isRightSidebarVisible =>
      _isAssembleMode ? false : _isRightSidebarVisible;

  // Motorcycle showcase collapse state
  bool _isMotorcycleShowcaseCollapsed = false;
  bool get isMotorcycleShowcaseCollapsed => _isMotorcycleShowcaseCollapsed;

  // Check if current motorcycle has 3D model
  bool get has3DModel {
    if (_motorcycles.isEmpty) return false;
    final motorcycle = _motorcycles.firstWhere(
      (m) => m.name == _selectedMotorcycle,
      orElse: () => _motorcycles.first,
    );
    return motorcycle.has3DModel;
  }

  // List of available motorcycles (displayed as categories)
  List<CategoryModel> _motorcycles = [];
  Map<String, dynamic> _motorcycleData = {};

  List<CategoryModel> get motorcycles => _motorcycles;

  // Initialize and load motorcycle data from JSON
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
  }

  Map<String, dynamic> get _currentMotorcycleData {
    final motorcycles = _motorcycleData['motorcycles'] as List? ?? [];
    return motorcycles.firstWhere(
      (m) => m['name'] == _selectedMotorcycle,
      orElse: () => motorcycles.isNotEmpty ? motorcycles.first : {},
    ) as Map<String, dynamic>;
  }

  // Specifications data for the selected motorcycle
  // Engine specifications
  List<String> get engineSpecs {
    final specs = _currentMotorcycleData['engineSpecs'] as List?;
    return specs?.cast<String>() ?? [];
  }

  // Accessories specifications
  List<String> get accessoriesSpecs {
    final specs = _currentMotorcycleData['accessoriesSpecs'] as List?;
    return specs?.cast<String>() ?? [];
  }

  // Parts data (displayed when a specific part is selected in disassemble mode)
  Map<String, dynamic> get currentPartData {
    final parts =
        _currentMotorcycleData['parts'] as Map<String, dynamic>? ?? {};
    if (_selectedPart != null && parts.containsKey(_selectedPart)) {
      return parts[_selectedPart] as Map<String, dynamic>;
    }
    // Return first part or empty map
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

  // Assembly model paths (dynamically determined by selected motorcycle)
  String get assembleModelPath {
    if (!has3DModel) return '';

    // Map motorcycle names to their assembly model paths
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

    // Map motorcycle names to their assembly MTL paths
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

  // Get all assembly model paths (for preloading)
  List<String> get allAssemblyModelPaths {
    if (!has3DModel) return [];
    return [assembleModelPath];
  }

  // Get all assembly MTL paths
  List<String?> get allAssemblyMtlPaths {
    if (!has3DModel) return [];
    return [assembleMtlPath];
  }

  // Get all disassembly model paths (for preloading)
  List<String> get allDisassemblyModelPaths {
    if (!has3DModel) return [];
    return partsModels.values.map((m) => m['obj']!).toList(growable: false);
  }

  // Get all disassembly MTL paths
  List<String?> get allDisassemblyMtlPaths {
    if (!has3DModel) return [];
    return partsModels.values
        .map(
            (m) => (m['mtl'] != null && m['mtl']!.isNotEmpty) ? m['mtl'] : null)
        .toList(growable: false);
  }

  // Getters for current part details (used in UI)
  String get partsLabel => currentPartData['label'] as String? ?? '';
  String get partsImageUrl => currentPartData['imageUrl'] as String? ?? '';
  String get partsName => currentPartData['name'] as String? ?? 'Unknown Part';
  String get partsSku => currentPartData['sku'] as String? ?? '';
  String get partsCategory => currentPartData['category'] as String? ?? '';
  String get partsGroupNo => currentPartData['groupNo'] as String? ?? '';
  String get partsPartNo => currentPartData['partNo'] as String? ?? '';
  int get partsQuantity => currentPartData['quantity'] as int? ?? 0;
  String get partsDescription =>
      currentPartData['description'] as String? ?? '';

  // Toggle between assemble and disassemble modes
  Future<void> toggleMode(bool isAssemble) async {
    _isAssembleMode = isAssemble;

    // Clear selected part when switching to assemble mode
    if (isAssemble) {
      _selectedPart = null;
      _isRightSidebarVisible = false;
    }

    notifyListeners();

    // NO LONGER NEEDED: The 3D viewer now preloads both modes
    // Models are already loaded, just toggling visibility
    // No simulated API call needed anymore
  }

  // Select a motorcycle from the categories list
  Future<void> selectMotorcycle(String motorcycleName) async {
    if (_selectedMotorcycle == motorcycleName) return;

    _selectedMotorcycle = motorcycleName;
    _selectedPart = null; // Reset selected part
    _isRightSidebarVisible =
        false; // Close right sidebar when selecting new motorcycle
    _isAssembleMode = true; // Reset to assemble mode when switching motorcycles
    notifyListeners();

    // Simulate API call to fetch motorcycle details
    setBusy(true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setBusy(false);
  }

  // Select a part in disassemble mode (e.g., clicked on 3D part)
  Future<void> selectPart(String partName) async {
    if (!_isAssembleMode && _selectedPart == partName) return;

    _selectedPart = partName;
    _isPartsOverlayOpen = false; // Close overlay when part is selected
    _isRightSidebarVisible = true; // Open right sidebar when part is selected
    notifyListeners();

    // Simulate API call to fetch part details
    setBusy(true);
    await Future.delayed(const Duration(milliseconds: 600));
    setBusy(false);
  }

  // Toggle parts overlay
  void togglePartsOverlay() {
    _isPartsOverlayOpen = !_isPartsOverlayOpen;
    notifyListeners();
  }

  // Update part distance
  void updatePartDistance(double distance) {
    _partDistance = distance;
    notifyListeners();
  }

  // Toggle right sidebar visibility
  void toggleRightSidebar() {
    _isRightSidebarVisible = !_isRightSidebarVisible;
    notifyListeners();
  }

  void toggleMotorcycleShowcase() {
    _isMotorcycleShowcaseCollapsed = !_isMotorcycleShowcaseCollapsed;
    notifyListeners();
  }

  // Reset to assemble mode (called when R key is pressed)
  void resetToAssembleMode() {
    _isAssembleMode = true;
    _selectedPart = null;
    _isRightSidebarVisible = false;
    notifyListeners();
  }
}
