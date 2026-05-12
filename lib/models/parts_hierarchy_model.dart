class SubAssemblyRef {
  final String code;
  final String name;

  const SubAssemblyRef({required this.code, required this.name});

  factory SubAssemblyRef.fromMap(Map<String, dynamic> map) => SubAssemblyRef(
        code: map['code'] as String? ?? '',
        name: map['name'] as String? ?? '',
      );
}

class PartItem {
  final String? id;
  final String? description;
  final String? partType;
  final int? quantity;

  /// depth_level may be int, null, or a String like "3,5"
  final dynamic depthLevel;
  final String? subAssembly;
  final String? itemCode;
  final String? internalCode;

  const PartItem({
    this.id,
    this.description,
    this.partType,
    this.quantity,
    this.depthLevel,
    this.subAssembly,
    this.itemCode,
    this.internalCode,
  });

  factory PartItem.fromMap(Map<String, dynamic> map) => PartItem(
        id: map['id'] as String?,
        description: map['description'] as String?,
        partType: map['part_type'] as String?,
        quantity: map['quantity'] as int?,
        depthLevel: map['depth_level'],
        subAssembly: map['sub_assembly'] as String?,
        itemCode: map['item_code'] as String?,
        internalCode: map['internal_code'] as String?,
      );

  /// True if this item is a hardware/fastener (has internal_code, no item_code)
  bool get isHardware => internalCode != null && itemCode == null;

  /// The display label for this part
  String get displayName =>
      description ?? itemCode ?? internalCode ?? id ?? 'Unknown Part';

  /// The code used to resolve a 3D model URL — prefer item_code, fall back to internal_code
  String? get modelCode => itemCode ?? internalCode;
}

class PartGroup {
  final String group;
  final String groupHeader;
  final String partType;
  final List<SubAssemblyRef> subAssemblies;
  final List<PartItem> items;

  const PartGroup({
    required this.group,
    required this.groupHeader,
    required this.partType,
    required this.subAssemblies,
    required this.items,
  });

  factory PartGroup.fromMap(Map<String, dynamic> map) => PartGroup(
        group: map['group'] as String? ?? '',
        groupHeader: map['group_header'] as String? ?? '',
        partType: map['part_type'] as String? ?? '',
        subAssemblies: ((map['sub_assemblies'] as List?) ?? [])
            .map((e) =>
                SubAssemblyRef.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
        items: ((map['items'] as List?) ?? [])
            .map((e) => PartItem.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );

  /// User-facing label: e.g. "F01 – Meter Assy"
  String get displayLabel {
    final parts = groupHeader.split(' ');
    // Strip the model prefix (LF150T-8G F-01 ...) and keep the English portion
    final engStart = parts.indexWhere((p) =>
        p.isNotEmpty &&
        p.codeUnitAt(0) < 128 &&
        !RegExp(r'^[A-Z]\d+$').hasMatch(p) &&
        !p.startsWith('LF') &&
        !p.startsWith('F-'));
    final label =
        engStart >= 0 ? parts.sublist(engStart).join(' ') : groupHeader;
    return '${group.replaceAll('F', 'F-')} — $label';
  }

  /// Loadable items — those with a model code (item_code or internal_code)
  List<PartItem> get loadableItems =>
      items.where((i) => i.modelCode != null).toList();
}

class PartsHierarchy {
  final String brand;
  final String model;
  final List<PartGroup> groups;

  const PartsHierarchy({
    required this.brand,
    required this.model,
    required this.groups,
  });

  factory PartsHierarchy.fromMap(Map<String, dynamic> map) => PartsHierarchy(
        brand: map['brand'] as String? ?? '',
        model: map['model'] as String? ?? '',
        groups: ((map['groups'] as List?) ?? [])
            .map((e) => PartGroup.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
}
