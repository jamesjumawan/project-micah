import 'package:flutter/material.dart';
import 'package:project_micah/models/parts_hierarchy_model.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';
import 'package:project_micah/ui/widgets/common/loading/cog_loader.dart';

/// Phase 5 hierarchy tree.
/// Shows groups → sub-assemblies → items. Groups are lazy-loaded on expand.
class PartsHierarchyTree extends StatelessWidget {
  final PartsHierarchy hierarchy;
  final Set<String> expandedGroups;
  final Set<String> loadedGroups;
  final Set<String> loadingGroups;
  final String? selectedPartId;

  final void Function(String groupCode) onExpandGroup;
  final void Function(String groupCode) onCollapseGroup;
  final void Function(String partId, String modelCode, PartItem item) onPartTap;

  const PartsHierarchyTree({
    super.key,
    required this.hierarchy,
    required this.expandedGroups,
    required this.loadedGroups,
    required this.loadingGroups,
    required this.selectedPartId,
    required this.onExpandGroup,
    required this.onCollapseGroup,
    required this.onPartTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: hierarchy.groups.length,
      itemBuilder: (context, i) => _GroupTile(
        group: hierarchy.groups[i],
        isExpanded: expandedGroups.contains(hierarchy.groups[i].group),
        isLoaded: loadedGroups.contains(hierarchy.groups[i].group),
        isLoading: loadingGroups.contains(hierarchy.groups[i].group),
        selectedPartId: selectedPartId,
        onExpand: () => onExpandGroup(hierarchy.groups[i].group),
        onCollapse: () => onCollapseGroup(hierarchy.groups[i].group),
        onPartTap: onPartTap,
      ),
    );
  }
}

class _GroupTile extends StatefulWidget {
  final PartGroup group;
  final bool isExpanded;
  final bool isLoaded;
  final bool isLoading;
  final String? selectedPartId;
  final VoidCallback onExpand;
  final VoidCallback onCollapse;
  final void Function(String partId, String modelCode, PartItem item) onPartTap;

  const _GroupTile({
    required this.group,
    required this.isExpanded,
    required this.isLoaded,
    required this.isLoading,
    required this.selectedPartId,
    required this.onExpand,
    required this.onCollapse,
    required this.onPartTap,
  });

  @override
  State<_GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<_GroupTile> {
  // Tracks which sub-assembly codes are collapsed locally
  final Set<String> _collapsedSAs = {};

  void _toggleSA(String saCode) {
    setState(() {
      if (_collapsedSAs.contains(saCode)) {
        _collapsedSAs.remove(saCode);
      } else {
        _collapsedSAs.add(saCode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Group header row ──────────────────────────────────────────────
        InkWell(
          onTap: widget.isExpanded ? widget.onCollapse : widget.onExpand,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: UIHelpers.spacing12, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isExpanded
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                // Expand / collapse icon
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.chevron_right,
                      size: 18, color: AppColors.textSecondary),
                ),
                UIHelpers.horizontalSpace8,
                // Group badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.group.group,
                    style: textTheme.labelSmall?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                UIHelpers.horizontalSpace8,
                // Header text (English portion only)
                Expanded(
                  child: Text(
                    _englishLabel(widget.group.groupHeader),
                    style: textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Part count
                Text(
                  '${widget.group.items.length}',
                  style: textTheme.labelSmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                UIHelpers.horizontalSpace4,
                if (widget.isLoading)
                  const SizedBox(
                      width: 12, height: 12, child: CogLoader(size: 12)),
                if (widget.isLoaded && !widget.isLoading)
                  Icon(Icons.check_circle, size: 14, color: AppColors.success),
              ],
            ),
          ),
        ),

        // ── Expanded: items list ──────────────────────────────────────────
        if (widget.isExpanded) ..._buildItems(context),
      ],
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    final Map<String?, List<PartItem>> bySubAssembly = {};
    for (final item in widget.group.items) {
      (bySubAssembly[item.subAssembly] ??= []).add(item);
    }

    final widgets = <Widget>[];

    // Standalone items (no sub_assembly) first
    final standalone = bySubAssembly[null] ?? [];
    for (final item in standalone) {
      widgets.add(_PartRow(
        item: item,
        indent: 24,
        isSelected: widget.selectedPartId != null &&
            (widget.selectedPartId == item.id ||
                widget.selectedPartId == item.modelCode),
        onTap: item.modelCode != null
            ? () => widget.onPartTap(
                item.id ?? item.modelCode!, item.modelCode!, item)
            : null,
      ));
    }

    // Sub-assembly sections — header tap toggles its items
    for (final sa in widget.group.subAssemblies) {
      final saItems = bySubAssembly[sa.code] ?? [];
      if (saItems.isEmpty) continue;
      final isCollapsed = _collapsedSAs.contains(sa.code);
      widgets.add(_SubAssemblyHeader(
        name: sa.code,
        isCollapsed: isCollapsed,
        onTap: () => _toggleSA(sa.code),
      ));
      if (!isCollapsed) {
        for (final item in saItems) {
          widgets.add(_PartRow(
            item: item,
            indent: 36,
            isSelected: widget.selectedPartId != null &&
                (widget.selectedPartId == item.id ||
                    widget.selectedPartId == item.modelCode),
            onTap: item.modelCode != null
                ? () => widget.onPartTap(
                    item.id ?? item.modelCode!, item.modelCode!, item)
                : null,
          ));
        }
      }
    }

    return widgets;
  }

  String _englishLabel(String header) {
    final tokens = header.split(' ');
    final start = tokens.indexWhere((t) =>
        t.isNotEmpty &&
        t.codeUnitAt(0) < 128 &&
        !RegExp(r'^[A-Z]+\d').hasMatch(t) &&
        !t.startsWith('F-'));
    return start >= 0 ? tokens.sublist(start).join(' ') : header;
  }
}

class _SubAssemblyHeader extends StatelessWidget {
  final String name;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _SubAssemblyHeader({
    required this.name,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(36, 6, 12, 4),
        color: AppColors.surface,
        child: Row(
          children: [
            AnimatedRotation(
              turns: isCollapsed ? 0 : 0.25,
              duration: const Duration(milliseconds: 150),
              child:
                  Icon(Icons.chevron_right, size: 14, color: AppColors.primary),
            ),
            UIHelpers.horizontalSpace4,
            Text(
              name,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartRow extends StatelessWidget {
  final PartItem item;
  final double indent;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PartRow({
    required this.item,
    required this.indent,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(indent, 6, 12, 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border:
              Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            // Part type icon
            Icon(
              item.isHardware ? Icons.hardware : Icons.settings,
              size: 13,
              color: item.isHardware
                  ? AppColors.textHint
                  : AppColors.textSecondary,
            ),
            UIHelpers.horizontalSpace8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayName,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.modelCode != null)
                    Text(
                      item.modelCode!,
                      style: textTheme.labelSmall
                          ?.copyWith(color: AppColors.textHint),
                    ),
                ],
              ),
            ),
            if (item.quantity != null)
              Text(
                'x${item.quantity}',
                style: textTheme.labelSmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
