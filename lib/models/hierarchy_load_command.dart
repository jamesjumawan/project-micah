/// A single part to be loaded lazily in the Phase 5 viewer.
class HierarchyPartLoad {
  final String partId;
  final String objUrl;
  final String? mtlUrl;

  const HierarchyPartLoad({
    required this.partId,
    required this.objUrl,
    this.mtlUrl,
  });

  Map<String, dynamic> toJson() => {
        'partId': partId,
        'objUrl': objUrl,
        if (mtlUrl != null) 'mtlUrl': mtlUrl,
      };
}

/// Command sent to [ThreeDViewer] to trigger lazy loading of one group's parts.
///
/// Equality is intentionally identity-based — a new instance always re-triggers
/// a load even if the groupCode is the same (e.g., retry on error).
class HierarchyGroupLoadCommand {
  final String groupCode;
  final List<HierarchyPartLoad> parts;

  HierarchyGroupLoadCommand({required this.groupCode, required this.parts});

  Map<String, dynamic> toJson() => {
        'type': 'loadGroup',
        'groupCode': groupCode,
        'parts': parts.map((p) => p.toJson()).toList(),
      };
}

/// Command sent to [ThreeDViewer] to load a single part on demand.
class HierarchyPartLoadCommand {
  final String partId;
  final String objUrl;
  final String? mtlUrl;

  HierarchyPartLoadCommand({
    required this.partId,
    required this.objUrl,
    this.mtlUrl,
  });

  Map<String, dynamic> toJson() => {
        'type': 'loadPart',
        'partId': partId,
        'objUrl': objUrl,
        if (mtlUrl != null) 'mtlUrl': mtlUrl,
      };
}
