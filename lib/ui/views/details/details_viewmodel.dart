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
  String _selectedMotorcycle = 'Stallion';
  String get selectedMotorcycle => _selectedMotorcycle;

  // Selected part (when in disassemble mode)
  String? _selectedPart;
  String? get selectedPart => _selectedPart;

  // List of available motorcycles (displayed as categories)
  final List<CategoryModel> _motorcycles = [
    CategoryModel(
      name: 'Blink 124',
      imageUrl: 'assets/images/banner_decoration.png',
    ),
    CategoryModel(
      name: 'Hero',
      imageUrl: 'assets/images/banner_decoration.png',
    ),
    CategoryModel(
      name: 'Stallion',
      imageUrl: 'assets/images/banner_decoration.png',
    ),
    CategoryModel(
      name: 'King',
      imageUrl: 'assets/images/banner_decoration.png',
    ),
    CategoryModel(
      name: 'Hero 2',
      imageUrl: 'assets/images/banner_decoration.png',
    ),
    CategoryModel(
      name: 'King 2',
      imageUrl: 'assets/images/banner_decoration.png',
    ),
  ];

  List<CategoryModel> get motorcycles => _motorcycles;

  // Specifications data for the selected motorcycle
  // Engine specifications
  List<String> get engineSpecs {
    final specs = {
      'Stallion': [
        'Cylinder Block & Cylinder Head',
        'Camshaft & Valves',
        'Right Crankcase Cover',
        'Crankcase',
        'Oil Pump & Oil Filter',
        'Starting Motor',
        'Magneto',
        'Clutch',
        'Crankshaft & Piston',
        'Transmission Device',
        'Gearshift Device',
      ],
      'Blink 124': [
        'Cylinder Block & Cylinder Head',
        'Camshaft & Valves',
        'Crankcase',
        'Oil Pump & Oil Filter',
        'Clutch',
        'Crankshaft & Piston',
      ],
      'Hero': [
        'Cylinder Block & Cylinder Head',
        'Right Crankcase Cover',
        'Starting Motor',
        'Magneto',
        'Clutch',
        'Transmission Device',
      ],
      'King': [
        'Cylinder Block & Cylinder Head',
        'Camshaft & Valves',
        'Crankcase',
        'Starting Motor',
        'Clutch',
        'Gearshift Device',
      ],
    };
    return specs[_selectedMotorcycle] ?? specs['Stallion']!;
  }

  // Accessories specifications
  List<String> get accessoriesSpecs {
    final specs = {
      'Stallion': [
        'Headlight',
        'Meter Assembly',
        'Grip Switch & Cable',
        'Steering Bar',
        'Steering Stem Comp',
        'Front Fender',
        'Front Shock Absorber',
        'Front Wheel Assy',
        'Rear Brake',
        'Rear Wheel Assy',
        'Fuel Tank Assy',
      ],
      'Blink 124': [
        'Headlight',
        'Meter Assembly',
        'Steering Bar',
        'Front Fender',
        'Front Wheel Assy',
        'Rear Brake',
      ],
      'Hero': [
        'Headlight',
        'Grip Switch & Cable',
        'Steering Stem Comp',
        'Front Shock Absorber',
        'Rear Brake',
        'Fuel Tank Assy',
      ],
      'King': [
        'Meter Assembly',
        'Steering Bar',
        'Front Fender',
        'Front Wheel Assy',
        'Rear Wheel Assy',
        'Fuel Tank Assy',
      ],
    };
    return specs[_selectedMotorcycle] ?? specs['Stallion']!;
  }

  // Parts data (displayed when a specific part is selected in disassemble mode)
  Map<String, dynamic> get currentPartData {
    if (_selectedPart == null) {
      // Default to clutch
      return _partsDatabase['Clutch']!;
    }
    return _partsDatabase[_selectedPart] ?? _partsDatabase['Clutch']!;
  }

  // Simulated parts database
  final Map<String, Map<String, dynamic>> _partsDatabase = {
    'Clutch': {
      'label': 'CLUTCH',
      'imageUrl': 'assets/images/banner_decoration.png',
      'name': 'LOCATING PLATE',
      'sku': 'FW5119482155',
      'category': 'GEAR',
      'groupNo': 'E-08',
      'partNo': '2235L',
      'quantity': 1,
      'description':
          'Smooth wheel rotation and reduce friction for a stable, efficient ride. Built with high-quality steel, these bearings are designed to handle heavy loads and high speeds. They provide durability against heat, dust, and road impact.',
    },
    'Front Wheel': {
      'label': 'FRONT WHEEL',
      'imageUrl': 'assets/images/banner_decoration.png',
      'name': 'WHEEL BEARING',
      'sku': 'FW6541982341',
      'category': 'WHEEL',
      'groupNo': 'F-12',
      'partNo': '3456W',
      'quantity': 2,
      'description':
          'High-performance wheel bearing ensuring smooth rotation and minimal friction. Engineered for durability and long service life under various road conditions.',
    },
    'Rear Brake': {
      'label': 'REAR BRAKE',
      'imageUrl': 'assets/images/banner_decoration.png',
      'name': 'BRAKE SHOE',
      'sku': 'RB4412365478',
      'category': 'BRAKE',
      'groupNo': 'B-05',
      'partNo': '7821B',
      'quantity': 2,
      'description':
          'Premium brake shoe designed for optimal stopping power and safety. Made with heat-resistant composite materials for consistent performance.',
    },
    'Magneto': {
      'label': 'MAGNETO',
      'imageUrl': 'assets/images/banner_decoration.png',
      'name': 'IGNITION COIL',
      'sku': 'MG8821445566',
      'category': 'ELECTRICAL',
      'groupNo': 'E-03',
      'partNo': '5512M',
      'quantity': 1,
      'description':
          'High-quality ignition coil that generates the spark needed to ignite the fuel mixture. Built to withstand extreme temperatures and vibrations.',
    },
  };

  // Full assembly model paths

  final String assembleModelPath =
      '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_01.obj';
  final String assembleMtlPath =
      '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_01.mtl';

  // ================================================================================================================

  // final String assembleModelPath = 'assets/sample_3d_object/blt150_01.obj';
  // final String assembleMtlPath = 'assets/sample_3d_object/blt150_01.mtl';

  // ================================================================================================================

  // final String assembleModelPath =
  //     'assets/sample_3d_object/tripo_convert_36cdd4a4-d861-4834-acdf-ce8a7d82f620.obj';
  // final String assembleMtlPath =
  //     'assets/sample_3d_object/tripo_convert_36cdd4a4-d861-4834-acdf-ce8a7d82f620.mtl';

  // Parts models mapping. Keys should match part names used in the UI
  // Some parts may not have an associated .mtl (empty string)
  final Map<String, Map<String, String>> partsModels = {
    'Right Side Mirror': {
      'displayName': 'Right Side Mirror',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_02.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_02.mtl',
    },
    'Left Side Mirror': {
      'displayName': 'Left Side Mirror',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_03.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_03.mtl',
    },
    'Handle Bar': {
      'displayName': 'Handle Bar',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_04.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_04.mtl',
    },
    'Front Frame': {
      'displayName': 'Front Frame',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_05.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_05.mtl',
    },
    'Back Frame': {
      'displayName': 'Back Frame',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_06.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_06.mtl',
    },
    'Front Wheel': {
      'displayName': 'Front Wheel',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_07.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_07.mtl',
    },
    'Rear Fender': {
      'displayName': 'Rear Fender',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_08.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_08.mtl',
    },
    'Exhaust Pipe': {
      'displayName': '09',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_09.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_09.mtl',
    },
    'Rear Wheel': {
      'displayName': 'Rear Wheel',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_10.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_10.mtl',
    },
    'Rear Shock Absorber': {
      'displayName': 'Rear Shock Absorber',
      'obj': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_11.obj',
      'mtl': '$_assetsBaseUrl/sample_3d_object/manual_breaking/blt150_11.mtl',
    },

    // ================================================================================================================

    // 'Rear Shock': {
    //   'displayName': 'Rear Shock Absorber',
    //   'obj': 'assets/sample_3d_object/shock_absorber_01.obj',
    //   'mtl': 'assets/sample_3d_object/shock_absorber_01.mtl',
    // },
    // 'Rear Shock ': {
    //   'displayName': 'Rear Shock Absorber',
    //   'obj': 'assets/sample_3d_object/shock_absorber_02.obj',
    //   'mtl': 'assets/sample_3d_object/shock_absorber_02.mtl',
    // },
    // 'Clutch': {
    //   'displayName': 'Clutch Shoe',
    //   'obj': 'assets/sample_3d_object/clutch shoe final_fixed.obj',
    //   'mtl': '',
    // },

    // ================================================================================================================

    // 'Rear Shock': {
    //   'displayName': 'Rear Shock Absorber',
    //   'obj': 'assets/sample_3d_object/blt150_rearShockAbsorber_final_00.obj',
    //   'mtl': 'assets/sample_3d_object/blt150_rearShockAbsorber_final_00.mtl',
    // },
    // 'Clutch': {
    //   'displayName': 'Clutch Shoe',
    //   'obj': 'assets/sample_3d_object/clutch shoe final_fixed.obj',
    //   'mtl': '',
    // },
    // Add more part -> model mappings here as needed
  };

  // Get the correct model path for the current view state
  String get currentModelPath {
    if (_isAssembleMode) return assembleModelPath;
    if (_selectedPart != null && partsModels.containsKey(_selectedPart)) {
      return partsModels[_selectedPart]!['obj']!;
    }
    // Default to the first parts model if none selected
    return partsModels.values.first['obj']!;
  }

  // Get the corresponding mtl path if available
  String? get currentMtlPath {
    if (_isAssembleMode) return assembleMtlPath;
    if (_selectedPart != null && partsModels.containsKey(_selectedPart)) {
      final mtl = partsModels[_selectedPart]!['mtl'];
      return (mtl != null && mtl.isNotEmpty) ? mtl : null;
    }
    final defaultMtl = partsModels.values.first['mtl'];
    return (defaultMtl != null && defaultMtl.isNotEmpty) ? defaultMtl : null;
  }

  // Get plural model paths (useful for disassemble to show multiple models)
  List<String> get currentModelPaths {
    if (_isAssembleMode) return [assembleModelPath];
    // If a specific part is selected, return only that part
    if (_selectedPart != null && partsModels.containsKey(_selectedPart)) {
      return [partsModels[_selectedPart]!['obj']!];
    }
    // Otherwise return all available parts models
    return partsModels.values.map((m) => m['obj']!).toList(growable: false);
  }

  // Get corresponding mtl paths aligned with currentModelPaths
  List<String?> get currentMtlPaths {
    if (_isAssembleMode) return [assembleMtlPath];
    if (_selectedPart != null && partsModels.containsKey(_selectedPart)) {
      final mtl = partsModels[_selectedPart]!['mtl'];
      return [(mtl != null && mtl.isNotEmpty) ? mtl : null];
    }
    return partsModels.values
        .map(
            (m) => (m['mtl'] != null && m['mtl']!.isNotEmpty) ? m['mtl'] : null)
        .toList(growable: false);
  }

  // Get all assembly model paths (for preloading)
  List<String> get allAssemblyModelPaths => [assembleModelPath];

  // Get all assembly MTL paths
  List<String?> get allAssemblyMtlPaths => [assembleMtlPath];

  // Get all disassembly model paths (for preloading)
  List<String> get allDisassemblyModelPaths =>
      partsModels.values.map((m) => m['obj']!).toList(growable: false);

  // Get all disassembly MTL paths
  List<String?> get allDisassemblyMtlPaths => partsModels.values
      .map((m) => (m['mtl'] != null && m['mtl']!.isNotEmpty) ? m['mtl'] : null)
      .toList(growable: false);

  // Getters for current part details (used in UI)
  String get partsLabel => currentPartData['label'] as String;
  String get partsImageUrl => currentPartData['imageUrl'] as String;
  String get partsName => currentPartData['name'] as String;
  String get partsSku => currentPartData['sku'] as String;
  String get partsCategory => currentPartData['category'] as String;
  String get partsGroupNo => currentPartData['groupNo'] as String;
  String get partsPartNo => currentPartData['partNo'] as String;
  int get partsQuantity => currentPartData['quantity'] as int;
  String get partsDescription => currentPartData['description'] as String;

  // Toggle between assemble and disassemble modes
  Future<void> toggleMode(bool isAssemble) async {
    _isAssembleMode = isAssemble;
    _selectedPart = null; // Reset selected part when toggling
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
    notifyListeners();

    // Simulate API call to fetch part details
    setBusy(true);
    await Future.delayed(const Duration(milliseconds: 600));
    setBusy(false);
  }
}
