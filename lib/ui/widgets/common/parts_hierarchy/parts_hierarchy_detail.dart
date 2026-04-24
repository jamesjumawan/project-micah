import 'package:flutter/material.dart';
import 'package:project_micah/models/parts_hierarchy_model.dart';
import 'package:project_micah/ui/utils/constants/app_colors.dart';
import 'package:project_micah/ui/utils/constants/ui_helpers.dart';

/// Shown in the right panel when a leaf part is selected in the hierarchy tree.
/// Replaces the tree; tap the back arrow to return to the tree.
class PartsHierarchyDetail extends StatelessWidget {
  final PartItem item;
  final VoidCallback onBack;

  const PartsHierarchyDetail({
    super.key,
    required this.item,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header with back button ──────────────────────────────────────
        InkWell(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: UIHelpers.spacing12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Icon(Icons.arrow_back_ios,
                    size: 16, color: AppColors.textSecondary),
                UIHelpers.horizontalSpace8,
                Expanded(
                  child: Text(
                    item.displayName,
                    style: textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Detail content ───────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UIHelpers.spacing12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.partType != null)
                  _chip(context, item.partType!),
                UIHelpers.verticalSpace12,
                if (item.itemCode != null)
                  _row(context, 'Item Code', item.itemCode!),
                if (item.internalCode != null)
                  _row(context, 'Internal Code', item.internalCode!),
                if (item.quantity != null)
                  _row(context, 'Quantity', '${item.quantity}'),
                if (item.subAssembly != null)
                  _row(context, 'Sub-Assembly', item.subAssembly!),
                if (item.description != null) ...[
                  UIHelpers.verticalSpace16,
                  Text(
                    'Description',
                    style: textTheme.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  UIHelpers.verticalSpace4,
                  Text(
                    item.description!,
                    style: textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: textTheme.labelSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(value,
                style: textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }
}
