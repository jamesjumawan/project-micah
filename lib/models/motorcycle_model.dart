/// Data model for a single motorcycle entry.
///
/// All motorcycle-specific configuration (asset paths, catalog locations,
/// explosion-model flags) lives here so that adding a new motorcycle requires
/// only a JSON update — no Dart code changes.
class MotorcycleModel {
  final String name;
  final String imageUrl;
  final bool has3DModel;

  /// Slug used to scope asset sub-folders, e.g. `'BLT150'`.
  /// Used as the prefix when scanning `assets/models/{modelKey}/` for
  /// explosion OBJs and when building S3 paths.
  final String? modelKey;

  /// S3-relative path to the fully-assembled OBJ, e.g.
  /// `'sample_3d_object/blt150_01.obj'`.
  final String? assembleObjPath;

  /// S3-relative path to the fully-assembled MTL.
  final String? assembleMtlPath;

  /// Local Flutter asset path to this motorcycle's parts-catalog JSON,
  /// e.g. `'assets/data/blt150_parts_catalog.json'`.
  /// Null when no catalog has been prepared yet.
  final String? catalogAsset;

  /// Local Flutter asset path to this motorcycle's parts-hierarchy JSON,
  /// e.g. `'assets/data/blt150_parts_hierarchy.json'`.
  /// Null when no hierarchy has been prepared yet.
  final String? hierarchyAsset;

  /// True when this motorcycle has Blender-exported per-group explosion OBJs
  /// located in `assets/models/{modelKey}/`.
  final bool hasExplosionModels;

  /// Engine component labels shown in the parts overlay.
  final List<String> engineSpecs;

  /// Accessories labels shown in the parts overlay.
  final List<String> accessoriesSpecs;

  /// Raw display-name → part-data map sourced from `motorcycles_data.json`.
  /// Used as a fallback when no dedicated catalog asset is available.
  final Map<String, dynamic> parts;

  const MotorcycleModel({
    required this.name,
    required this.imageUrl,
    this.has3DModel = false,
    this.modelKey,
    this.assembleObjPath,
    this.assembleMtlPath,
    this.catalogAsset,
    this.hierarchyAsset,
    this.hasExplosionModels = false,
    this.engineSpecs = const [],
    this.accessoriesSpecs = const [],
    this.parts = const {},
  });

  factory MotorcycleModel.fromMap(Map<String, dynamic> map) => MotorcycleModel(
        name: map['name'] as String? ?? '',
        imageUrl: map['imageUrl'] as String? ?? '',
        has3DModel: map['has3DModel'] as bool? ?? false,
        modelKey: map['modelKey'] as String?,
        assembleObjPath: map['assembleObjPath'] as String?,
        assembleMtlPath: map['assembleMtlPath'] as String?,
        catalogAsset: map['catalogAsset'] as String?,
        hierarchyAsset: map['hierarchyAsset'] as String?,
        hasExplosionModels: map['hasExplosionModels'] as bool? ?? false,
        engineSpecs: ((map['engineSpecs'] as List?) ?? []).cast<String>(),
        accessoriesSpecs:
            ((map['accessoriesSpecs'] as List?) ?? []).cast<String>(),
        parts: map['parts'] != null
            ? Map<String, dynamic>.from(map['parts'] as Map)
            : const {},
      );
}
